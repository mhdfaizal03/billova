import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:billova/utils/local_Storage/token_storage.dart';
import 'package:billova/utils/exceptions/network_exception.dart';
import 'package:billova/utils/local_Storage/category_local_store.dart';
import '../model/category_models/category_model.dart';

class CategoryService {
  static const String _baseUrl =
      'https://billova-backend.onrender.com/api/category';

  // ───────── HEADERS ─────────
  static Future<Map<String, String>> _headers() async {
    final token = await TokenStorage.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ───────── FETCH ─────────
  static Future<List<Category>> fetchCategories({
    bool? isActive,
    bool pagination = false,
    int? page,
    int? limit,
  }) async {
    try {
      final params = <String, String>{};

      if (isActive != null) {
        params['is_active'] = isActive.toString();
      }

      params['pagination'] = pagination.toString();
      if (page != null) params['page'] = page.toString();
      if (limit != null) params['limit'] = limit.toString();

      final uri = Uri.parse(_baseUrl).replace(queryParameters: params);
      print('CategoryService FETCH: $uri');
      final res = await http.get(uri, headers: await _headers());
      print('CategoryService FETCH Res: ${res.statusCode} ${res.body}');

      if (res.statusCode != 200) {
        throw Exception('Fetch failed');
      }

      final decoded = jsonDecode(res.body);

      // Handle response structure depending on pagination
      List list;
      if (decoded['data'] is Map && decoded['data'].containsKey('data')) {
        // Paginated response usually likely { data: { data: [], total: ... } } or similar
        // Adjust based on actual API response structure for pagination
        list = decoded['data']['data'] ?? [];
      } else if (decoded['data'] is List) {
        list = decoded['data'];
      } else if (decoded['categories'] is Map &&
          decoded['categories'].containsKey('data')) {
        list = decoded['categories']['data'] ?? [];
      } else if (decoded['categories'] is List) {
        list = decoded['categories'];
      } else {
        list = [];
      }

      final categories = list.map((e) => Category.fromJson(e)).toList();

      // Save to local store if fetching all (or specific logic)
      // Usually we cache the "all" list or "active" list.
      // For simplicity, if not paginated, we update cache.
      if (!pagination) {
        await CategoryLocalStore.saveAll(categories);
      }

      return categories;
    } on SocketException {
      print('CategoryService FETCH: No Internet');
      // Offline fallback
      return await CategoryLocalStore.loadAll();
    } on http.ClientException catch (e) {
      print('CategoryService FETCH ClientException: $e');
      throw NetworkException('Unable to reach server');
    } catch (e) {
      print('CategoryService FETCH Error: $e');
      rethrow;
    }
  }

  // ───────── GET BY ID ─────────
  static Future<Category?> getCategoryById(String id) async {
    try {
      final uri = Uri.parse('$_baseUrl?id=$id');
      final res = await http.get(uri, headers: await _headers());
      if (res.statusCode != 200) {
        return null; // Or throw
      }
      final decoded = jsonDecode(res.body);
      // Assuming valid response has data
      if (decoded['data'] != null &&
          decoded['data'] is List &&
          (decoded['data'] as List).isNotEmpty) {
        return Category.fromJson(decoded['data'][0]);
      }
      return null;
    } on SocketException {
      final local = await CategoryLocalStore.loadAll();
      try {
        return local.firstWhere((e) => e.id == id);
      } catch (_) {
        return null;
      }
    } catch (e) {
      throw e;
    }
  }

  // ───────── CREATE ─────────
  static Future<Category> createCategory({
    required String name,
    required bool isActive,
  }) async {
    try {
      print('CategoryService CREATE: $name, $isActive');
      final res = await http.post(
        Uri.parse(_baseUrl),
        headers: await _headers(),
        body: jsonEncode({'name': name, 'is_active': isActive}),
      );
      print('CategoryService CREATE Res: ${res.statusCode} ${res.body}');

      if (res.statusCode != 200 && res.statusCode != 201) {
        throw Exception('Create failed: ${res.statusCode} - ${res.body}');
      }

      final decoded = jsonDecode(res.body);
      final catData = decoded['data'] ?? decoded['category'];

      if (catData == null) {
        throw Exception('Server returned no data');
      }

      final newCategory = Category.fromJson(catData);

      // Update local store
      await CategoryLocalStore.add(newCategory);

      return newCategory;
    } on SocketException {
      print('CategoryService CREATE: No Internet');
      throw NetworkException('No internet connection');
    } on http.ClientException catch (e) {
      print('CategoryService CREATE ClientException: $e');
      throw NetworkException('Unable to reach server');
    } catch (e) {
      print('CategoryService CREATE Error: $e');
      if (e is! NetworkException) {
        throw Exception('Failed to create category: $e');
      }
      rethrow;
    }
  }

  // ───────── UPDATE ─────────
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
    } on SocketException {
      throw NetworkException('No internet connection');
    } on http.ClientException {
      throw NetworkException('Unable to reach server');
    }
  }

  // ───────── DELETE ─────────
  static Future<void> deleteCategory(String id) async {
    try {
      final res = await http.delete(
        Uri.parse('$_baseUrl/$id'),
        headers: await _headers(),
      );

      if (res.statusCode != 200) {
        throw Exception('Delete failed');
      }
    } on SocketException {
      throw NetworkException('No internet connection');
    } on http.ClientException {
      throw NetworkException('Unable to reach server');
    }
  }
}
