import 'dart:convert';
import 'package:billova/models/model/models/order_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SalesLocalStore {
  static const String _keySales = 'sales_history';

  static Future<void> saveOrder(OrderModel order) async {
    final prefs = await SharedPreferences.getInstance();
    final List<OrderModel> orders = await getOrders();
    orders.add(order);

    final List<String> jsonList = orders
        .map((e) => json.encode(e.toJson()))
        .toList();
    await prefs.setStringList(_keySales, jsonList);
  }

  static Future<List<OrderModel>> getOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? jsonList = prefs.getStringList(_keySales);

    if (jsonList == null) return [];

    return jsonList
        .map((e) => OrderModel.fromJson(json.decode(e) as Map<String, dynamic>))
        .toList();
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keySales);
  }
}
