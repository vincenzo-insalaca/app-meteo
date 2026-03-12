class ApiConstants {
  ApiConstants._();

  static const String owmApiKey = String.fromEnvironment('OWM_API_KEY');
  static const String baseUrlWeather = 'https://api.openweathermap.org/data/2.5';
  static const String baseUrlGeo = 'https://api.openweathermap.org/geo/1.0';
  static const String units = 'metric';
  static const String lang = 'it';
  static const int citySuggestionsLimit = 5;
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
}
