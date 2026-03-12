// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geo_location_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeoLocationDto _$GeoLocationDtoFromJson(Map<String, dynamic> json) =>
    GeoLocationDto(
      name: json['name'] as String,
      country: json['country'] as String,
      state: json['state'] as String?,
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
    );
