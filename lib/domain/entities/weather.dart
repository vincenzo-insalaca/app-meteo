import 'package:equatable/equatable.dart';

/// Rappresenta le condizioni meteo attuali di una città.
class Weather extends Equatable {
  final String cityName;
  final double temperature;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final int humidity;

  /// Velocità del vento in m/s (la conversione a km/h avviene nel layer UI).
  final double windSpeedMs;
  final String condition;
  final String conditionDescription;
  final String iconCode;

  const Weather({
    required this.cityName,
    required this.temperature,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.humidity,
    required this.windSpeedMs,
    required this.condition,
    required this.conditionDescription,
    required this.iconCode,
  });

  @override
  List<Object?> get props => [
    cityName,
    temperature,
    feelsLike,
    tempMin,
    tempMax,
    humidity,
    windSpeedMs,
    condition,
    conditionDescription,
    iconCode,
  ];
}
