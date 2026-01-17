import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:billova/utils/local_Storage/token_storage.dart';
import 'package:billova/utils/exceptions/network_exception.dart';
import 'package:billova/utils/local_Storage/product_local_store.dart';
import '../model/product_models/product_model.dart';

class ProductService {
  static const String _baseUrl =
      'https://billova-backend.onrender.com/api/product';

  // ───────── HEADERS ─────────
  static Future<Map<String, String>> _headers() async {
    final token = await TokenStorage.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ───────── FETCH ─────────
  static Future<List<Product>> fetchProducts() async {
    try {
      final uri = Uri.parse('$_baseUrl?pagination=false');
      print('ProductService FETCH: $uri');
      final res = await http.get(uri, headers: await _headers());
      print('ProductService FETCH Res: ${res.statusCode} ${res.body}');

      if (res.statusCode != 200) {
        throw Exception('Fetch failed');
      }

      final decoded = jsonDecode(res.body);

      List list;
      if (decoded['data'] is Map && decoded['data'].containsKey('data')) {
        list = decoded['data']['data'] ?? [];
      } else if (decoded['data'] is List) {
        list = decoded['data'];
      } else if (decoded['products'] is Map &&
          decoded['products'].containsKey('data')) {
        list = decoded['products']['data'] ?? [];
      } else if (decoded['products'] is List) {
        list = decoded['products'];
      } else {
        list = [];
      }

      final products = list.map((e) => Product.fromJson(e)).toList();

      await ProductLocalStore.saveAll(products);

      return products;
    } on SocketException {
      print('ProductService FETCH: No Internet');
      return await ProductLocalStore.loadAll();
    } on http.ClientException catch (e) {
      print('ProductService FETCH ClientException: $e');
      throw NetworkException('Unable to reach server');
    } catch (e) {
      print('ProductService FETCH Error: $e');
      rethrow;
    }
  }

  // ───────── CREATE ─────────
  static Future<Product> createProduct(
    Product product, {
    File? imageFile,
  }) async {
    try {
      final headers = await _headers();
      http.Response res;

      if (imageFile != null) {
        print('ProductService CREATE: Multipart with Image');
        final request = http.MultipartRequest('POST', Uri.parse(_baseUrl));
        request.headers.addAll(headers);

        // Add fields
        final jsonMap = product.toJson();
        // Multipart fields must be strings
        jsonMap.forEach((key, value) {
          if (value is Map || value is List) {
            request.fields[key] = jsonEncode(value);
          } else {
            request.fields[key] = value.toString();
          }
        });
        request.fields.remove('_id');

        request.files.add(
          await http.MultipartFile.fromPath('image', imageFile.path),
        );

        final streamedRes = await request.send();
        res = await http.Response.fromStream(streamedRes);
      } else {
        print('ProductService CREATE: JSON');
        // payload matches model keys now
        final body = product.toJson();
        body.remove('_id');
        print('ProductService CREATE Body: $body');

        res = await http.post(
          Uri.parse(_baseUrl),
          headers: headers,
          body: jsonEncode(body),
        );
      }

      print('ProductService CREATE Res: ${res.statusCode} ${res.body}');

      if (res.statusCode != 200 && res.statusCode != 201) {
        throw Exception('Create failed: ${res.statusCode} - ${res.body}');
      }

      final decoded = jsonDecode(res.body);
      final prodData = decoded['data'] ?? decoded['product'];

      if (prodData == null) {
        throw Exception('Server returned no data');
      }

      final newProduct = Product.fromJson(prodData);

      await ProductLocalStore.add(newProduct);

      return newProduct;
    } on SocketException {
      print('ProductService CREATE: No Internet');
      throw NetworkException('No internet connection');
    } on http.ClientException catch (e) {
      print('ProductService CREATE ClientException: $e');
      throw NetworkException('Unable to reach server');
    } catch (e) {
      print('ProductService CREATE Error: $e');
      if (e is! NetworkException) {
        throw Exception('Failed to create product: $e');
      }
      rethrow;
    }
  }

  // ───────── UPDATE ─────────
  static Future<Product> updateProduct(
    Product product, {
    File? imageFile,
  }) async {
    try {
      if (product.id == null) throw Exception('Product ID required for update');

      final headers = await _headers();
      http.Response res;

      if (imageFile != null) {
        print('ProductService UPDATE: Multipart with Image');
        final request = http.MultipartRequest(
          'PUT',
          Uri.parse('$_baseUrl/${product.id}'),
        );
        request.headers.addAll(headers);

        final jsonMap = product.toJson();
        jsonMap.forEach((key, value) {
          if (value is Map || value is List) {
            request.fields[key] = jsonEncode(value);
          } else {
            request.fields[key] = value.toString();
          }
        });
        request.fields.remove('_id');

        request.files.add(
          await http.MultipartFile.fromPath('image', imageFile.path),
        );

        final streamedRes = await request.send();
        res = await http.Response.fromStream(streamedRes);
      } else {
        final body = product.toJson();
        body.remove('_id');

        print('ProductService UPDATE Body: $body');

        res = await http.put(
          Uri.parse('$_baseUrl/${product.id}'),
          headers: headers,
          body: jsonEncode(body),
        );
      }

      print('ProductService UPDATE Res: ${res.statusCode} ${res.body}');

      if (res.statusCode != 200) {
        throw Exception('Update failed: ${res.statusCode} - ${res.body}');
      }

      final decoded = jsonDecode(res.body);
      final prodData = decoded['data'] ?? decoded['product'];

      if (prodData == null) {
        throw Exception('Server returned no data');
      }

      final updatedProduct = Product.fromJson(prodData);

      await ProductLocalStore.add(updatedProduct);

      return updatedProduct;
    } on SocketException {
      print('ProductService UPDATE: No Internet');
      throw NetworkException('No internet connection');
    } on http.ClientException catch (e) {
      print('ProductService UPDATE ClientException: $e');
      throw NetworkException('Unable to reach server');
    } catch (e) {
      print('ProductService UPDATE Error: $e');
      if (e is! NetworkException) {
        throw Exception('Failed to update product: $e');
      }
      rethrow;
    }
  }
}
