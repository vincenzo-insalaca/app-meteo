// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Weather';

  @override
  String get searchHint => 'Search city...';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get locationButton => 'Use GPS location';

  @override
  String get favoritesButton => 'Favorites';

  @override
  String get refreshing => 'Refreshing...';

  @override
  String get today => 'Today';

  @override
  String get feelsLike => 'Feels like';

  @override
  String get humidity => 'Humidity';

  @override
  String get wind => 'Wind';

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
  String get noConnection => 'No internet connection';

  @override
  String get cityNotFound => 'City not found';

  @override
  String get invalidApiKey => 'Invalid API key';

  @override
  String get unknownError => 'Unexpected error';

  @override
  String get retry => 'Retry';

  @override
  String get locationSemantic => 'Location';

  @override
  String get favoritesTitle => 'Favorites';

  @override
  String get noFavorites => 'No saved cities';

  @override
  String get noFavoritesHint => 'Search a city and tap the star to save it';

  @override
  String get addToFavorites => 'Add to favorites';

  @override
  String get removeFromFavorites => 'Remove from favorites';

  @override
  String get severeWeatherTitle => 'Weather alert';

  @override
  String severeWeatherBody(String condition, String city) {
    return 'Warning: $condition expected in $city';
  }

  @override
  String get dailySummaryTitle => 'Today\'s forecast';

  @override
  String dailySummaryBody(String city, int temp, String condition) {
    return '$city: $temp°, $condition';
  }
}
