import 'package:billova/data/services/api_client.dart';
import '../model/category_models/category_model.dart';

class CategoryService {
  static const String _endpoint = '/category';

  // ───────── FETCH ─────────
  static Future<List<Category>> fetchCategories({
    bool? isActive,
    bool pagination = false,
    int? page,
    int? limit,
  }) async {
    final params = <String, dynamic>{};
    if (isActive != null) params['is_active'] = isActive.toString();
    params['pagination'] = pagination.toString();
    if (page != null) params['page'] = page.toString();
    if (limit != null) params['limit'] = limit.toString();

    final decoded = await ApiClient.get(_endpoint, queryParams: params);

    List list = [];
    if (decoded != null) {
      if (decoded is List) {
        list = decoded;
      } else if (decoded is Map) {
        if (decoded.containsKey('data')) {
          final dataField = decoded['data'];
          if (dataField is Map && dataField.containsKey('data')) {
            list = dataField['data'] ?? [];
          } else if (dataField is List) {
            list = dataField;
          }
        } else if (decoded.containsKey('categories')) {
          final catField = decoded['categories'];
          if (catField is Map && catField.containsKey('data')) {
            list = catField['data'] ?? [];
          } else if (catField is List) {
            list = catField;
          }
        }
      }
    }

    return list.map((e) => Category.fromJson(e)).toList();
  }

  // ───────── GET BY ID ─────────
  static Future<Category?> getCategoryById(String id) async {
    final decoded = await ApiClient.get('$_endpoint?id=$id');
    if (decoded != null &&
        decoded['data'] != null &&
        decoded['data'] is List &&
        (decoded['data'] as List).isNotEmpty) {
      return Category.fromJson(decoded['data'][0]);
    }
    return null;
  }

  // ───────── CREATE ─────────
  static Future<Category> createCategory({
    required String name,
    required bool isActive,
  }) async {
    final decoded = await ApiClient.post(
      _endpoint,
      body: {'name': name, 'is_active': isActive},
    );

    final catData = decoded != null
        ? (decoded['data'] ?? decoded['category'])
        : null;
    if (catData != null) {
      return Category.fromJson(catData);
    }

    final all = await fetchCategories();
    try {
      return all.firstWhere(
        (c) => c.name.toLowerCase() == name.trim().toLowerCase(),
      );
    } catch (_) {
      return Category(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        isActive: isActive,
        createdAt: DateTime.now(),
      );
    }
  }

  // ───────── UPDATE ─────────
  static Future<void> updateCategory({
    required String id,
    required String name,
    required bool isActive,
  }) async {
    await ApiClient.put(
      '$_endpoint/$id',
      body: {'name': name, 'is_active': isActive},
    );
  }

  // ───────── DELETE ─────────
  static Future<void> deleteCategory(String id) async {
    await ApiClient.delete('$_endpoint/$id');
  }
}
