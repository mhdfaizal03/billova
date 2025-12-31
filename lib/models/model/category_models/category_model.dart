class Category {
  final String id;
  final String name;
  final bool isActive;
  final DateTime? createdAt;

  Category({
    required this.id,
    required this.name,
    required this.isActive,
    this.createdAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id']?.toString() ?? '',
      name: json['name'] ?? '',
      isActive: json['is_active'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }
}
