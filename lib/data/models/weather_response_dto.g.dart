// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeatherResponseDto _$WeatherResponseDtoFromJson(Map<String, dynamic> json) =>
    WeatherResponseDto(
      name: json['name'] as String,
      main: MainDto.fromJson(json['main'] as Map<String, dynamic>),
      weather: (json['weather'] as List<dynamic>)
          .map((e) => WeatherConditionDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      wind: WindDto.fromJson(json['wind'] as Map<String, dynamic>),
    );

MainDto _$MainDtoFromJson(Map<String, dynamic> json) => MainDto(
  temp: (json['temp'] as num).toDouble(),
  feelsLike: (json['feels_like'] as num).toDouble(),
  tempMin: (json['temp_min'] as num).toDouble(),
  tempMax: (json['temp_max'] as num).toDouble(),
  humidity: (json['humidity'] as num).toInt(),
);

WeatherConditionDto _$WeatherConditionDtoFromJson(Map<String, dynamic> json) =>
    WeatherConditionDto(
      main: json['main'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
    );

WindDto _$WindDtoFromJson(Map<String, dynamic> json) =>
    WindDto(speed: (json['speed'] as num).toDouble());
