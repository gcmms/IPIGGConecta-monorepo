import 'package:dio/dio.dart';

import '../api/api_client.dart';
import '../models/mural_model.dart';

class MuralService {
  const MuralService();

  Future<List<MuralModel>> getMural() async {
    try {
      final response = await ApiClient().dio.get<List<dynamic>>('/mural');
      final data = response.data;

      if (data is List) {
        return data
            .map((item) => MuralModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      throw Exception('Resposta inválida do servidor.');
    } on DioException catch (error) {
      final response = error.response;
      final data = response?.data;
      final message = _extractMessage(data) ??
          error.message ??
          'Erro ao carregar o mural.';

      throw Exception(message);
    }
  }

  Future<MuralModel> createMural({
    required String title,
    required String subtitle,
    required DateTime publishDate,
    String? link,
    required String token,
  }) async {
    final dio = ApiClient().dio;
    final formattedDate =
        '${publishDate.year.toString().padLeft(4, '0')}-${publishDate.month.toString().padLeft(2, '0')}-${publishDate.day.toString().padLeft(2, '0')}';

    try {
      final response = await dio.post<Map<String, dynamic>>(
        '/mural',
        data: {
          'title': title,
          'subtitle': subtitle,
          'publish_date': formattedDate,
          'link': (link?.trim().isEmpty ?? true) ? null : link!.trim(),
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      final item = response.data?['item'];
      if (item is Map<String, dynamic>) {
        return MuralModel.fromJson(item);
      }

      throw Exception('Resposta inválida do servidor.');
    } on DioException catch (error) {
      final message = _extractMessage(error.response?.data) ??
          error.message ??
          'Erro ao criar aviso.';
      throw Exception(message);
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
