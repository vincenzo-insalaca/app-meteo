import 'package:bloc/bloc.dart';
import 'package:logger/logger.dart';

import '../../../domain/entities/city_suggestion.dart';
import '../../../domain/repositories/weather_repository.dart';

class SearchCubit extends Cubit<void> {
  final WeatherRepository _repository;
  final Logger _logger;

  SearchCubit({
    required WeatherRepository repository,
    required Logger logger,
  })  : _repository = repository,
        _logger = logger,
        super(null);

  /// Restituisce i suggerimenti di città per [query].
  /// Ritorna lista vuota se [query] < 3 caratteri o in caso di errore.
  Future<List<CitySuggestion>> getSuggestions(String query) async {
    if (query.length < 3) return const [];
    try {
      return await _repository.searchCities(query);
    } catch (e) {
      _logger.w('getSuggestions failed: $e');
      return const [];
    }
  }
}
