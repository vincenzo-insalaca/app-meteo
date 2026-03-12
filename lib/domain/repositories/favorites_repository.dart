abstract class FavoritesRepository {
  Future<List<String>> getFavorites();
  Future<void> addFavorite(String cityName);
  Future<void> removeFavorite(String cityName);
  Future<bool> isFavorite(String cityName);
}
