import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const _tokenKey = 'auth_token';
  static const _storeKey = 'selected_store';

  // ───────── SAVE ─────────
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<void> saveSelectedStore(String storeId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storeKey, storeId);
  }

  // ───────── GET ─────────
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<String?> getSelectedStore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_storeKey);
  }

  // ───────── HELPERS ─────────
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ───────── CLEAR ─────────
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_storeKey);
  }
}
