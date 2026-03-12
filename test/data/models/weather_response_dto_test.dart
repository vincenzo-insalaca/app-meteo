import 'package:flutter_test/flutter_test.dart';
import 'package:meteo/data/models/weather_response_dto.dart';

import '../../helpers/test_data.dart';

void main() {
  group('WeatherResponseDto.fromJson', () {
    test('parses tutti i campi correttamente', () {
      final dto = WeatherResponseDto.fromJson(kWeatherResponseJson);

      expect(dto.name, 'Roma');
      expect(dto.main.temp, 20.5);
      expect(dto.main.feelsLike, 19.0);
      expect(dto.main.tempMin, 18.0);
      expect(dto.main.tempMax, 22.0);
      expect(dto.main.humidity, 65);
      expect(dto.wind.speed, 3.2);
      expect(dto.weather, hasLength(1));
      expect(dto.weather.first.main, 'Clear');
      expect(dto.weather.first.description, 'cielo sereno');
      expect(dto.weather.first.icon, '01d');
    });

    test('lista weather vuota non causa crash', () {
      final json = Map<String, dynamic>.from(kWeatherResponseJson)
        ..['weather'] = <dynamic>[];

      final dto = WeatherResponseDto.fromJson(json);
      expect(dto.weather, isEmpty);
    });
  });

  group('MainDto.fromJson', () {
    test('legge i campi con snake_case via @JsonKey', () {
      final json = {
        'temp': 15.0,
        'feels_like': 14.0,
        'temp_min': 12.0,
        'temp_max': 18.0,
        'humidity': 80,
      };
      final dto = MainDto.fromJson(json);

      expect(dto.feelsLike, 14.0);
      expect(dto.tempMin, 12.0);
      expect(dto.tempMax, 18.0);
    });
  });

  group('WindDto.fromJson', () {
    test('legge speed correttamente', () {
      final dto = WindDto.fromJson({'speed': 5.5});
      expect(dto.speed, 5.5);
    });
  });
}
