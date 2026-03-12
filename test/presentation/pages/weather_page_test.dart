import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:meteo/core/error/failures.dart';
import 'package:meteo/domain/repositories/favorites_repository.dart';
import 'package:meteo/domain/repositories/weather_repository.dart';
import 'package:meteo/generated/l10n/app_localizations.dart';
import 'package:meteo/presentation/blocs/favorites/favorites_cubit.dart';
import 'package:meteo/presentation/blocs/search/search_cubit.dart';
import 'package:meteo/presentation/blocs/weather/weather_bloc.dart';
import 'package:meteo/presentation/pages/weather/weather_page.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/test_data.dart';

// ─── Mock classes ─────────────────────────────────────────────────────────────

class MockWeatherBloc extends MockBloc<WeatherEvent, WeatherState>
    implements WeatherBloc {}

class MockWeatherRepository extends Mock implements WeatherRepository {}

class MockFavoritesRepository extends Mock implements FavoritesRepository {}

// ─── Helpers ─────────────────────────────────────────────────────────────────

Widget _buildTestApp(WeatherBloc bloc, FavoritesCubit favoritesCubit) {
  return MultiBlocProvider(
    providers: [
      BlocProvider<WeatherBloc>.value(value: bloc),
      BlocProvider<FavoritesCubit>.value(value: favoritesCubit),
    ],
    child: MaterialApp(
      locale: const Locale('it'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const WeatherPage(),
    ),
  );
}

void main() {
  late MockWeatherBloc mockBloc;
  late MockWeatherRepository mockRepository;
  late MockFavoritesRepository mockFavoritesRepository;
  late FavoritesCubit favoritesCubit;

  setUpAll(() async {
    await initializeDateFormatting('it_IT', null);
  });

  setUp(() {
    mockBloc = MockWeatherBloc();
    mockRepository = MockWeatherRepository();
    mockFavoritesRepository = MockFavoritesRepository();

    when(() => mockFavoritesRepository.getFavorites())
        .thenAnswer((_) async => []);
    favoritesCubit = FavoritesCubit(mockFavoritesRepository)..load();

    // Override GetIt per i test: SearchCubit usa un repository mock
    final sl = GetIt.instance;
    if (sl.isRegistered<SearchCubit>()) sl.unregister<SearchCubit>();
    sl.registerFactory<SearchCubit>(
      () => SearchCubit(
        repository: mockRepository,
        logger: Logger(level: Level.off),
      ),
    );

    when(() => mockRepository.searchCities(any())).thenAnswer((_) async => []);
  });

  tearDown(() {
    favoritesCubit.close();
    GetIt.instance.reset();
  });

  group('WeatherPage', () {
    testWidgets('mostra CircularProgressIndicator in stato WeatherInitial', (
      tester,
    ) async {
      when(() => mockBloc.state).thenReturn(const WeatherInitial());
      when(() => mockBloc.stream).thenAnswer(
        (_) => Stream.value(const WeatherInitial()),
      );

      await tester.pumpWidget(_buildTestApp(mockBloc, favoritesCubit));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('mostra CircularProgressIndicator in WeatherLoading senza dati', (
      tester,
    ) async {
      when(() => mockBloc.state).thenReturn(const WeatherLoading());
      when(() => mockBloc.stream).thenAnswer(
        (_) => Stream.value(const WeatherLoading()),
      );

      await tester.pumpWidget(_buildTestApp(mockBloc, favoritesCubit));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('mostra nome città e temperatura in WeatherLoaded', (
      tester,
    ) async {
      final loadedState = WeatherLoaded(
        weather: kWeather,
        forecast: [kForecastDay],
        source: WeatherSource.gps,
      );
      when(() => mockBloc.state).thenReturn(loadedState);
      when(() => mockBloc.stream).thenAnswer((_) => Stream.value(loadedState));

      await tester.pumpWidget(_buildTestApp(mockBloc, favoritesCubit));
      await tester.pump();

      expect(find.text('Roma'), findsOneWidget);
      expect(find.text('21°'), findsOneWidget); // 20.5.round() = 21
    });

    testWidgets('mostra icona cloud_off e pulsante Riprova in WeatherError', (
      tester,
    ) async {
      const errorState = WeatherError(failure: NetworkFailure());
      when(() => mockBloc.state).thenReturn(errorState);
      when(() => mockBloc.stream).thenAnswer((_) => Stream.value(errorState));

      await tester.pumpWidget(_buildTestApp(mockBloc, favoritesCubit));
      await tester.pump();

      expect(find.byIcon(Icons.cloud_off), findsOneWidget);
      expect(find.text('Riprova'), findsOneWidget);
    });

    testWidgets('pulsante Riprova dispatcha WeatherFetchByLocationRequested', (
      tester,
    ) async {
      const errorState = WeatherError(failure: NetworkFailure());
      when(() => mockBloc.state).thenReturn(errorState);
      when(() => mockBloc.stream).thenAnswer((_) => Stream.value(errorState));

      await tester.pumpWidget(_buildTestApp(mockBloc, favoritesCubit));
      await tester.pump();

      await tester.tap(find.text('Riprova'));

      verify(
        () => mockBloc.add(const WeatherFetchByLocationRequested()),
      ).called(1);
    });

    testWidgets('mostra dati stale in WeatherError con previousWeather', (
      tester,
    ) async {
      final errorWithStale = WeatherError(
        failure: const ServerFailure('Città non trovata', statusCode: 404),
        previousWeather: kWeather,
        previousForecast: [kForecastDay],
      );

      final controller = StreamController<WeatherState>.broadcast();
      when(() => mockBloc.state).thenReturn(const WeatherInitial());
      when(() => mockBloc.stream).thenAnswer((_) => controller.stream);

      await tester.pumpWidget(_buildTestApp(mockBloc, favoritesCubit));

      controller.add(errorWithStale);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verifica che i dati stale siano visibili (nome città)
      expect(find.text('Roma'), findsOneWidget);
      await controller.close();
    });
  });
}
