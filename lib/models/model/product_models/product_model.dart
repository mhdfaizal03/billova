class Product {
  final String? id;
  final String name;
  final String remakes; // description
  final double mrp;
  final double salePrice;
  final double purchasePrice;
  final int stockQuantity;
  final String categoryId;
  final String taxId;
  final ProductVariants? variants;
  final String? imageUrl;

  Product({
    this.id,
    required this.name,
    required this.remakes,
    required this.mrp,
    required this.salePrice,
    required this.purchasePrice,
    required this.stockQuantity,
    required this.categoryId,
    required this.taxId,
    this.variants,
    this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Handle 'varients' (API typo) which is a List, or 'variants'
    ProductVariants? parsedVariants;
    final vData = json['varients'] ?? json['variants'];

    if (vData is List && vData.isNotEmpty) {
      final firstItem = vData[0];
      if (firstItem is Map<String, dynamic> &&
          firstItem.containsKey('options')) {
        // Handle nested structure: [{"options": [...]}]
        final List options = firstItem['options'] ?? [];
        parsedVariants = ProductVariants(
          options: options.map((v) => VariantOption.fromJson(v)).toList(),
        );
      } else {
        // Handle direct list structure: [{"option_name": "...", ...}]
        parsedVariants = ProductVariants(
          options: vData.map((v) => VariantOption.fromJson(v)).toList(),
        );
      }
    } else if (vData is Map<String, dynamic>) {
      parsedVariants = ProductVariants.fromJson(vData);
    }

    return Product(
      id: json['_id'] ?? json['id'], // ID might be null on create response?
      name: json['name'] ?? '',
      remakes: json['remakes'] ?? '',
      mrp: (json['mrp'] ?? 0).toDouble(),
      salePrice: (json['sale_price'] ?? 0).toDouble(),
      purchasePrice: (json['purchase_price'] ?? 0).toDouble(),
      stockQuantity: (json['stock_quantity'] ?? 0).toInt(),
      categoryId: json['category_id'] ?? '',
      taxId: json['tax_id'] ?? '',
      variants: parsedVariants,
      imageUrl: json['image'] ?? json['image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'name': name,
      'remakes': remakes,
      'mrp': mrp,
      'sale_price': salePrice,
      'purchase_price': purchasePrice,
      'stock_quantity': stockQuantity,
      'category_id': categoryId,
      'tax_id': taxId,
      if (variants != null)
        'varients': {
          'options': variants!.options.map((v) => v.toJson()).toList(),
        },
      if (imageUrl != null) 'image_url': imageUrl,
    };
  }
}

class ProductVariants {
  final List<VariantOption> options;

  ProductVariants({required this.options});

  factory ProductVariants.fromJson(Map<String, dynamic> json) {
    var opts = <VariantOption>[];
    if (json['options'] != null) {
      json['options'].forEach((v) {
        opts.add(VariantOption.fromJson(v));
      });
    }
    return ProductVariants(options: opts);
  }

  Map<String, dynamic> toJson() {
    return {'options': options.map((v) => v.toJson()).toList()};
  }
}

class VariantOption {
  final String optionName;
  final double optionRate;

  VariantOption({required this.optionName, required this.optionRate});

  factory VariantOption.fromJson(Map<String, dynamic> json) {
    return VariantOption(
      optionName: json['option_name'] ?? '',
      optionRate: (json['sales_rate'] ?? json['option_rate'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'option_name': optionName, 'sales_rate': optionRate};
  }
}
