import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:billova/models/model/tax_models/tax_model.dart';
import 'package:billova/utils/local_Storage/token_storage.dart';

class TaxLocalStore {
  /// 🔑 STABLE KEY (STORE-BASED)
  static Future<String> _key() async {
    final storeId = await TokenStorage.getSelectedStore();
    return 'cached_taxes_${storeId ?? 'default'}';
  }

  // ───────── LOAD ─────────
  static Future<List<Tax>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(await _key());

    if (raw == null || raw.isEmpty) return [];

    try {
      final List list = jsonDecode(raw);
      return list.map((e) => Tax.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  // ───────── SAVE ─────────
  static Future<void> saveAll(List<Tax> taxes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      await _key(),
      jsonEncode(taxes.map((e) => e.toJson()).toList()),
    );
  }

  // ───────── ADD / UPDATE ─────────
  static Future<void> add(Tax t) async {
    final list = await loadAll();
    list.removeWhere((e) => e.id == t.id);
    list.add(t);
    await saveAll(list);
  }

  static Future<void> update(Tax t) => add(t);

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
