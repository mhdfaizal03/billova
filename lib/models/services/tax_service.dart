import 'package:billova/data/services/api_client.dart';
import '../model/tax_models/tax_model.dart';

class TaxService {
  static const String _endpoint = '/tax';

  // ───────── FETCH ─────────
  static Future<List<Tax>> fetchTaxes({bool? isActive}) async {
    final params = <String, dynamic>{};
    if (isActive != null) params['is_active'] = isActive.toString();
    params['pagination'] = 'false';

    final decoded = await ApiClient.get(_endpoint, queryParams: params);

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
        } else if (decoded.containsKey('taxes')) {
          final catField = decoded['taxes'];
          if (catField is Map && catField.containsKey('data')) {
            list = catField['data'] ?? [];
          } else if (catField is List) {
            list = catField;
          }
        }
      }
    }

    return list.map((e) => Tax.fromJson(e)).toList();
  }

  // ───────── CREATE ─────────
  static Future<Tax> createTax({
    required String name,
    required double rate,
    required bool isActive,
  }) async {
    final decoded = await ApiClient.post(
      _endpoint,
      body: {'name': name, 'rate': rate, 'is_active': isActive},
    );

    final taxData = decoded != null
        ? (decoded['data'] ?? decoded['tax'])
        : null;
    if (taxData != null) {
      return Tax.fromJson(taxData);
    }

    final all = await fetchTaxes();
    try {
      return all.firstWhere(
        (t) => t.name.toLowerCase() == name.trim().toLowerCase(),
      );
    } catch (_) {
      return Tax(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        rate: rate,
        isActive: isActive,
        createdAt: DateTime.now(),
      );
    }
  }

  // ───────── UPDATE ─────────
  static Future<void> updateTax({
    required String id,
    required String name,
    required double rate,
    required bool isActive,
  }) async {
    await ApiClient.put(
      '$_endpoint/$id',
      body: {'name': name, 'rate': rate, 'is_active': isActive},
    );
  }

  // ───────── DELETE ─────────
  static Future<void> deleteTax(String id) async {
    await ApiClient.delete('$_endpoint/$id');
  }
}
