import 'package:json_annotation/json_annotation.dart';

part 'weather_response_dto.g.dart';

@JsonSerializable(createToJson: false)
class WeatherResponseDto {
  final String name;
  final MainDto main;
  final List<WeatherConditionDto> weather;
  final WindDto wind;

  const WeatherResponseDto({
    required this.name,
    required this.main,
    required this.weather,
    required this.wind,
  });

  factory WeatherResponseDto.fromJson(Map<String, dynamic> json) =>
      _$WeatherResponseDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class MainDto {
  final double temp;

  @JsonKey(name: 'feels_like')
  final double feelsLike;

  @JsonKey(name: 'temp_min')
  final double tempMin;

  @JsonKey(name: 'temp_max')
  final double tempMax;

  final int humidity;

  const MainDto({
    required this.temp,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.humidity,
  });

  factory MainDto.fromJson(Map<String, dynamic> json) =>
      _$MainDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class WeatherConditionDto {
  final String main;
  final String description;
  final String icon;

  const WeatherConditionDto({
    required this.main,
    required this.description,
    required this.icon,
  });

  factory WeatherConditionDto.fromJson(Map<String, dynamic> json) =>
      _$WeatherConditionDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class WindDto {
  final double speed;

  const WindDto({required this.speed});

  factory WindDto.fromJson(Map<String, dynamic> json) =>
      _$WindDtoFromJson(json);
}
