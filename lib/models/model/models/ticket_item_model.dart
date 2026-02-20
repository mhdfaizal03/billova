class TicketItem {
  final String productName;
  final String? variantName;
  final double price; // Changed from int to double
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

  double get subtotal => price * quantity;
  double get taxAmount => (subtotal * taxRate) / 100;
  double get totalWithTax => subtotal + taxAmount;

  double get total => totalWithTax; // Changed from int round()

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
    price: (json['price'] ?? 0).toDouble(), // Ensure double
    quantity: json['quantity'] ?? 1,
    taxId: json['taxId'],
    taxRate: (json['taxRate'] ?? 0).toDouble(),
  );
}
