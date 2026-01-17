class Tax {
  final String id;
  final String name;
  final double rate;
  final bool isActive;
  final DateTime createdAt;

  Tax({
    required this.id,
    required this.name,
    required this.rate,
    required this.isActive,
    required this.createdAt,
  });

  factory Tax.fromJson(Map<String, dynamic> json) {
    return Tax(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      rate: (json['rate'] ?? 0).toDouble(),
      isActive: json['is_active'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'name': name,
    'rate': rate,
    'is_active': isActive,
    'createdAt': createdAt.toIso8601String(),
  };

  Tax copyWith({bool? isActive, String? name, double? rate}) {
    return Tax(
      id: id,
      name: name ?? this.name,
      rate: rate ?? this.rate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
    );
  }
}
