import 'dart:convert';

import 'package:http/http.dart' as http;

import '../api/api_config.dart';
import '../models/community_comment.dart';
import '../models/community_post.dart';

class CommunityService {
  const CommunityService();

  Future<List<CommunityPost>> fetchFeed({int? userId}) async {
    final uri = Uri.parse(
      userId == null || userId == 0
          ? '$apiBaseUrl/community'
          : '$apiBaseUrl/community?userId=$userId',
    );

    final response = await http
        .get(uri, headers: const {'Content-Type': 'application/json'})
        .timeout(const Duration(seconds: 15));

    if (response.statusCode >= 400) {
      throw Exception('Não foi possível carregar o feed.');
    }

    final parsed = jsonDecode(response.body);

    if (parsed is List) {
      return parsed
          .map((item) => CommunityPost.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    throw Exception('Resposta inválida do servidor.');
  }

  Future<CommunityPost> createPost({
    required int userId,
    required String content,
  }) async {
    final uri = Uri.parse('$apiBaseUrl/community');
    final response = await http
        .post(
          uri,
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode({'user_id': userId, 'content': content}),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode >= 400) {
      final data = jsonDecode(response.body);
      throw Exception(data['message']?.toString() ?? 'Erro ao publicar.');
    }

    final data = jsonDecode(response.body);
    return CommunityPost.fromJson(data['post'] as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> toggleLike({
    required int postId,
    required int userId,
  }) async {
    final uri = Uri.parse('$apiBaseUrl/community/$postId/like');
    final response = await http
        .post(
          uri,
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode({'user_id': userId}),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode >= 400) {
      final data = jsonDecode(response.body);
      throw Exception(data['message']?.toString() ?? 'Erro ao curtir.');
    }

    final data = jsonDecode(response.body);
    return {
      'likes_count':
          int.tryParse(data['likes_count']?.toString() ?? '') ?? 0,
      'liked': data['liked'] as bool? ?? false,
    };
  }

  Future<List<CommunityComment>> fetchComments(int postId) async {
    final uri = Uri.parse('$apiBaseUrl/community/$postId/comments');
    final response = await http
        .get(uri, headers: const {'Content-Type': 'application/json'})
        .timeout(const Duration(seconds: 15));

    if (response.statusCode >= 400) {
      final data = jsonDecode(response.body);
      throw Exception(data['message']?.toString() ?? 'Erro ao carregar comentários.');
    }

    final parsed = jsonDecode(response.body);
    if (parsed is List) {
      return parsed
          .map((item) => CommunityComment.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return const [];
  }

  Future<List<CommunityComment>> addComment({
    required int postId,
    required int userId,
    required String comment,
  }) async {
    final uri = Uri.parse('$apiBaseUrl/community/$postId/comments');
    final response = await http
        .post(
          uri,
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode({'user_id': userId, 'comment': comment}),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode >= 400) {
      final data = jsonDecode(response.body);
      throw Exception(data['message']?.toString() ?? 'Erro ao comentar.');
    }

    final data = jsonDecode(response.body);
    if (data['comments'] is List) {
      return (data['comments'] as List)
          .map((item) => CommunityComment.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return const [];
  }
}
