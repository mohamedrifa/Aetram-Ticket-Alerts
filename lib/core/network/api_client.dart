import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/environment_config.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: EnvironmentConfig.apiBaseUrl,
      connectTimeout: Duration(
        seconds: EnvironmentConfig.connectTimeoutSeconds,
      ),
      receiveTimeout: Duration(
        seconds: EnvironmentConfig.receiveTimeoutSeconds,
      ),
      sendTimeout: Duration(seconds: EnvironmentConfig.connectTimeoutSeconds),
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );
  if (kDebugMode)
    dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
  return dio;
});
