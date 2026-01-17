import 'package:billova/models/model/models/ticket_item_model.dart';

class OrderModel {
  final String id;
  final List<TicketItem> items;
  final int total;
  final DateTime dateTime;

  OrderModel({
    required this.id,
    required this.items,
    required this.total,
    required this.dateTime,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'items': items.map((e) => e.toJson()).toList(),
    'total': total,
    'dateTime': dateTime.toIso8601String(),
  };

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
    id: json['id'],
    items: (json['items'] as List)
        .map((e) => TicketItem.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
    total: json['total'],
    dateTime: DateTime.parse(json['dateTime']),
  );
}
