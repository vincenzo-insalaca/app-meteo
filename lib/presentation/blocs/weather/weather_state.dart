part of 'weather_bloc.dart';

/// Indica se i dati vengono da GPS o da ricerca manuale.
enum WeatherSource { gps, search }

sealed class WeatherState extends Equatable {
  const WeatherState();

  @override
  List<Object?> get props => [];
}

/// Stato iniziale prima di qualsiasi fetch.
final class WeatherInitial extends WeatherState {
  const WeatherInitial();
}

/// Fetch in corso. Può contenere dati precedenti per mostrare l'UI già carica.
final class WeatherLoading extends WeatherState {
  final Weather? previousWeather;
  final List<ForecastDay>? previousForecast;

  const WeatherLoading({this.previousWeather, this.previousForecast});

  @override
  List<Object?> get props => [previousWeather, previousForecast];
}

/// Dati caricati con successo.
final class WeatherLoaded extends WeatherState {
  final Weather weather;
  final List<ForecastDay> forecast;
  final WeatherSource source;

  const WeatherLoaded({
    required this.weather,
    required this.forecast,
    required this.source,
  });

  @override
  List<Object?> get props => [weather, forecast, source];
}

/// Errore. Può contenere dati precedenti per mostrare l'UI stale.
final class WeatherError extends WeatherState {
  final Failure failure;
  final Weather? previousWeather;
  final List<ForecastDay>? previousForecast;

  const WeatherError({
    required this.failure,
    this.previousWeather,
    this.previousForecast,
  });

  @override
  List<Object?> get props => [failure, previousWeather, previousForecast];
}
