import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/auth_interceptor.dart';
import '../network/connectivity_service.dart';
import '../network/dio_client.dart';
import '../services/local_storage_service.dart';
import '../services/notification_service.dart';
import '../../data/remote/geo_api_client.dart';
import '../../data/remote/weather_api_client.dart';
import '../../data/repositories/favorites_repository_impl.dart';
import '../../data/repositories/weather_repository_impl.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../../domain/repositories/weather_repository.dart';
import '../../presentation/blocs/favorites/favorites_cubit.dart';
import '../../presentation/blocs/search/search_cubit.dart';
import '../../presentation/blocs/weather/weather_bloc.dart';

final GetIt sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  // ─── Utils ──────────────────────────────────────────────────────────────────
  sl.registerSingleton<Logger>(Logger());

  // ─── Persistence ─────────────────────────────────────────────────────────────
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<LocalStorageService>(LocalStorageServiceImpl(prefs));

  // ─── Notifications ───────────────────────────────────────────────────────────
  final notificationService = NotificationServiceImpl();
  await notificationService.initialize();
  sl.registerSingleton<NotificationService>(notificationService);

  // ─── Network ────────────────────────────────────────────────────────────────
  sl.registerSingleton<ConnectivityService>(ConnectivityServiceImpl());
  sl.registerSingleton<AuthInterceptor>(AuthInterceptor());

  sl.registerSingleton(
    DioClient.createWeatherDio(sl<AuthInterceptor>(), sl<Logger>()),
    instanceName: 'weatherDio',
  );
  sl.registerSingleton(
    DioClient.createGeoDio(sl<AuthInterceptor>(), sl<Logger>()),
    instanceName: 'geoDio',
  );

  // ─── API Clients ─────────────────────────────────────────────────────────────
  sl.registerSingleton<WeatherApiClient>(
    WeatherApiClient(sl(instanceName: 'weatherDio')),
  );
  sl.registerSingleton<GeoApiClient>(
    GeoApiClient(sl(instanceName: 'geoDio')),
  );

  // ─── Repositories ────────────────────────────────────────────────────────────
  sl.registerSingleton<WeatherRepository>(
    WeatherRepositoryImpl(
      weatherApiClient: sl<WeatherApiClient>(),
      geoApiClient: sl<GeoApiClient>(),
      logger: sl<Logger>(),
    ),
  );
  sl.registerSingleton<FavoritesRepository>(
    FavoritesRepositoryImpl(sl<LocalStorageService>()),
  );

  // ─── BLoC / Cubit ────────────────────────────────────────────────────────────
  sl.registerSingleton<WeatherBloc>(
    WeatherBloc(
      repository: sl<WeatherRepository>(),
      connectivity: sl<ConnectivityService>(),
      storage: sl<LocalStorageService>(),
      notifications: sl<NotificationService>(),
      logger: sl<Logger>(),
    ),
  );

  sl.registerSingleton<FavoritesCubit>(
    FavoritesCubit(sl<FavoritesRepository>())..load(),
  );

  // Factory: nuova istanza per ogni WeatherPage montata
  sl.registerFactory<SearchCubit>(
    () => SearchCubit(
      repository: sl<WeatherRepository>(),
      logger: sl<Logger>(),
    ),
  );
}
