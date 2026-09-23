class InformationModel {
  final String id;
  final String title;
  final String category;
  final String status;
  final bool isRead;
  final bool isImportant;
  final DateTime createdAt;

  const InformationModel({
    required this.id,
    required this.title,
    required this.category,
    required this.status,
    required this.isRead,
    required this.isImportant,
    required this.createdAt,
  });
}
