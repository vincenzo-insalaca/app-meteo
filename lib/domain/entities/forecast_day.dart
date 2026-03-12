import 'package:equatable/equatable.dart';

/// Rappresenta le previsioni meteo per un singolo giorno.
class ForecastDay extends Equatable {
  final DateTime date;
  final double temperature;
  final String condition;
  final String iconCode;

  const ForecastDay({
    required this.date,
    required this.temperature,
    required this.condition,
    required this.iconCode,
  });

  @override
  List<Object?> get props => [date, temperature, condition, iconCode];
}
