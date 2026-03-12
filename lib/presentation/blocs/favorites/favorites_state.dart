part of 'favorites_cubit.dart';

class FavoritesState extends Equatable {
  final List<String> cities;

  const FavoritesState({this.cities = const []});

  @override
  List<Object?> get props => [cities];
}
