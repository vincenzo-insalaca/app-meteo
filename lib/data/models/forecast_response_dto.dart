import 'package:json_annotation/json_annotation.dart';

import 'weather_response_dto.dart';

part 'forecast_response_dto.g.dart';

@JsonSerializable(createToJson: false)
class ForecastResponseDto {
  final List<ForecastItemDto> list;

  const ForecastResponseDto({required this.list});

  factory ForecastResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ForecastResponseDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class ForecastItemDto {
  final int dt;
  final MainDto main;
  final List<WeatherConditionDto> weather;

  const ForecastItemDto({
    required this.dt,
    required this.main,
    required this.weather,
  });

  DateTime get dateTime => DateTime.fromMillisecondsSinceEpoch(dt * 1000);

  factory ForecastItemDto.fromJson(Map<String, dynamic> json) =>
      _$ForecastItemDtoFromJson(json);
}
