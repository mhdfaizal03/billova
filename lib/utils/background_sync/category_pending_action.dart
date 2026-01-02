enum CategoryActionType { create, update, delete }

class CategoryPendingAction {
  final CategoryActionType type;
  final Map<String, dynamic> payload;

  CategoryPendingAction({required this.type, required this.payload});

  Map<String, dynamic> toJson() => {'type': type.name, 'payload': payload};

  factory CategoryPendingAction.fromJson(Map<String, dynamic> json) {
    return CategoryPendingAction(
      type: CategoryActionType.values.firstWhere((e) => e.name == json['type']),
      payload: Map<String, dynamic>.from(json['payload']),
    );
  }
}
