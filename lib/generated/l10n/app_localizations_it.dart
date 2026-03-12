// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Meteo';

  @override
  String get searchHint => 'Cerca città...';

  @override
  String get clearSearch => 'Cancella ricerca';

  @override
  String get locationButton => 'Usa posizione GPS';

  @override
  String get favoritesButton => 'Preferiti';

  @override
  String get refreshing => 'Aggiornamento in corso...';

  @override
  String get today => 'Oggi';

  @override
  String get feelsLike => 'Percepita';

  @override
  String get humidity => 'Umidità';

  @override
  String get wind => 'Vento';

  @override
  String windUnit(String speed) {
    return '$speed km/h';
  }

  @override
  String humidityValue(int value) {
    return '$value%';
  }

  @override
  String temperatureDegree(int temp) {
    return '$temp°';
  }

  @override
  String minMax(int max, int min) {
    return 'Max: $max°  Min: $min°';
  }

  @override
  String get noConnection => 'Nessuna connessione internet';

  @override
  String get cityNotFound => 'Città non trovata';

  @override
  String get invalidApiKey => 'Chiave API non valida';

  @override
  String get unknownError => 'Errore imprevisto';

  @override
  String get retry => 'Riprova';

  @override
  String get locationSemantic => 'Posizione';

  @override
  String get favoritesTitle => 'Preferiti';

  @override
  String get noFavorites => 'Nessuna città salvata';

  @override
  String get noFavoritesHint =>
      'Cerca una città e tocca la stella per salvarla';

  @override
  String get addToFavorites => 'Aggiungi ai preferiti';

  @override
  String get removeFromFavorites => 'Rimuovi dai preferiti';

  @override
  String get severeWeatherTitle => 'Allerta meteo';

  @override
  String severeWeatherBody(String condition, String city) {
    return 'Attenzione: $condition previsto a $city';
  }

  @override
  String get dailySummaryTitle => 'Previsioni del giorno';

  @override
  String dailySummaryBody(String city, int temp, String condition) {
    return '$city: $temp°, $condition';
  }
}
