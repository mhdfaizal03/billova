class Category {
  final String id;
  final String name;
  final bool isActive;
  final DateTime createdAt;

  Category({
    required this.id,
    required this.name,
    required this.isActive,
    required this.createdAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      isActive: json['is_active'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'name': name,
    'is_active': isActive,
    'createdAt': createdAt.toIso8601String(),
  };

  Category copyWith({bool? isActive, String? name}) {
    return Category(
      id: id,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
    );
  }
}
