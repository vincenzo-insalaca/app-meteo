import 'package:meteo/data/models/forecast_response_dto.dart';
import 'package:meteo/data/models/weather_response_dto.dart';
import 'package:meteo/domain/entities/city_suggestion.dart';
import 'package:meteo/domain/entities/forecast_day.dart';
import 'package:meteo/domain/entities/weather.dart';

// ─── JSON Fixtures ────────────────────────────────────────────────────────────

const Map<String, dynamic> kWeatherResponseJson = {
  'name': 'Roma',
  'main': {
    'temp': 20.5,
    'feels_like': 19.0,
    'temp_min': 18.0,
    'temp_max': 22.0,
    'humidity': 65,
  },
  'weather': [
    {'main': 'Clear', 'description': 'cielo sereno', 'icon': '01d'},
  ],
  'wind': {'speed': 3.2},
};

final Map<String, dynamic> kForecastResponseJson = {
  'list': List.generate(
    10,
    (i) => {
      'dt': 1700000000 + (i * 10800),
      'main': {
        'temp': 20.0 + i,
        'feels_like': 19.0,
        'temp_min': 18.0,
        'temp_max': 22.0,
        'humidity': 60,
      },
      'weather': [
        {'main': 'Clear', 'description': 'cielo sereno', 'icon': '01d'},
      ],
    },
  ),
};

const List<Map<String, dynamic>> kGeoResponseJson = [
  {
    'name': 'Roma',
    'country': 'IT',
    'state': 'Lazio',
    'lat': 41.9,
    'lon': 12.5,
  },
  {'name': 'Roma', 'country': 'US', 'state': 'Texas', 'lat': 30.5, 'lon': -97.0},
];

// ─── DTO Fixtures ─────────────────────────────────────────────────────────────

final WeatherResponseDto kWeatherResponseDto =
    WeatherResponseDto.fromJson(kWeatherResponseJson);

final ForecastResponseDto kForecastResponseDto =
    ForecastResponseDto.fromJson(kForecastResponseJson);

// ─── Domain Entity Fixtures ───────────────────────────────────────────────────

const Weather kWeather = Weather(
  cityName: 'Roma',
  temperature: 20.5,
  feelsLike: 19.0,
  tempMin: 18.0,
  tempMax: 22.0,
  humidity: 65,
  windSpeedMs: 3.2,
  condition: 'Clear',
  conditionDescription: 'cielo sereno',
  iconCode: '01d',
);

final ForecastDay kForecastDay = ForecastDay(
  date: DateTime.fromMillisecondsSinceEpoch(1700000000 * 1000),
  temperature: 20.0,
  condition: 'Clear',
  iconCode: '01d',
);

const CitySuggestion kCitySuggestion = CitySuggestion(
  name: 'Roma',
  country: 'IT',
  state: 'Lazio',
  lat: 41.9,
  lon: 12.5,
);
