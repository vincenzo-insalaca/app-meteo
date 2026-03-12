import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/forecast_response_dto.dart';
import '../models/weather_response_dto.dart';

part 'weather_api_client.g.dart';

@RestApi()
abstract class WeatherApiClient {
  factory WeatherApiClient(Dio dio, {String? baseUrl}) = _WeatherApiClient;

  @GET('/weather')
  Future<WeatherResponseDto> getCurrentWeatherByCity(
    @Query('q') String city,
  );

  @GET('/weather')
  Future<WeatherResponseDto> getCurrentWeatherByCoords(
    @Query('lat') double lat,
    @Query('lon') double lon,
  );

  @GET('/forecast')
  Future<ForecastResponseDto> getForecastByCity(
    @Query('q') String city,
  );

  @GET('/forecast')
  Future<ForecastResponseDto> getForecastByCoords(
    @Query('lat') double lat,
    @Query('lon') double lon,
  );
}
