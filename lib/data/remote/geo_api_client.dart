import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/geo_location_dto.dart';

part 'geo_api_client.g.dart';

@RestApi()
abstract class GeoApiClient {
  factory GeoApiClient(Dio dio, {String? baseUrl}) = _GeoApiClient;

  @GET('/direct')
  Future<List<GeoLocationDto>> searchCities(
    @Query('q') String query,
    @Query('limit') int limit,
  );
}
