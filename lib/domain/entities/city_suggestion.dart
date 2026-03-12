import 'package:equatable/equatable.dart';

/// Suggerimento di città per l'autocompletamento della ricerca.
class CitySuggestion extends Equatable {
  final String name;
  final String country;
  final String? state;
  final double lat;
  final double lon;

  const CitySuggestion({
    required this.name,
    required this.country,
    this.state,
    required this.lat,
    required this.lon,
  });

  String get displayName {
    final statePart = state != null ? ', $state' : '';
    return '$name$statePart, $country';
  }

  @override
  List<Object?> get props => [name, country, state, lat, lon];
}
