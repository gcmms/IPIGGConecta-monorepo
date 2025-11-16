import 'package:dio/dio.dart';

import 'api/api_client.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'ApiException(statusCode: $statusCode, message: $message)';
}

class AuthApi {
  const AuthApi();

  Dio get _dio => ApiClient().dio;

  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String birthDate,
    required String email,
    String? phone,
    required String password,
  }) {
    return _post(
      '/auth/register',
      {
        'first_name': firstName,
        'last_name': lastName,
        'birth_date': birthDate,
        'email': email,
        'phone': phone,
        'password': password,
      },
    );
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) {
    return _post(
      '/auth/login',
      {
        'email': email,
        'password': password,
      },
    );
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        path,
        data: body,
      );

      final data = response.data;
      if (data == null) {
        return <String, dynamic>{};
      }

      if (data is Map<String, dynamic>) {
        return data;
      }

      throw ApiException('Resposta inesperada da API.');
    } on DioException catch (error) {
      final response = error.response;
      final data = response?.data;
      final message = _extractMessage(data) ??
          error.message ??
          'Erro inesperado ao chamar a API.';

      throw ApiException(
        message,
        statusCode: response?.statusCode,
      );
    }
  }

  String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    }

    return null;
  }
}
