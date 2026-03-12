import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/error/failures.dart';
import '../../../core/extensions/build_context_extensions.dart';
import '../../../domain/entities/forecast_day.dart';
import '../../../domain/entities/weather.dart';
import '../../blocs/favorites/favorites_cubit.dart';
import '../../blocs/search/search_cubit.dart';
import '../../blocs/weather/weather_bloc.dart';
import 'widgets/current_weather_card.dart';
import 'widgets/forecast_strip.dart';
import 'widgets/search_bar_widget.dart';
import 'widgets/weather_background.dart';
import 'widgets/weather_details_row.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<WeatherBloc>().state is WeatherInitial) {
        context.read<WeatherBloc>().add(const WeatherInitializeRequested());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SearchCubit>(
      create: (_) => sl<SearchCubit>(),
      child: BlocConsumer<WeatherBloc, WeatherState>(
        listener: (context, state) {
          if (state is WeatherError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_mapFailureToMessage(context, state.failure)),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          final condition = switch (state) {
            WeatherLoaded(:final weather) => weather.condition,
            WeatherLoading(:final previousWeather) => previousWeather?.condition,
            WeatherError(:final previousWeather) => previousWeather?.condition,
            _ => null,
          };

          return Scaffold(
            body: WeatherBackground(
              condition: condition,
              child: SafeArea(
                child: Column(
                  children: [
                    _TopBar(state: state),
                    Expanded(child: _buildContent(context, state)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, WeatherState state) {
    return switch (state) {
      WeatherInitial() => const _LoadingView(),
      WeatherLoading(previousWeather: null) => const _LoadingView(),
      WeatherLoading(:final previousWeather, :final previousForecast) =>
        _WeatherContent(
          weather: previousWeather!,
          forecast: previousForecast ?? const [],
          isRefreshing: true,
        ),
      WeatherLoaded(:final weather, :final forecast) => _WeatherContent(
        weather: weather,
        forecast: forecast,
        isRefreshing: false,
      ),
      WeatherError(previousWeather: null, :final failure) =>
        _ErrorView(failure: failure),
      WeatherError(:final previousWeather, :final previousForecast) =>
        _WeatherContent(
          weather: previousWeather!,
          forecast: previousForecast ?? const [],
          isRefreshing: false,
        ),
    };
  }

  String _mapFailureToMessage(BuildContext context, Failure failure) =>
      switch (failure) {
        NetworkFailure() => context.l10n.noConnection,
        ServerFailure(statusCode: 404) => context.l10n.cityNotFound,
        ServerFailure(statusCode: 401) => context.l10n.invalidApiKey,
        ServerFailure(:final message) => message,
        LocationFailure(:final message) => message,
        UnknownFailure() => context.l10n.unknownError,
      };
}

// ─── Top bar: search + GPS + favorites ───────────────────────────────────────

class _TopBar extends StatelessWidget {
  final WeatherState state;

  const _TopBar({required this.state});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: SearchBarWidget()),
        Tooltip(
          message: context.l10n.locationButton,
          child: IconButton(
            icon: const Icon(Icons.my_location, color: Colors.white70),
            onPressed: () => context
                .read<WeatherBloc>()
                .add(const WeatherFetchByLocationRequested()),
          ),
        ),
        Tooltip(
          message: context.l10n.favoritesButton,
          child: IconButton(
            icon: const Icon(Icons.star_border, color: Colors.white70),
            onPressed: () => context.push('/favorites'),
          ),
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}

// ─── Sub-widget: Loading ──────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: Colors.white),
    );
  }
}

// ─── Sub-widget: Error senza dati precedenti ──────────────────────────────────

class _ErrorView extends StatelessWidget {
  final Failure failure;

  const _ErrorView({required this.failure});

  @override
  Widget build(BuildContext context) {
    final message = switch (failure) {
      NetworkFailure() => context.l10n.noConnection,
      ServerFailure(statusCode: 404) => context.l10n.cityNotFound,
      ServerFailure(statusCode: 401) => context.l10n.invalidApiKey,
      ServerFailure(:final message) => message,
      LocationFailure(:final message) => message,
      UnknownFailure() => context.l10n.unknownError,
    };

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off, color: Colors.white54, size: 64),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context
                .read<WeatherBloc>()
                .add(const WeatherFetchByLocationRequested()),
            icon: const Icon(Icons.refresh),
            label: Text(context.l10n.retry),
          ),
        ],
      ),
    );
  }
}

// ─── Sub-widget: Contenuto meteo (loaded o stale) ────────────────────────────

class _WeatherContent extends StatelessWidget {
  final Weather weather;
  final List<ForecastDay> forecast;
  final bool isRefreshing;

  const _WeatherContent({
    required this.weather,
    required this.forecast,
    required this.isRefreshing,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<WeatherBloc>().add(const WeatherRefreshRequested());
        await context
            .read<WeatherBloc>()
            .stream
            .firstWhere((s) => s is WeatherLoaded || s is WeatherError)
            .timeout(const Duration(seconds: 15));
      },
      color: Colors.white,
      backgroundColor: Colors.white.withValues(alpha: 0.2),
      child: Stack(
        children: [
          SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 20),
                CurrentWeatherCard(weather: weather),
                const SizedBox(height: 30),
                WeatherDetailsRow(weather: weather),
                const SizedBox(height: 40),
                ForecastStrip(forecast: forecast),
                const SizedBox(height: 20),
              ],
            ),
          ),
          // Pulsante stella per i preferiti
          Positioned(
            top: 8,
            right: 16,
            child: BlocBuilder<FavoritesCubit, FavoritesState>(
              builder: (context, favState) {
                final isFav = favState.cities.contains(weather.cityName);
                return Tooltip(
                  message: isFav
                      ? context.l10n.removeFromFavorites
                      : context.l10n.addToFavorites,
                  child: IconButton(
                    icon: Icon(
                      isFav ? Icons.star : Icons.star_border,
                      color: isFav ? Colors.amber : Colors.white70,
                    ),
                    onPressed: () => context
                        .read<FavoritesCubit>()
                        .toggleFavorite(weather.cityName),
                  ),
                );
              },
            ),
          ),
          if (isRefreshing)
            const Positioned.fill(
              child: IgnorePointer(
                child: ColoredBox(
                  color: Colors.black12,
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.white70),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
