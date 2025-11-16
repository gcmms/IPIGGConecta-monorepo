class MuralModel {
  const MuralModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.publishDate,
    this.link,
  });

  final int id;
  final String title;
  final String subtitle;
  final DateTime publishDate;
  final String? link;

  factory MuralModel.fromJson(Map<String, dynamic> json) {
    final publishDateRaw = json['publish_date']?.toString() ?? '';
    return MuralModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      publishDate: DateTime.tryParse(publishDateRaw) ?? DateTime.now(),
      link: (json['link']?.toString().isEmpty ?? true)
          ? null
          : json['link']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'publish_date':
            '${publishDate.year.toString().padLeft(4, '0')}-${publishDate.month.toString().padLeft(2, '0')}-${publishDate.day.toString().padLeft(2, '0')}',
        'link': link,
      };

  String get formattedDate {
    final day = publishDate.day.toString().padLeft(2, '0');
    final month = publishDate.month.toString().padLeft(2, '0');
    final year = publishDate.year.toString();
    return '$day/$month/$year';
  }
}
