import '../../core/services/local_storage_service.dart';
import '../../domain/repositories/favorites_repository.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final LocalStorageService _storage;

  FavoritesRepositoryImpl(this._storage);

  @override
  Future<List<String>> getFavorites() => _storage.getFavorites();

  @override
  Future<void> addFavorite(String cityName) async {
    final current = await _storage.getFavorites();
    if (!current.contains(cityName)) {
      await _storage.saveFavorites([...current, cityName]);
    }
  }

  @override
  Future<void> removeFavorite(String cityName) async {
    final current = await _storage.getFavorites();
    await _storage.saveFavorites(current.where((c) => c != cityName).toList());
  }

  @override
  Future<bool> isFavorite(String cityName) async {
    final current = await _storage.getFavorites();
    return current.contains(cityName);
  }
}
