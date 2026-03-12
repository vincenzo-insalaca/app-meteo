import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import '../constants/api_constants.dart';
import 'auth_interceptor.dart';

class DioClient {
  DioClient._();

  static Dio createWeatherDio(
    AuthInterceptor authInterceptor,
    Logger logger,
  ) => _buildDio(
    baseUrl: ApiConstants.baseUrlWeather,
    authInterceptor: authInterceptor,
    logger: logger,
  );

  static Dio createGeoDio(
    AuthInterceptor authInterceptor,
    Logger logger,
  ) => _buildDio(
    baseUrl: ApiConstants.baseUrlGeo,
    authInterceptor: authInterceptor,
    logger: logger,
  );

  static Dio _buildDio({
    required String baseUrl,
    required AuthInterceptor authInterceptor,
    required Logger logger,
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
        LogInterceptor(
          logPrint: (log) => logger.d('$log'),
          requestBody: false,
          responseBody: false,
        ),
    ]);

    return dio;
  }
}
