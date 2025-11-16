class CommunityComment {
  const CommunityComment({
    required this.id,
    required this.postId,
    required this.authorName,
    required this.comment,
    required this.createdAt,
  });

  final int id;
  final int postId;
  final String authorName;
  final String comment;
  final DateTime createdAt;

  factory CommunityComment.fromJson(Map<String, dynamic> json) {
    final createdRaw = json['created_at']?.toString() ?? '';
    return CommunityComment(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      postId: int.tryParse(json['post_id']?.toString() ?? '') ?? 0,
      authorName: json['author_name']?.toString() ?? 'Usuário',
      comment: json['comment']?.toString() ?? '',
      createdAt: DateTime.tryParse(createdRaw) ?? DateTime.now(),
    );
  }

  String get relativeTime {
    final difference = DateTime.now().difference(createdAt);
    if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes.clamp(1, 59);
      return '${minutes}m';
    }
    if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '${hours}h';
    }
    final days = difference.inDays;
    return '${days}d';
  }
}
