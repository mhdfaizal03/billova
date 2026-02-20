import 'dart:io';
import 'package:billova/data/services/api_client.dart';
import '../model/product_models/product_model.dart';

class ProductService {
  static const String _endpoint = '/product';

  // ───────── FETCH ─────────
  static Future<List<Product>> fetchProducts() async {
    final decoded = await ApiClient.get('$_endpoint?pagination=false');

    List list = [];
    if (decoded != null) {
      if (decoded is List) {
        list = decoded;
      } else if (decoded is Map) {
        if (decoded.containsKey('data')) {
          final dataField = decoded['data'];
          if (dataField is Map && dataField.containsKey('data')) {
            list = dataField['data'] ?? [];
          } else if (dataField is List) {
            list = dataField;
          }
        } else if (decoded.containsKey('products')) {
          final catField = decoded['products'];
          if (catField is Map && catField.containsKey('data')) {
            list = catField['data'] ?? [];
          } else if (catField is List) {
            list = catField;
          }
        }
      }
    }

    return list.map((e) => Product.fromJson(e)).toList();
  }

  // ───────── CREATE ─────────
  static Future<Product> createProduct(
    Product product, {
    File? imageFile,
  }) async {
    dynamic decoded;

    if (imageFile != null) {
      final body = product.toJson();
      body.remove('_id');

      decoded = await ApiClient.multipart(
        'POST',
        _endpoint,
        body: body,
        file: imageFile,
      );
    } else {
      final body = product.toJson();
      body.remove('_id');
      decoded = await ApiClient.post(_endpoint, body: body);
    }

    final prodData = decoded != null
        ? (decoded['data'] ?? decoded['product'])
        : null;
    if (prodData != null) {
      return Product.fromJson(prodData);
    }

    final all = await fetchProducts();
    try {
      return all.firstWhere(
        (p) => p.name.toLowerCase() == product.name.trim().toLowerCase(),
      );
    } catch (_) {
      return product;
    }
  }

  // ───────── UPDATE ─────────
  static Future<Product> updateProduct(
    Product product, {
    File? imageFile,
  }) async {
    if (product.id == null) throw Exception('Product ID required for update');

    dynamic decoded;

    if (imageFile != null) {
      final body = product.toJson();
      body.remove('_id');

      decoded = await ApiClient.multipart(
        'PUT',
        '$_endpoint/${product.id}',
        body: body,
        file: imageFile,
      );
    } else {
      final body = product.toJson();
      body.remove('_id');
      decoded = await ApiClient.put('$_endpoint/${product.id}', body: body);
    }

    final prodData = decoded != null
        ? (decoded['data'] ?? decoded['product'])
        : null;
    if (prodData != null) {
      return Product.fromJson(prodData);
    }

    return product;
  }

  // ───────── DELETE ─────────
  static Future<void> deleteProduct(String id) async {
    await ApiClient.delete('$_endpoint/$id');
  }
}
