import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../constants/api_constants.dart';
import 'auth_interceptor.dart';

class DioClient {
  DioClient._();

  static Dio createWeatherDio(AuthInterceptor authInterceptor) => _buildDio(
    baseUrl: ApiConstants.baseUrlWeather,
    authInterceptor: authInterceptor,
  );

  static Dio createGeoDio(AuthInterceptor authInterceptor) => _buildDio(
    baseUrl: ApiConstants.baseUrlGeo,
    authInterceptor: authInterceptor,
  );

  static Dio _buildDio({
    required String baseUrl,
    required AuthInterceptor authInterceptor,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
      ),
    );

    dio.interceptors.addAll([
      authInterceptor,
      RetryInterceptor(
        dio: dio,
        retries: 3,
        retryDelays: const [
          Duration(seconds: 1),
          Duration(seconds: 2),
          Duration(seconds: 3),
        ],
      ),
      if (kDebugMode)
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          compact: false,
          error: true,
          request: true,
        ),
    ]);

    return dio;
  }
}
