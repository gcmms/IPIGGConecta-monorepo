import 'package:dio/dio.dart';

import '../api/api_client.dart';
import '../models/user_profile.dart';

class UserService {
  UserService({Dio? dio}) : _dio = dio ?? ApiClient().dio;

  final Dio _dio;

  Future<UserProfile> fetchCurrentUser(String token) async {
    if (token.isEmpty) {
      throw Exception('Faça login novamente.');
    }

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/auth/me',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      final data = response.data;
      final user = data?['user'];
      if (user is Map<String, dynamic>) {
        return UserProfile.fromJson(user);
      }
    } on DioException catch (error) {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        final message = data['message']?.toString();
        if (message != null && message.isNotEmpty) {
          throw Exception(message);
        }
      }
      throw Exception('Erro ao carregar perfil.');
    }

    throw Exception('Resposta inválida da API.');
  }

  Future<List<UserProfile>> fetchMembers(String token) async {
    if (token.isEmpty) {
      throw Exception('Sessão expirada.');
    }

    try {
      final response = await _dio.get<List<dynamic>>(
        '/users',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      final data = response.data;
      if (data is List) {
        return data
            .map((item) => UserProfile.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } on DioException catch (error) {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        final message = data['message']?.toString();
        if (message != null && message.isNotEmpty) {
          throw Exception(message);
        }
      }
      throw Exception('Erro ao listar membros.');
    }

    throw Exception('Resposta inválida da API.');
  }

  Future<UserProfile> updateMemberRole({
    required int userId,
    required String role,
    required String token,
  }) async {
    if (token.isEmpty) {
      throw Exception('Sessão expirada.');
    }

    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/users/$userId/role',
        data: {'role': role},
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      final user = response.data?['user'];
      if (user is Map<String, dynamic>) {
        return UserProfile.fromJson(user);
      }
    } on DioException catch (error) {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        final message = data['message']?.toString();
        if (message != null && message.isNotEmpty) {
          throw Exception(message);
        }
      }
      throw Exception('Erro ao atualizar papel do membro.');
    }

    throw Exception('Resposta inválida da API.');
  }
}
