import 'package:go_router/go_router.dart';

import '../../presentation/pages/favorites/favorites_page.dart';
import '../../presentation/pages/weather/weather_page.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const WeatherPage(),
      ),
      GoRoute(
        path: '/favorites',
        builder: (context, state) => const FavoritesPage(),
      ),
    ],
  );
}
