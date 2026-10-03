/// Model data pengumuman pesantren.
class AnnouncementModel {
  final String id;
  final String title;
  final String content;
  final String category; // 'SPP', 'Infak', 'Uang Saku', 'Umum'
  final String
  status; // 'draft', 'scheduled', 'published', 'expired', 'archived'
  final String? bannerUrl;
  final String? attachmentUrl;
  final String authorName;
  final DateTime publishedAt;
  final DateTime createdAt;
  final bool isImportant;

  const AnnouncementModel({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.status,
    this.bannerUrl,
    this.attachmentUrl,
    required this.authorName,
    required this.publishedAt,
    required this.createdAt,
    this.isImportant = false,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Umum',
      status: json['status']?.toString() ?? 'published',
      bannerUrl: json['banner_url']?.toString(),
      attachmentUrl: json['attachment_url']?.toString(),
      authorName: json['author_name']?.toString() ?? 'Admin',
      publishedAt: json['published_at'] != null
          ? DateTime.tryParse(json['published_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isImportant: json['is_important'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'status': status,
      'banner_url': bannerUrl,
      'attachment_url': attachmentUrl,
      'author_name': authorName,
      'published_at': publishedAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'is_important': isImportant,
    };
  }

  /// Data pengumuman resmi (placeholder: belum terintegrasi dengan data backend)
  static List<AnnouncementModel> mockAnnouncements() => const [];
}
