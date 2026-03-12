import 'package:shared_preferences/shared_preferences.dart';

abstract class LocalStorageService {
  Future<void> saveLastCityName(String cityName);
  Future<String?> getLastCityName();
  Future<void> saveLastSource(String source);
  Future<String?> getLastSource();
  Future<void> saveFavorites(List<String> cities);
  Future<List<String>> getFavorites();
}

class LocalStorageServiceImpl implements LocalStorageService {
  static const _keyLastCity = 'last_city';
  static const _keyLastSource = 'last_source';
  static const _keyFavorites = 'favorites';

  final SharedPreferences _prefs;

  LocalStorageServiceImpl(this._prefs);

  @override
  Future<void> saveLastCityName(String cityName) =>
      _prefs.setString(_keyLastCity, cityName);

  @override
  Future<String?> getLastCityName() async => _prefs.getString(_keyLastCity);

  @override
  Future<void> saveLastSource(String source) =>
      _prefs.setString(_keyLastSource, source);

  @override
  Future<String?> getLastSource() async => _prefs.getString(_keyLastSource);

  @override
  Future<void> saveFavorites(List<String> cities) =>
      _prefs.setStringList(_keyFavorites, cities);

  @override
  Future<List<String>> getFavorites() async =>
      _prefs.getStringList(_keyFavorites) ?? [];
}
