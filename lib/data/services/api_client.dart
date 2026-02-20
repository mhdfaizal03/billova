import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:billova/utils/local_Storage/token_storage.dart';
import 'package:billova/utils/exceptions/network_exception.dart';

class ApiClient {
  static const String baseUrl = 'https://billova-backend.onrender.com/api';
  static const Duration timeout = Duration(seconds: 10);

  // ───────── HEADERS ─────────
  static Future<Map<String, String>> _headers() async {
    final token = await TokenStorage.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  // ───────── GET ─────────
  static Future<dynamic> get(
    String endpoint, {
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final uri = Uri.parse(
        '$baseUrl$endpoint',
      ).replace(queryParameters: queryParams);
      print('API GET: $uri');

      final response = await http
          .get(uri, headers: await _headers())
          .timeout(timeout);
      return _processResponse(response);
    } on SocketException {
      throw NetworkException('No internet connection');
    } on http.ClientException {
      throw NetworkException('Unable to reach server');
    } catch (e) {
      rethrow;
    }
  }

  // ───────── POST ─────────
  static Future<dynamic> post(String endpoint, {dynamic body}) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      print('API POST: $uri');

      final response = await http
          .post(
            uri,
            headers: await _headers(),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(timeout);

      return _processResponse(response);
    } on SocketException {
      throw NetworkException('No internet connection');
    } on http.ClientException {
      throw NetworkException('Unable to reach server');
    } catch (e) {
      rethrow;
    }
  }

  // ───────── PUT ─────────
  static Future<dynamic> put(String endpoint, {dynamic body}) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      print('API PUT: $uri');

      final response = await http
          .put(
            uri,
            headers: await _headers(),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(timeout);

      return _processResponse(response);
    } on SocketException {
      throw NetworkException('No internet connection');
    } on http.ClientException {
      throw NetworkException('Unable to reach server');
    } catch (e) {
      rethrow;
    }
  }

  // ───────── DELETE ─────────
  static Future<dynamic> delete(String endpoint) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      print('API DELETE: $uri');

      final response = await http
          .delete(uri, headers: await _headers())
          .timeout(timeout);
      return _processResponse(response);
    } on SocketException {
      throw NetworkException('No internet connection');
    } on http.ClientException {
      throw NetworkException('Unable to reach server');
    } catch (e) {
      rethrow;
    }
  }

  // ───────── RESPONSE HANDLER ─────────
  static dynamic _processResponse(http.Response response) {
    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');

    final body = response.body.isNotEmpty ? jsonDecode(response.body) : null;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    } else {
      String message = 'Something went wrong';
      if (body is Map && body.containsKey('message')) {
        message = body['message'];
      } else if (body is Map && body.containsKey('error')) {
        message = body['error'];
      }
      throw NetworkException(message); // Or custom API exception
    }
  }
}
