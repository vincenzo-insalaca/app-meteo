import 'package:flutter_test/flutter_test.dart';
import 'package:meteo/data/models/geo_location_dto.dart';

import '../../helpers/test_data.dart';

void main() {
  group('GeoLocationDto.fromJson', () {
    test('parsa tutti i campi incluso state', () {
      final dto = GeoLocationDto.fromJson(kGeoResponseJson.first);

      expect(dto.name, 'Roma');
      expect(dto.country, 'IT');
      expect(dto.state, 'Lazio');
      expect(dto.lat, 41.9);
      expect(dto.lon, 12.5);
    });

    test('state nullable: null se assente', () {
      final json = {'name': 'Roma', 'country': 'IT', 'lat': 41.9, 'lon': 12.5};
      final dto = GeoLocationDto.fromJson(json);

      expect(dto.state, isNull);
    });
  });
}
