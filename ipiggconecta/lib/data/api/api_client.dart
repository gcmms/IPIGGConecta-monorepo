import 'package:dio/dio.dart';

import 'api_config.dart';

/// Responsável por expor uma instância configurada do Dio.
class ApiClient {
  ApiClient._internal()
      : _dio = Dio(
          BaseOptions(
            baseUrl: apiBaseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            responseType: ResponseType.json,
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        )..interceptors.add(
            LogInterceptor(
              request: true,
              requestHeader: true,
              requestBody: true,
              responseHeader: false,
              responseBody: true,
              error: true,
            ),
          );

  static final ApiClient _instance = ApiClient._internal();

  factory ApiClient() => _instance;

  final Dio _dio;

  Dio get dio => _dio;
}
