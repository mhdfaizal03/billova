import 'package:billova/models/model/models/order_model.dart';
import 'package:billova/data/services/api_client.dart';

class SalesService {
  static Future<void> saveOrder(OrderModel order) async {
    await ApiClient.post('/sales', body: order.toJson());
  }

  static Future<List<OrderModel>> getOrders() async {
    final response = await ApiClient.get('/sales');

    if (response == null) return [];

    List list = [];
    if (response is Map && response.containsKey('data')) {
      if (response['data'] is List) {
        list = response['data'];
      } else if (response['data'] is Map &&
          response['data'].containsKey('data')) {
        list = response['data']['data'];
      }
    } else if (response is List) {
      list = response;
    }

    return list
        .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> clearHistory() async {
    await ApiClient.delete('/sales/clear');
  }
}
