import 'dart:convert';
import 'package:billova/models/model/category_models/category_model.dart';
import 'package:billova/utils/local_Storage/category_local_store.dart';
import 'package:billova/utils/local_Storage/token_storage.dart';
import 'package:http/http.dart' as http;

class CategoryService {
  static const String _baseUrl =
      'https://billova-backend.onrender.com/api/category';

  // ─────────────────────────────────────────────
  // HEADERS
  // ─────────────────────────────────────────────
  static Future<Map<String, String>> _headers() async {
    final token = await TokenStorage.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ─────────────────────────────────────────────
  // CREATE CATEGORY (ONLINE FIRST + LOCAL SAVE)
  // ─────────────────────────────────────────────
  static Future<void> createCategory({
    required String name,
    required bool isActive,
  }) async {
    try {
      final res = await http.post(
        Uri.parse(_baseUrl),
        headers: await _headers(),
        body: jsonEncode({'name': name, 'is_active': isActive}),
      );

      final decoded = jsonDecode(res.body);

      if ((res.statusCode == 200 || res.statusCode == 201) &&
          decoded is Map &&
          decoded['success'] == true) {
        final data = decoded['data'];

        if (data != null) {
          final category = Category.fromJson(data);
          await CategoryLocalStore.add(category);
        }
        return;
      }

      throw Exception(decoded['message'] ?? 'Failed to create category');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // ─────────────────────────────────────────────
  // GET CATEGORIES (API → LOCAL SYNC → FALLBACK)
  // ─────────────────────────────────────────────
  static Future<List<Category>> getCategories({
    bool? isActive,
    bool pagination = false,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final params = <String, String>{'pagination': pagination.toString()};

      if (pagination) {
        params['page'] = page.toString();
        params['limit'] = limit.toString();
      }

      if (isActive != null) {
        params['is_active'] = isActive.toString();
      }

      final uri = Uri.parse(_baseUrl).replace(queryParameters: params);
      final res = await http.get(uri, headers: await _headers());

      if (res.statusCode != 200) {
        throw Exception();
      }

      final decoded = jsonDecode(res.body);
      final data = decoded['data'];
      if (data == null) return [];

      final List list = pagination ? (data['docs'] ?? []) : data;
      final categories = list.map((e) => Category.fromJson(e)).toList();

      /// 🔥 SAVE SERVER STATE LOCALLY
      await CategoryLocalStore.saveAll(categories);

      return categories;
    } catch (_) {
      /// 🔁 OFFLINE FALLBACK
      return await CategoryLocalStore.loadAll();
    }
  }

  // ─────────────────────────────────────────────
  // FETCH ACTIVE CATEGORIES
  // ─────────────────────────────────────────────
  static Future<List<Category>> fetchActiveCategories() async {
    try {
      final res = await http.get(
        Uri.parse('$_baseUrl?is_active=true&pagination=false'),
        headers: await _headers(),
      );

      if (res.statusCode != 200) throw Exception();

      final decoded = jsonDecode(res.body);
      final List list = decoded['data'] ?? [];

      final categories = list.map((e) => Category.fromJson(e)).toList();

      await CategoryLocalStore.saveAll(categories);
      return categories;
    } catch (_) {
      final local = await CategoryLocalStore.loadAll();
      return local.where((c) => c.isActive).toList();
    }
  }

  // ─────────────────────────────────────────────
  // DELETE CATEGORY
  // ─────────────────────────────────────────────
  static Future<void> deleteCategory(String id) async {
    try {
      final res = await http.delete(
        Uri.parse('$_baseUrl/$id'),
        headers: await _headers(),
      );

      if (res.statusCode != 200) {
        throw Exception('Delete failed');
      }

      await CategoryLocalStore.delete(id);
    } catch (e) {
      throw Exception('Delete category error: $e');
    }
  }

  // ─────────────────────────────────────────────
  // UPDATE CATEGORY
  // ─────────────────────────────────────────────
  static Future<void> updateCategory({
    required String id,
    required String name,
    required bool isActive,
  }) async {
    try {
      final res = await http.put(
        Uri.parse('$_baseUrl/$id'),
        headers: await _headers(),
        body: jsonEncode({'name': name, 'is_active': isActive}),
      );

      if (res.statusCode != 200) {
        throw Exception('Update failed');
      }

      final updated = Category(
        id: id,
        name: name,
        isActive: isActive,
        createdAt: DateTime.now(), // server may override
      );

      await CategoryLocalStore.update(updated);
    } catch (e) {
      throw Exception('Update category error: $e');
    }
  }
}
