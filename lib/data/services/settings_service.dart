import 'package:billova/data/services/api_client.dart';

class SettingsService {
  static Future<Map<String, String>> loadStoreDetails() async {
    try {
      final response = await ApiClient.get('/settings/store');
      if (response != null && response['data'] != null) {
        final data = response['data'];
        return {
          'name': data['name'] ?? '',
          'address': data['address'] ?? '',
          'contact': data['contact'] ?? '',
          'gst': data['gst'] ?? '',
          'header': data['header'] ?? '',
          'footer': data['footer'] ?? '',
          'logo': data['logo'] ?? '',
        };
      }
    } catch (e) {
      print('SettingsService loadStoreDetails Error: $e');
    }
    return {
      'name': '',
      'address': '',
      'contact': '',
      'gst': '',
      'header': '',
      'footer': '',
      'logo': '',
    };
  }

  static Future<Map<String, dynamic>> loadPrinterSettings() async {
    try {
      final response = await ApiClient.get('/settings/printer');
      if (response != null && response['data'] != null) {
        final data = response['data'];
        return {
          'ip': data['ip'] ?? '192.168.1.100',
          'port': data['port'] ?? 9100,
          'paper': data['paper'] ?? 80,
        };
      }
    } catch (e) {
      print('SettingsService loadPrinterSettings Error: $e');
    }
    return {'ip': '192.168.1.100', 'port': 9100, 'paper': 80};
  }

  static Future<void> saveStoreDetails({
    required String name,
    required String address,
    required String contact,
    required String gst,
    required String header,
    required String footer,
    required String logo,
  }) async {
    await ApiClient.post(
      '/settings/store',
      body: {
        'name': name,
        'address': address,
        'contact': contact,
        'gst': gst,
        'header': header,
        'footer': footer,
        'logo': logo,
      },
    );
  }

  static Future<void> savePrinterSettings({
    required String ip,
    required int port,
    required int paper,
  }) async {
    await ApiClient.post(
      '/settings/printer',
      body: {'ip': ip, 'port': port, 'paper': paper},
    );
  }

  static Future<void> saveBluetoothDevice(String address) async {
    await ApiClient.post('/settings/bluetooth', body: {'address': address});
  }

  static Future<String?> loadBluetoothDevice() async {
    try {
      final response = await ApiClient.get('/settings/bluetooth');
      if (response != null && response['data'] != null) {
        return response['data']['address'];
      }
    } catch (e) {
      print('SettingsService loadBluetoothDevice Error: $e');
    }
    return null;
  }
}
