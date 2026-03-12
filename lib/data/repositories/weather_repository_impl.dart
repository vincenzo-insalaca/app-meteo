import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';

import '../../core/constants/api_constants.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/city_suggestion.dart';
import '../../domain/entities/forecast_day.dart';
import '../../domain/entities/weather.dart';
import '../../domain/repositories/weather_repository.dart';
import '../models/forecast_response_dto.dart';
import '../models/geo_location_dto.dart';
import '../models/weather_response_dto.dart';
import '../remote/geo_api_client.dart';
import '../remote/weather_api_client.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  static const Duration _cacheTtl = Duration(minutes: 10);

  final WeatherApiClient _weatherApiClient;
  final GeoApiClient _geoApiClient;
  final Logger _logger;

  final Map<String, ({(Weather, List<ForecastDay>) data, DateTime timestamp})>
      _cache = {};

  WeatherRepositoryImpl({
    required WeatherApiClient weatherApiClient,
    required GeoApiClient geoApiClient,
    required Logger logger,
  })  : _weatherApiClient = weatherApiClient,
        _geoApiClient = geoApiClient,
        _logger = logger;

  bool _isCacheValid(String key) {
    final entry = _cache[key];
    if (entry == null) return false;
    return DateTime.now().difference(entry.timestamp) < _cacheTtl;
  }

  @override
  Future<(Weather, List<ForecastDay>)> fetchWeatherByCity(
    String cityName,
  ) async {
    final cacheKey = 'city:${cityName.toLowerCase()}';
    if (_isCacheValid(cacheKey)) {
      _logger.d('Cache hit per "$cityName"');
      return _cache[cacheKey]!.data;
    }

    try {
      // Le due chiamate partono in parallelo
      final weatherFuture = _weatherApiClient.getCurrentWeatherByCity(cityName);
      final forecastFuture = _weatherApiClient.getForecastByCity(cityName);

      final weatherDto = await weatherFuture;
      final forecastDto = await forecastFuture;

      final result = (_mapWeather(weatherDto), _mapForecast(forecastDto));
      _cache[cacheKey] = (data: result, timestamp: DateTime.now());
      return result;
    } catch (e, st) {
      _logger.w('fetchWeatherByCity failed', error: e, stackTrace: st);
      throw _wrapError(e);
    }
  }

  @override
  Future<(Weather, List<ForecastDay>)> fetchWeatherByLocation() async {
    const cacheKey = 'location';
    if (_isCacheValid(cacheKey)) {
      _logger.d('Cache hit per GPS');
      return _cache[cacheKey]!.data;
    }

    try {
      final position = await _getPosition();

      // Le due chiamate partono in parallelo
      final weatherFuture = _weatherApiClient.getCurrentWeatherByCoords(
        position.latitude,
        position.longitude,
      );
      final forecastFuture = _weatherApiClient.getForecastByCoords(
        position.latitude,
        position.longitude,
      );

      final weatherDto = await weatherFuture;
      final forecastDto = await forecastFuture;

      final result = (_mapWeather(weatherDto), _mapForecast(forecastDto));
      _cache[cacheKey] = (data: result, timestamp: DateTime.now());
      return result;
    } catch (e, st) {
      _logger.w('fetchWeatherByLocation failed', error: e, stackTrace: st);
      if (e is Failure) rethrow;
      throw _wrapError(e);
    }
  }

  @override
  Future<List<CitySuggestion>> searchCities(String query) async {
    if (query.length < 3) return const [];
    try {
      final dtos = await _geoApiClient.searchCities(
        query,
        ApiConstants.citySuggestionsLimit,
      );
      return dtos.map(_mapSuggestion).toList();
    } catch (e) {
      _logger.w('searchCities failed: $e');
      return const [];
    }
  }

  // ─── GPS ────────────────────────────────────────────────────────────────────

  Future<Position> _getPosition() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      throw const LocationFailure(
        'Permesso posizione negato definitivamente. Abilitalo nelle impostazioni del dispositivo.',
      );
    }

    if (permission == LocationPermission.denied) {
      throw const LocationFailure('Permesso posizione negato.');
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
      ),
    );
  }

  // ─── Mapping DTO → Entity ────────────────────────────────────────────────────

  Weather _mapWeather(WeatherResponseDto dto) {
    final condition = dto.weather.isNotEmpty ? dto.weather.first : null;
    return Weather(
      cityName: dto.name.replaceAll('Province of ', ''),
      temperature: dto.main.temp,
      feelsLike: dto.main.feelsLike,
      tempMin: dto.main.tempMin,
      tempMax: dto.main.tempMax,
      humidity: dto.main.humidity,
      windSpeedMs: dto.wind.speed,
      condition: condition?.main ?? 'Clear',
      conditionDescription: condition?.description ?? '',
      iconCode: condition?.icon ?? '01d',
    );
  }

  List<ForecastDay> _mapForecast(ForecastResponseDto dto) {
    final days = <ForecastDay>[];
    for (var i = 0; i < dto.list.length; i += 8) {
      final item = dto.list[i];
      final condition = item.weather.isNotEmpty ? item.weather.first : null;
      days.add(
        ForecastDay(
          date: item.dateTime,
          temperature: item.main.temp,
          condition: condition?.main ?? 'Clear',
          iconCode: condition?.icon ?? '01d',
        ),
      );
    }
    return days;
  }

  CitySuggestion _mapSuggestion(GeoLocationDto dto) => CitySuggestion(
    name: dto.name,
    country: dto.country,
    state: dto.state,
    lat: dto.lat,
    lon: dto.lon,
  );

  // ─── Error wrapping ──────────────────────────────────────────────────────────

  Failure _wrapError(Object e) {
    if (e is Failure) return e;

    if (e is DioException) {
      return switch (e.type) {
        DioExceptionType.connectionError ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.receiveTimeout ||
        DioExceptionType.connectionTimeout => const NetworkFailure(),
        _ => ServerFailure(
          _statusMessage(e.response?.statusCode),
          statusCode: e.response?.statusCode,
        ),
      };
    }

    return UnknownFailure(e.toString());
  }

  String _statusMessage(int? statusCode) => switch (statusCode) {
    401 => 'Chiave API non valida',
    404 => 'Città non trovata',
    429 => 'Troppe richieste. Riprova più tardi.',
    _ => 'Errore del server (${statusCode ?? 'sconosciuto'})',
  };
}
