class AuthResponse {
  final bool success;
  final String message;
  final String? token;
  final bool multipleStores;
  final List<StoreModel> stores;

  AuthResponse({
    required this.success,
    required this.message,
    this.token,
    this.multipleStores = false,
    this.stores = const [],
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['token'] != null || json['multiple_stores'] == true,
      message: json['message'] ?? '',
      token: json['token'],
      multipleStores: json['multiple_stores'] ?? false,
      stores: json['stores'] != null
          ? (json['stores'] as List).map((e) => StoreModel.fromJson(e)).toList()
          : [],
    );
  }
}

class StoreModel {
  final String id;
  final String name;

  StoreModel({required this.id, required this.name});

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(id: json['id'], name: json['name']);
  }
}
