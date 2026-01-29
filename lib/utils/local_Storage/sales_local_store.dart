import 'dart:convert';
import 'package:billova/models/model/models/order_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:billova/utils/local_Storage/token_storage.dart';

class SalesLocalStore {
  static Future<String> _key() async {
    final storeId = await TokenStorage.getSelectedStore();
    return 'sales_history_${storeId ?? 'default'}';
  }

  static Future<void> saveOrder(OrderModel order) async {
    final prefs = await SharedPreferences.getInstance();
    final List<OrderModel> orders = await getOrders();
    orders.add(order);

    final List<String> jsonList = orders
        .map((e) => json.encode(e.toJson()))
        .toList();
    await prefs.setStringList(await _key(), jsonList);
  }

  static Future<List<OrderModel>> getOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _key();
    final List<String>? jsonList = prefs.getStringList(key);

    if (jsonList == null) return [];

    return jsonList
        .map((e) => OrderModel.fromJson(json.decode(e) as Map<String, dynamic>))
        .toList();
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(await _key());
  }
}
