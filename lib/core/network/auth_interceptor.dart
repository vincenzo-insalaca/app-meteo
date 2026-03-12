import 'package:dio/dio.dart';

import '../constants/api_constants.dart';

/// Inietta automaticamente `appid`, `units` e `lang` su ogni richiesta.
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    options.queryParameters.addAll({
      'appid': ApiConstants.owmApiKey,
      'units': ApiConstants.units,
      'lang': ApiConstants.lang,
    });
    handler.next(options);
  }
}
