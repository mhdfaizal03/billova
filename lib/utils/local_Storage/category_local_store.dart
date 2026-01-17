import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:billova/models/model/category_models/category_model.dart';
import 'package:billova/utils/local_Storage/token_storage.dart';

class CategoryLocalStore {
  /// 🔑 STABLE KEY (STORE-BASED)
  static Future<String> _key() async {
    final storeId = await TokenStorage.getSelectedStore();
    return 'cached_categories_${storeId ?? 'default'}';
  }

  // ───────── LOAD ─────────
  static Future<List<Category>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(await _key());

    if (raw == null || raw.isEmpty) return [];

    try {
      final List list = jsonDecode(raw);
      return list.map((e) => Category.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  // ───────── SAVE ─────────
  static Future<void> saveAll(List<Category> categories) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      await _key(),
      jsonEncode(categories.map((e) => e.toJson()).toList()),
    );
  }

  // ───────── ADD / UPDATE ─────────
  static Future<void> add(Category c) async {
    final list = await loadAll();
    list.removeWhere((e) => e.id == c.id);
    list.add(c);
    await saveAll(list);
  }

  static Future<void> update(Category c) => add(c);

  // ───────── DELETE ─────────
  static Future<void> delete(String id) async {
    final list = await loadAll();
    list.removeWhere((e) => e.id == id);
    await saveAll(list);
  }

  // ───────── REPLACE TEMP ID ─────────
  static Future<void> replaceId({
    required String oldId,
    required Category newCategory,
  }) async {
    final list = await loadAll();
    list.removeWhere((e) => e.id == oldId);
    list.add(newCategory);
    await saveAll(list);
  }

  // ───────── CLEAR ON LOGOUT ─────────
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(await _key());
  }
}
