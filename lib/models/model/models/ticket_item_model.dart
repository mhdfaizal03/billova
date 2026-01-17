class TicketItem {
  final String productName;
  final String? variantName;
  final int price;
  int quantity;

  TicketItem({
    required this.productName,
    this.variantName,
    required this.price,
    required this.quantity,
  });

  int get total => price * quantity;

  TicketItem copy() {
    return TicketItem(
      productName: productName,
      variantName: variantName,
      price: price,
      quantity: quantity,
    );
  }

  Map<String, dynamic> toJson() => {
    'productName': productName,
    'variantName': variantName,
    'price': price,
    'quantity': quantity,
  };

  factory TicketItem.fromJson(Map<String, dynamic> json) => TicketItem(
    productName: json['productName'],
    variantName: json['variantName'],
    price: json['price'],
    quantity: json['quantity'],
  );
}
