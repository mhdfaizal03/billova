import 'dart:convert';
import 'package:billova/models/model/category_models/category_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoryLocalStore {
  static const String _key = 'cached_categories';

  /// SAVE FULL LIST (REPLACE CACHE)
  static Future<void> saveAll(List<Category> categories) async {
    final prefs = await SharedPreferences.getInstance();

    final jsonList = categories
        .map(
          (c) => {
            '_id': c.id,
            'name': c.name,
            'is_active': c.isActive,
            'createdAt': c.createdAt.toIso8601String(),
          },
        )
        .toList();

    await prefs.setString(_key, jsonEncode(jsonList));
  }

  /// LOAD FULL LIST
  static Future<List<Category>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);

    if (raw == null || raw.isEmpty) return [];

    try {
      final List decoded = jsonDecode(raw);
      return decoded.map((e) => Category.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  /// ADD OR REPLACE CATEGORY
  static Future<void> add(Category category) async {
    final list = await loadAll();

    final index = list.indexWhere((e) => e.id == category.id);
    if (index == -1) {
      list.add(category);
    } else {
      list[index] = category;
    }

    await saveAll(list);
  }

  /// UPDATE CATEGORY
  static Future<void> update(Category category) async {
    final list = await loadAll();
    final index = list.indexWhere((e) => e.id == category.id);

    if (index != -1) {
      list[index] = category;
      await saveAll(list);
    }
  }

  /// DELETE CATEGORY
  static Future<void> delete(String id) async {
    final list = await loadAll();
    list.removeWhere((e) => e.id == id);
    await saveAll(list);
  }

  /// CLEAR CACHE
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
