import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:logger/logger.dart';

import '../../../core/error/failures.dart';
import '../../../core/network/connectivity_service.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../domain/entities/forecast_day.dart';
import '../../../domain/entities/weather.dart';
import '../../../domain/repositories/weather_repository.dart';

part 'weather_event.dart';
part 'weather_state.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final WeatherRepository _repository;
  final ConnectivityService _connectivity;
  final LocalStorageService _storage;
  final NotificationService _notifications;
  final Logger _logger;

  WeatherBloc({
    required WeatherRepository repository,
    required ConnectivityService connectivity,
    required LocalStorageService storage,
    required NotificationService notifications,
    required Logger logger,
  })  : _repository = repository,
        _connectivity = connectivity,
        _storage = storage,
        _notifications = notifications,
        _logger = logger,
        super(const WeatherInitial()) {
    on<WeatherInitializeRequested>(_onInitialize);
    on<WeatherFetchByLocationRequested>(
      _onFetchByLocation,
      transformer: droppable(),
    );
    on<WeatherFetchByCityRequested>(
      _onFetchByCity,
      transformer: droppable(),
    );
    on<WeatherRefreshRequested>(
      _onRefresh,
      transformer: droppable(),
    );
  }

  // ─── Handlers ───────────────────────────────────────────────────────────────

  Future<void> _onInitialize(
    WeatherInitializeRequested event,
    Emitter<WeatherState> emit,
  ) async {
    final lastSource = await _storage.getLastSource();
    final lastCity = await _storage.getLastCityName();

    if (lastSource == WeatherSource.search.name && lastCity != null) {
      add(WeatherFetchByCityRequested(lastCity));
    } else {
      add(const WeatherFetchByLocationRequested());
    }
  }

  Future<void> _onFetchByLocation(
    WeatherFetchByLocationRequested event,
    Emitter<WeatherState> emit,
  ) async {
    if (!await _connectivity.isConnected) {
      emit(WeatherError(
        failure: const NetworkFailure(),
        previousWeather: _previousWeather,
        previousForecast: _previousForecast,
      ));
      return;
    }

    emit(WeatherLoading(
      previousWeather: _previousWeather,
      previousForecast: _previousForecast,
    ));

    try {
      final (weather, forecast) = await _repository.fetchWeatherByLocation();
      await _storage.saveLastSource(WeatherSource.gps.name);
      await _storage.saveLastCityName(weather.cityName);
      emit(WeatherLoaded(
        weather: weather,
        forecast: forecast,
        source: WeatherSource.gps,
      ));
      await _triggerNotifications(weather);
    } on Failure catch (failure) {
      _logger.w('FetchByLocation failed: $failure');
      emit(WeatherError(
        failure: failure,
        previousWeather: _previousWeather,
        previousForecast: _previousForecast,
      ));
    } catch (e, st) {
      _logger.e('Unexpected error in FetchByLocation', error: e, stackTrace: st);
      emit(WeatherError(
        failure: UnknownFailure(e.toString()),
        previousWeather: _previousWeather,
        previousForecast: _previousForecast,
      ));
    }
  }

  Future<void> _onFetchByCity(
    WeatherFetchByCityRequested event,
    Emitter<WeatherState> emit,
  ) async {
    if (!await _connectivity.isConnected) {
      emit(WeatherError(
        failure: const NetworkFailure(),
        previousWeather: _previousWeather,
        previousForecast: _previousForecast,
      ));
      return;
    }

    emit(WeatherLoading(
      previousWeather: _previousWeather,
      previousForecast: _previousForecast,
    ));

    try {
      final (weather, forecast) =
          await _repository.fetchWeatherByCity(event.cityName);
      await _storage.saveLastSource(WeatherSource.search.name);
      await _storage.saveLastCityName(weather.cityName);
      emit(WeatherLoaded(
        weather: weather,
        forecast: forecast,
        source: WeatherSource.search,
      ));
      await _triggerNotifications(weather);
    } on Failure catch (failure) {
      _logger.w('FetchByCity failed: $failure');
      emit(WeatherError(
        failure: failure,
        previousWeather: _previousWeather,
        previousForecast: _previousForecast,
      ));
    } catch (e, st) {
      _logger.e('Unexpected error in FetchByCity', error: e, stackTrace: st);
      emit(WeatherError(
        failure: UnknownFailure(e.toString()),
        previousWeather: _previousWeather,
        previousForecast: _previousForecast,
      ));
    }
  }

  Future<void> _onRefresh(
    WeatherRefreshRequested event,
    Emitter<WeatherState> emit,
  ) async {
    final current = state;
    if (current is WeatherLoaded && current.source == WeatherSource.search) {
      await _onFetchByCity(
        WeatherFetchByCityRequested(current.weather.cityName),
        emit,
      );
    } else {
      await _onFetchByLocation(const WeatherFetchByLocationRequested(), emit);
    }
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────────

  Future<void> _triggerNotifications(Weather weather) async {
    try {
      final cond = weather.condition.toLowerCase();
      if (cond == 'rain' || cond == 'thunderstorm' || cond == 'snow') {
        await _notifications.showSevereWeatherAlert(
          cityName: weather.cityName,
          condition: weather.conditionDescription,
        );
      }
      await _notifications.scheduleDailySummary(
        cityName: weather.cityName,
        temperature: weather.temperature.round(),
        condition: weather.conditionDescription,
      );
    } catch (e) {
      _logger.w('Notification error (non-fatal): $e');
    }
  }

  Weather? get _previousWeather => switch (state) {
    WeatherLoaded(:final weather) => weather,
    WeatherError(:final previousWeather) => previousWeather,
    WeatherLoading(:final previousWeather) => previousWeather,
    _ => null,
  };

  List<ForecastDay>? get _previousForecast => switch (state) {
    WeatherLoaded(:final forecast) => forecast,
    WeatherError(:final previousForecast) => previousForecast,
    WeatherLoading(:final previousForecast) => previousForecast,
    _ => null,
  };
}
