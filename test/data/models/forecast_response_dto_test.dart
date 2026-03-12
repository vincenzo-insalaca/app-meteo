import 'package:flutter_test/flutter_test.dart';
import 'package:meteo/data/models/forecast_response_dto.dart';

import '../../helpers/test_data.dart';

void main() {
  group('ForecastResponseDto.fromJson', () {
    test('parsa la lista di ForecastItemDto', () {
      final dto = ForecastResponseDto.fromJson(kForecastResponseJson);

      expect(dto.list, hasLength(10));
    });

    test('ForecastItemDto converte dt in DateTime', () {
      final dto = ForecastResponseDto.fromJson(kForecastResponseJson);
      final item = dto.list.first;

      expect(item.dateTime, isA<DateTime>());
      expect(
        item.dateTime,
        DateTime.fromMillisecondsSinceEpoch(item.dt * 1000),
      );
    });

    test('weather list vuota non causa crash', () {
      final jsonWithEmptyWeather = {
        'list': [
          {
            'dt': 1700000000,
            'main': {
              'temp': 20.0,
              'feels_like': 19.0,
              'temp_min': 18.0,
              'temp_max': 22.0,
              'humidity': 60,
            },
            'weather': <dynamic>[],
          },
        ],
      };
      final dto = ForecastResponseDto.fromJson(jsonWithEmptyWeather);

      expect(dto.list.first.weather, isEmpty);
    });
  });
}
