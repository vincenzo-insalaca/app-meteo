// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forecast_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ForecastResponseDto _$ForecastResponseDtoFromJson(Map<String, dynamic> json) =>
    ForecastResponseDto(
      list: (json['list'] as List<dynamic>)
          .map((e) => ForecastItemDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

ForecastItemDto _$ForecastItemDtoFromJson(Map<String, dynamic> json) =>
    ForecastItemDto(
      dt: (json['dt'] as num).toInt(),
      main: MainDto.fromJson(json['main'] as Map<String, dynamic>),
      weather: (json['weather'] as List<dynamic>)
          .map((e) => WeatherConditionDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
