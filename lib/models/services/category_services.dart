import 'dart:convert';

import 'package:billova/models/model/category_models/category_model.dart';
import 'package:billova/utils/local_Storage/token_storage.dart';
import 'package:http/http.dart' as http;

class CategoryService {
  static const String _baseUrl =
      'https://billova-backend.onrender.com/api/category';

  static Future<Map<String, String>> _headers() async {
    final token = await TokenStorage.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ─────────────────────────────────────────────
  // CREATE CATEGORY
  // ─────────────────────────────────────────────
  static Future<void> createCategory({
    required String name,
    required bool isActive,
  }) async {
    final res = await http.post(
      Uri.parse(_baseUrl),
      headers: await _headers(),
      body: jsonEncode({'name': name, 'is_active': isActive}),
    );

    final decoded = jsonDecode(res.body);

    if (res.statusCode == 200 || res.statusCode == 201) {
      if (decoded is Map && decoded['success'] == true) {
        return; // ✅ SUCCESS
      }
    }

    throw Exception(
      decoded is Map && decoded['message'] != null
          ? decoded['message']
          : 'Failed to create category',
    );
  }

  // ─────────────────────────────────────────────
  // GET CATEGORIES
  // ─────────────────────────────────────────────
  static Future<List<Category>> getCategories({
    bool? isActive,
    bool pagination = true,
    int page = 1,
    int limit = 10,
  }) async {
    final queryParams = <String, String>{'pagination': pagination.toString()};

    if (pagination) {
      queryParams['page'] = page.toString();
      queryParams['limit'] = limit.toString();
    }

    if (isActive != null) {
      queryParams['is_active'] = isActive.toString();
    }

    final uri = Uri.parse(_baseUrl).replace(queryParameters: queryParams);
    final res = await http.get(uri, headers: await _headers());

    if (res.statusCode != 200) {
      throw Exception('Failed to fetch categories');
    }

    final decoded = jsonDecode(res.body);
    final List list = pagination ? decoded['data']['docs'] : decoded['data'];

    return list.map((e) => Category.fromJson(e)).toList();
  }

  // ─────────────────────────────────────────────
  // FETCH ACTIVE (NO PAGINATION)
  // ─────────────────────────────────────────────
  static Future<List<Category>> fetchActiveCategories() async {
    final res = await http.get(
      Uri.parse('$_baseUrl?is_active=true&pagination=false'),
      headers: await _headers(),
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to fetch categories');
    }

    final decoded = jsonDecode(res.body);
    final List list = decoded['data'];

    return list.map((e) => Category.fromJson(e)).toList();
  }

  static Future<void> deleteCategory(String id) async {
    final res = await http.delete(
      Uri.parse('$_baseUrl/$id'),
      headers: await _headers(),
    );
    if (res.statusCode != 200) {
      throw Exception('Delete failed');
    }
  }

  static Future<void> updateCategory({
    required String id,
    required String name,
    required bool isActive,
  }) async {
    final res = await http.put(
      Uri.parse('$_baseUrl/$id'),
      headers: await _headers(),
      body: jsonEncode({'name': name, 'is_active': isActive}),
    );

    if (res.statusCode != 200) {
      throw Exception('Update failed');
    }
  }
}
