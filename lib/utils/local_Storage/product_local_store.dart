import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:billova/models/model/product_models/product_model.dart';
import 'package:billova/utils/local_Storage/token_storage.dart';

class ProductLocalStore {
  /// 🔑 STABLE KEY (STORE-BASED)
  static Future<String> _key() async {
    final storeId = await TokenStorage.getSelectedStore();
    return 'cached_products_${storeId ?? 'default'}';
  }

  // ───────── LOAD ─────────
  static Future<List<Product>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(await _key());

    if (raw == null || raw.isEmpty) return [];

    try {
      final List list = jsonDecode(raw);
      return list.map((e) => Product.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  // ───────── SAVE ─────────
  static Future<void> saveAll(List<Product> products) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      await _key(),
      jsonEncode(products.map((e) => e.toJson()).toList()),
    );
  }

  // ───────── ADD / UPDATE ─────────
  static Future<void> add(Product p) async {
    final list = await loadAll();
    list.removeWhere((e) => e.id == p.id);
    list.add(p);
    await saveAll(list);
  }

  // ───────── DELETE ─────────
  static Future<void> delete(String id) async {
    final list = await loadAll();
    list.removeWhere((e) => e.id == id);
    await saveAll(list);
  }

  // ───────── CLEAR ON LOGOUT ─────────
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(await _key());
  }
}
