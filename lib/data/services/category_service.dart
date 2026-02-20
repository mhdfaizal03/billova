import 'package:billova/data/services/api_client.dart';
import 'package:billova/models/model/category_models/category_model.dart';

class CategoryService {
  static const String _endpoint = '/category';

  static Future<List<Category>> fetchCategories({bool? isActive}) async {
    final queryParams = isActive != null
        ? {'is_active': isActive.toString()}
        : null;
    final response = await ApiClient.get(_endpoint, queryParams: queryParams);

    if (response['data'] is List) {
      return (response['data'] as List)
          .map((e) => Category.fromJson(e))
          .toList();
    } else if (response['data'] is Map && response['data']['data'] is List) {
      // Handle pagination structure if any
      return (response['data']['data'] as List)
          .map((e) => Category.fromJson(e))
          .toList();
    }
    return [];
  }

  static Future<Category> createCategory(
    String name, {
    bool isActive = true,
  }) async {
    final response = await ApiClient.post(
      _endpoint,
      body: {'name': name, 'is_active': isActive},
    );

    // Check if response has data
    if (response['data'] != null) {
      return Category.fromJson(response['data']);
    } else if (response['category'] != null) {
      return Category.fromJson(response['category']);
    }
    // Fallback or re-fetch logic if needed
    throw Exception('Failed to parse category creation response');
  }

  static Future<Category> updateCategory(
    String id,
    String name, {
    bool isActive = true,
  }) async {
    final response = await ApiClient.put(
      '$_endpoint/$id',
      body: {'name': name, 'is_active': isActive},
    );

    if (response['data'] != null) {
      return Category.fromJson(response['data']);
    }
    throw Exception('Failed to parse category update response');
  }

  static Future<void> deleteCategory(String id) async {
    await ApiClient.delete('$_endpoint/$id');
  }
}
