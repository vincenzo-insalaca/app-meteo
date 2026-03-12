import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/favorites_repository.dart';

part 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  final FavoritesRepository _repository;

  FavoritesCubit(this._repository) : super(const FavoritesState());

  Future<void> load() async {
    final cities = await _repository.getFavorites();
    emit(FavoritesState(cities: cities));
  }

  Future<void> toggleFavorite(String cityName) async {
    if (state.cities.contains(cityName)) {
      await _repository.removeFavorite(cityName);
    } else {
      await _repository.addFavorite(cityName);
    }
    await load();
  }

  bool isFavorite(String cityName) => state.cities.contains(cityName);
}
