part of 'weather_bloc.dart';

sealed class WeatherEvent extends Equatable {
  const WeatherEvent();

  @override
  List<Object?> get props => [];
}

/// Inizializza ripristinando l'ultima sorgente salvata.
final class WeatherInitializeRequested extends WeatherEvent {
  const WeatherInitializeRequested();
}

/// Richiede il meteo tramite GPS.
final class WeatherFetchByLocationRequested extends WeatherEvent {
  const WeatherFetchByLocationRequested();
}

/// Richiede il meteo per una città specifica.
final class WeatherFetchByCityRequested extends WeatherEvent {
  final String cityName;
  const WeatherFetchByCityRequested(this.cityName);

  @override
  List<Object?> get props => [cityName];
}

/// Aggiorna il meteo per la sorgente corrente (GPS o città).
final class WeatherRefreshRequested extends WeatherEvent {
  const WeatherRefreshRequested();
}
