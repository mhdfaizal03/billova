import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'category_pending_action.dart';

class CategoryPendingStore {
  static const _key = 'pending_category_actions';

  static Future<List<CategoryPendingAction>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);

    if (raw == null) return [];

    final List decoded = jsonDecode(raw);
    return decoded.map((e) => CategoryPendingAction.fromJson(e)).toList();
  }

  static Future<void> add(CategoryPendingAction action) async {
    final list = await load();
    list.add(action);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(list.map((e) => e.toJson()).toList()),
    );
  }

  static Future<void> removeAt(int index) async {
    final list = await load();
    list.removeAt(index);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(list.map((e) => e.toJson()).toList()),
    );
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
