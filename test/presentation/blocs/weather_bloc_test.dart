import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:meteo/core/error/failures.dart';
import 'package:meteo/core/network/connectivity_service.dart';
import 'package:meteo/core/services/local_storage_service.dart';
import 'package:meteo/core/services/notification_service.dart';
import 'package:meteo/domain/repositories/weather_repository.dart';
import 'package:meteo/presentation/blocs/weather/weather_bloc.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/test_data.dart';

class MockWeatherRepository extends Mock implements WeatherRepository {}

class MockConnectivityService extends Mock implements ConnectivityService {}

class MockLocalStorageService extends Mock implements LocalStorageService {}

class MockNotificationService extends Mock implements NotificationService {}

void main() {
  late MockWeatherRepository mockRepository;
  late MockConnectivityService mockConnectivity;
  late MockLocalStorageService mockStorage;
  late MockNotificationService mockNotifications;
  late Logger silentLogger;

  setUp(() {
    mockRepository = MockWeatherRepository();
    mockConnectivity = MockConnectivityService();
    mockStorage = MockLocalStorageService();
    mockNotifications = MockNotificationService();
    silentLogger = Logger(level: Level.off);

    // Default stubs for storage and notifications (non-fatal)
    when(() => mockStorage.saveLastSource(any())).thenAnswer((_) async {});
    when(() => mockStorage.saveLastCityName(any())).thenAnswer((_) async {});
    when(() => mockNotifications.showSevereWeatherAlert(
          cityName: any(named: 'cityName'),
          condition: any(named: 'condition'),
        )).thenAnswer((_) async {});
    when(() => mockNotifications.scheduleDailySummary(
          cityName: any(named: 'cityName'),
          temperature: any(named: 'temperature'),
          condition: any(named: 'condition'),
        )).thenAnswer((_) async {});
  });

  WeatherBloc buildBloc() => WeatherBloc(
    repository: mockRepository,
    connectivity: mockConnectivity,
    storage: mockStorage,
    notifications: mockNotifications,
    logger: silentLogger,
  );

  group('WeatherFetchByCityRequested', () {
    blocTest<WeatherBloc, WeatherState>(
      'emette [WeatherLoading, WeatherLoaded] in caso di successo',
      setUp: () {
        when(() => mockConnectivity.isConnected).thenAnswer((_) async => true);
        when(() => mockRepository.fetchWeatherByCity('Roma')).thenAnswer(
          (_) async => (kWeather, [kForecastDay]),
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const WeatherFetchByCityRequested('Roma')),
      expect: () => [
        const WeatherLoading(),
        WeatherLoaded(
          weather: kWeather,
          forecast: [kForecastDay],
          source: WeatherSource.search,
        ),
      ],
    );

    blocTest<WeatherBloc, WeatherState>(
      'emette [WeatherError(NetworkFailure)] senza connessione',
      setUp: () {
        when(() => mockConnectivity.isConnected).thenAnswer((_) async => false);
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const WeatherFetchByCityRequested('Roma')),
      expect: () => [
        const WeatherError(failure: NetworkFailure()),
      ],
    );

    blocTest<WeatherBloc, WeatherState>(
      'emette [WeatherLoading, WeatherError] su ServerFailure 404',
      setUp: () {
        when(() => mockConnectivity.isConnected).thenAnswer((_) async => true);
        when(() => mockRepository.fetchWeatherByCity('XYZ'))
            .thenThrow(const ServerFailure('Città non trovata', statusCode: 404));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const WeatherFetchByCityRequested('XYZ')),
      expect: () => [
        const WeatherLoading(),
        const WeatherError(
          failure: ServerFailure('Città non trovata', statusCode: 404),
        ),
      ],
    );

    blocTest<WeatherBloc, WeatherState>(
      'conserva i dati precedenti in WeatherLoading se era già loaded',
      setUp: () {
        when(() => mockConnectivity.isConnected).thenAnswer((_) async => true);
        when(() => mockRepository.fetchWeatherByCity(any())).thenAnswer(
          (_) async => (kWeather, [kForecastDay]),
        );
      },
      build: buildBloc,
      seed: () => WeatherLoaded(
        weather: kWeather,
        forecast: [kForecastDay],
        source: WeatherSource.search,
      ),
      act: (bloc) => bloc.add(const WeatherFetchByCityRequested('Milano')),
      expect: () => [
        WeatherLoading(previousWeather: kWeather, previousForecast: [kForecastDay]),
        WeatherLoaded(
          weather: kWeather,
          forecast: [kForecastDay],
          source: WeatherSource.search,
        ),
      ],
    );
  });

  group('WeatherFetchByLocationRequested', () {
    blocTest<WeatherBloc, WeatherState>(
      'emette [WeatherLoading, WeatherLoaded] con source=gps',
      setUp: () {
        when(() => mockConnectivity.isConnected).thenAnswer((_) async => true);
        when(() => mockRepository.fetchWeatherByLocation()).thenAnswer(
          (_) async => (kWeather, [kForecastDay]),
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const WeatherFetchByLocationRequested()),
      expect: () => [
        const WeatherLoading(),
        WeatherLoaded(
          weather: kWeather,
          forecast: [kForecastDay],
          source: WeatherSource.gps,
        ),
      ],
    );

    blocTest<WeatherBloc, WeatherState>(
      'emette WeatherError(LocationFailure) su permesso negato',
      setUp: () {
        when(() => mockConnectivity.isConnected).thenAnswer((_) async => true);
        when(() => mockRepository.fetchWeatherByLocation())
            .thenThrow(const LocationFailure('Permesso negato.'));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const WeatherFetchByLocationRequested()),
      expect: () => [
        const WeatherLoading(),
        const WeatherError(failure: LocationFailure('Permesso negato.')),
      ],
    );
  });

  group('WeatherRefreshRequested', () {
    blocTest<WeatherBloc, WeatherState>(
      'ri-fetcha per GPS se source era gps',
      setUp: () {
        when(() => mockConnectivity.isConnected).thenAnswer((_) async => true);
        when(() => mockRepository.fetchWeatherByLocation()).thenAnswer(
          (_) async => (kWeather, [kForecastDay]),
        );
      },
      build: buildBloc,
      seed: () => WeatherLoaded(
        weather: kWeather,
        forecast: [kForecastDay],
        source: WeatherSource.gps,
      ),
      act: (bloc) => bloc.add(const WeatherRefreshRequested()),
      expect: () => [
        WeatherLoading(previousWeather: kWeather, previousForecast: [kForecastDay]),
        WeatherLoaded(
          weather: kWeather,
          forecast: [kForecastDay],
          source: WeatherSource.gps,
        ),
      ],
    );

    blocTest<WeatherBloc, WeatherState>(
      'ri-fetcha per città se source era search',
      setUp: () {
        when(() => mockConnectivity.isConnected).thenAnswer((_) async => true);
        when(() => mockRepository.fetchWeatherByCity(kWeather.cityName))
            .thenAnswer((_) async => (kWeather, [kForecastDay]));
      },
      build: buildBloc,
      seed: () => WeatherLoaded(
        weather: kWeather,
        forecast: [kForecastDay],
        source: WeatherSource.search,
      ),
      act: (bloc) => bloc.add(const WeatherRefreshRequested()),
      expect: () => [
        WeatherLoading(previousWeather: kWeather, previousForecast: [kForecastDay]),
        WeatherLoaded(
          weather: kWeather,
          forecast: [kForecastDay],
          source: WeatherSource.search,
        ),
      ],
    );
  });
}
