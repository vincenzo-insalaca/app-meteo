import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:meteo/core/error/failures.dart';
import 'package:meteo/data/models/geo_location_dto.dart';
import 'package:meteo/data/models/weather_response_dto.dart';
import 'package:meteo/data/remote/geo_api_client.dart';
import 'package:meteo/data/remote/weather_api_client.dart';
import 'package:meteo/data/repositories/weather_repository_impl.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/test_data.dart';

class MockWeatherApiClient extends Mock implements WeatherApiClient {}

class MockGeoApiClient extends Mock implements GeoApiClient {}

void main() {
  late MockWeatherApiClient mockWeatherApi;
  late MockGeoApiClient mockGeoApi;
  late WeatherRepositoryImpl repository;

  setUp(() {
    mockWeatherApi = MockWeatherApiClient();
    mockGeoApi = MockGeoApiClient();
    repository = WeatherRepositoryImpl(
      weatherApiClient: mockWeatherApi,
      geoApiClient: mockGeoApi,
      logger: Logger(level: Level.off),
    );
  });

  group('fetchWeatherByCity', () {
    const city = 'Roma';

    test('ritorna (Weather, List<ForecastDay>) in caso di successo', () async {
      when(() => mockWeatherApi.getCurrentWeatherByCity(city))
          .thenAnswer((_) async => kWeatherResponseDto);
      when(() => mockWeatherApi.getForecastByCity(city))
          .thenAnswer((_) async => kForecastResponseDto);

      final (weather, forecast) = await repository.fetchWeatherByCity(city);

      expect(weather.cityName, 'Roma');
      expect(weather.temperature, 20.5);
      expect(weather.condition, 'Clear');
      expect(weather.windSpeedMs, 3.2);
      expect(forecast, isNotEmpty);
    });

    test('mappa il forecast ogni 8 voci (ogni ~24h)', () async {
      when(() => mockWeatherApi.getCurrentWeatherByCity(city))
          .thenAnswer((_) async => kWeatherResponseDto);
      when(() => mockWeatherApi.getForecastByCity(city))
          .thenAnswer((_) async => kForecastResponseDto);

      final (_, forecast) = await repository.fetchWeatherByCity(city);

      // kForecastResponseJson ha 10 voci: con step 8 → 2 giorni (indici 0 e 8)
      expect(forecast.length, 2);
    });

    test('rimuove "Province of " dal nome città', () async {
      final dtoWithProvince = WeatherResponseDto.fromJson({
        ...kWeatherResponseJson,
        'name': 'Province of Roma',
      });
      when(() => mockWeatherApi.getCurrentWeatherByCity(city))
          .thenAnswer((_) async => dtoWithProvince);
      when(() => mockWeatherApi.getForecastByCity(city))
          .thenAnswer((_) async => kForecastResponseDto);

      final (weather, _) = await repository.fetchWeatherByCity(city);

      expect(weather.cityName, 'Roma');
    });

    test('lancia NetworkFailure su DioException connectionError', () async {
      when(() => mockWeatherApi.getCurrentWeatherByCity(city)).thenThrow(
        DioException(
          requestOptions: RequestOptions(),
          type: DioExceptionType.connectionError,
        ),
      );
      when(() => mockWeatherApi.getForecastByCity(city))
          .thenAnswer((_) async => kForecastResponseDto);

      expect(
        () => repository.fetchWeatherByCity(city),
        throwsA(isA<NetworkFailure>()),
      );
    });

    test('lancia ServerFailure(404) su risposta 404', () async {
      when(() => mockWeatherApi.getCurrentWeatherByCity(city)).thenThrow(
        DioException(
          requestOptions: RequestOptions(),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(),
            statusCode: 404,
          ),
        ),
      );
      when(() => mockWeatherApi.getForecastByCity(city))
          .thenAnswer((_) async => kForecastResponseDto);

      await expectLater(
        () => repository.fetchWeatherByCity(city),
        throwsA(
          isA<ServerFailure>().having((f) => f.statusCode, 'statusCode', 404),
        ),
      );
    });
  });

  group('searchCities', () {
    test('ritorna lista vuota se query < 3 caratteri', () async {
      final result = await repository.searchCities('Ro');

      expect(result, isEmpty);
      verifyNever(() => mockGeoApi.searchCities(any(), any()));
    });

    test('ritorna lista di CitySuggestion mappata', () async {
      when(() => mockGeoApi.searchCities('Roma', 5)).thenAnswer(
        (_) async => kGeoResponseJson
            .map(GeoLocationDto.fromJson)
            .toList(),
      );

      final result = await repository.searchCities('Roma');

      expect(result, hasLength(2));
      expect(result.first.name, 'Roma');
      expect(result.first.state, 'Lazio');
      expect(result.first.displayName, 'Roma, Lazio, IT');
    });

    test('ritorna lista vuota su errore (non rilancia)', () async {
      when(() => mockGeoApi.searchCities(any(), any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(),
          type: DioExceptionType.connectionError,
        ),
      );

      final result = await repository.searchCities('Roma');

      expect(result, isEmpty);
    });
  });
}
