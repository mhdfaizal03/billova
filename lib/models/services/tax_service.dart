import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:billova/utils/local_Storage/token_storage.dart';
import 'package:billova/utils/exceptions/network_exception.dart';
import 'package:billova/utils/local_Storage/tax_local_store.dart';
import '../model/tax_models/tax_model.dart';

class TaxService {
  static const String _baseUrl = 'https://billova-backend.onrender.com/api/tax';

  // ───────── HEADERS ─────────
  static Future<Map<String, String>> _headers() async {
    final token = await TokenStorage.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ───────── FETCH ─────────
  static Future<List<Tax>> fetchTaxes({bool? isActive}) async {
    try {
      final params = <String, String>{};
      if (isActive != null) {
        params['is_active'] = isActive.toString();
      }
      params['pagination'] = 'false';

      final uri = Uri.parse(_baseUrl).replace(queryParameters: params);
      print('TaxService FETCH: $uri');
      final res = await http.get(uri, headers: await _headers());
      print('TaxService FETCH Res: ${res.statusCode} ${res.body}');

      if (res.statusCode != 200) {
        throw Exception('Fetch failed');
      }

      final decoded = jsonDecode(res.body);

      // Handle response structure depending on pagination
      List list;
      if (decoded['data'] is Map && decoded['data'].containsKey('data')) {
        list = decoded['data']['data'] ?? [];
      } else if (decoded['data'] is List) {
        list = decoded['data'];
      } else if (decoded['taxes'] is Map &&
          decoded['taxes'].containsKey('data')) {
        list = decoded['taxes']['data'] ?? [];
      } else if (decoded['taxes'] is List) {
        list = decoded['taxes'];
      } else {
        list = [];
        print('TaxService FETCH: No list found in keys: ${decoded.keys}');
      }

      final taxes = list.map((e) => Tax.fromJson(e)).toList();

      // Cache
      await TaxLocalStore.saveAll(taxes);

      return taxes;
    } on SocketException {
      print('TaxService FETCH: No Internet');
      return await TaxLocalStore.loadAll();
    } on http.ClientException catch (e) {
      print('TaxService FETCH ClientException: $e');
      throw NetworkException('Unable to reach server');
    } catch (e) {
      print('TaxService FETCH Error: $e');
      rethrow;
    }
  }

  // ───────── CREATE ─────────
  static Future<Tax> createTax({
    required String name,
    required double rate,
    required bool isActive,
  }) async {
    try {
      print('TaxService CREATE: $name, $rate, $isActive');
      final res = await http.post(
        Uri.parse(_baseUrl),
        headers: await _headers(),
        body: jsonEncode({'name': name, 'rate': rate, 'is_active': isActive}),
      );
      print('TaxService CREATE Res: ${res.statusCode} ${res.body}');

      if (res.statusCode != 200 && res.statusCode != 201) {
        throw Exception('Create failed: ${res.statusCode} - ${res.body}');
      }

      final decoded = jsonDecode(res.body);
      final taxData = decoded['data'] ?? decoded['tax'];

      if (taxData == null) {
        throw Exception('Server returned no data');
      }

      final newTax = Tax.fromJson(taxData);

      await TaxLocalStore.add(newTax);

      return newTax;
    } on SocketException {
      print('TaxService CREATE: No Internet');
      throw NetworkException('No internet connection');
    } on http.ClientException catch (e) {
      print('TaxService CREATE ClientException: $e');
      throw NetworkException('Unable to reach server');
    } catch (e) {
      print('TaxService CREATE Error: $e');
      if (e is! NetworkException) {
        throw Exception('Failed to create tax: $e');
      }
      rethrow;
    }
  }

  // ───────── UPDATE ─────────
  static Future<void> updateTax({
    required String id,
    required String name,
    required double rate,
    required bool isActive,
  }) async {
    try {
      final res = await http.put(
        Uri.parse('$_baseUrl/$id'),
        headers: await _headers(),
        body: jsonEncode({'name': name, 'rate': rate, 'is_active': isActive}),
      );

      if (res.statusCode != 200) {
        throw Exception('Update failed');
      }

      // We need to fetch the updated object or construct it to update local cache
      // Ideally backend returns the updated object.
      // Simplified: We assume success and update local if we had full object details,
      // but here we might just re-fetch or partial update.
      // Let's do a re-fetch or manual update.

      // Manual update attempt
      // Since we don't have created_at etc here easily without fetching,
      // we might want to fetch all again or just ignore local update until next fetch.
      // Better yet, let's fetch single if possible or update what we know.
      // For now, re-fetch all to sync.
      await fetchTaxes();
    } on SocketException {
      throw NetworkException('No internet connection');
    } on http.ClientException {
      throw NetworkException('Unable to reach server');
    }
  }

  // ───────── DELETE ─────────
  static Future<void> deleteTax(String id) async {
    try {
      final res = await http.delete(
        Uri.parse('$_baseUrl/$id'),
        headers: await _headers(),
      );

      if (res.statusCode != 200) {
        throw Exception('Delete failed');
      }

      await TaxLocalStore.delete(id);
    } on SocketException {
      throw NetworkException('No internet connection');
    } on http.ClientException {
      throw NetworkException('Unable to reach server');
    }
  }
}
