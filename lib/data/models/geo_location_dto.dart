import 'package:json_annotation/json_annotation.dart';

part 'geo_location_dto.g.dart';

@JsonSerializable(createToJson: false)
class GeoLocationDto {
  final String name;
  final String country;
  final String? state;
  final double lat;
  final double lon;

  const GeoLocationDto({
    required this.name,
    required this.country,
    this.state,
    required this.lat,
    required this.lon,
  });

  factory GeoLocationDto.fromJson(Map<String, dynamic> json) =>
      _$GeoLocationDtoFromJson(json);
}
