class TicketItem {
  final String productName;
  final String? variantName;
  final int price;
  int quantity;
  final String? taxId;
  final double taxRate;

  TicketItem({
    required this.productName,
    this.variantName,
    required this.price,
    required this.quantity,
    this.taxId,
    this.taxRate = 0.0,
  });

  int get subtotal => price * quantity;
  double get taxAmount => (subtotal * taxRate) / 100;
  double get totalWithTax => subtotal + taxAmount;

  // For backward compatibility mostly, but ticket total usually means pay amount
  int get total => totalWithTax.round();

  TicketItem copy() {
    return TicketItem(
      productName: productName,
      variantName: variantName,
      price: price,
      quantity: quantity,
      taxId: taxId,
      taxRate: taxRate,
    );
  }

  Map<String, dynamic> toJson() => {
    'productName': productName,
    'variantName': variantName,
    'price': price,
    'quantity': quantity,
    'taxId': taxId,
    'taxRate': taxRate,
  };

  factory TicketItem.fromJson(Map<String, dynamic> json) => TicketItem(
    productName: json['productName'],
    variantName: json['variantName'],
    price: json['price'],
    quantity: json['quantity'],
    taxId: json['taxId'],
    taxRate: (json['taxRate'] ?? 0).toDouble(),
  );
}
