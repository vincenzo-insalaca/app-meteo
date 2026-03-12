import '../entities/weather.dart';
import '../entities/forecast_day.dart';
import '../entities/city_suggestion.dart';

/// Interfaccia del repository meteo. Il data layer ne fornisce l'implementazione.
abstract class WeatherRepository {
  /// Recupera meteo attuale e previsioni a 5 giorni per [cityName].
  /// Lancia un [Failure] in caso di errore.
  Future<(Weather, List<ForecastDay>)> fetchWeatherByCity(String cityName);

  /// Recupera meteo attuale e previsioni a 5 giorni tramite GPS.
  /// Lancia un [Failure] in caso di errore o permesso negato.
  Future<(Weather, List<ForecastDay>)> fetchWeatherByLocation();

  /// Restituisce suggerimenti di città per l'autocompletamento.
  /// Restituisce lista vuota se [query] è troppo corta. Non lancia mai eccezioni.
  Future<List<CitySuggestion>> searchCities(String query);
}
