class Category {
  final String id;
  final String name;
  bool isActive;
  final DateTime createdAt;

  Category({
    required this.id,
    required this.name,
    required this.isActive,
    required this.createdAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'],
      name: json['name'],
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'is_active': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
