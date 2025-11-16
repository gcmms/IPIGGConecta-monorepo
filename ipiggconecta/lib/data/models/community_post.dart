class CommunityPost {
  const CommunityPost({
    required this.id,
    required this.userId,
    required this.authorName,
    required this.content,
    required this.createdAt,
    required this.likesCount,
    required this.commentsCount,
    required this.likedByUser,
  });

  final int id;
  final int userId;
  final String authorName;
  final String content;
  final DateTime createdAt;
  final int likesCount;
  final int commentsCount;
  final bool likedByUser;

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    final createdRaw = json['created_at']?.toString() ?? '';

    return CommunityPost(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      userId: int.tryParse(json['user_id']?.toString() ?? '') ?? 0,
      authorName: json['author_name']?.toString() ?? 'Usuário',
      content: json['content']?.toString() ?? '',
      createdAt: DateTime.tryParse(createdRaw) ?? DateTime.now(),
      likesCount: int.tryParse(json['likes_count']?.toString() ?? '') ?? 0,
      commentsCount: int.tryParse(json['comments_count']?.toString() ?? '') ?? 0,
      likedByUser: (json['liked_by_user']?.toString() ?? '0') == '1',
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

  CommunityPost copyWith({
    int? likesCount,
    int? commentsCount,
    bool? likedByUser,
  }) {
    return CommunityPost(
      id: id,
      userId: userId,
      authorName: authorName,
      content: content,
      createdAt: createdAt,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      likedByUser: likedByUser ?? this.likedByUser,
    );
  }
}
