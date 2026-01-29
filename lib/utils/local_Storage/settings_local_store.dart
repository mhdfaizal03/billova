import 'package:shared_preferences/shared_preferences.dart';
import 'package:billova/utils/local_Storage/token_storage.dart';

class SettingsLocalStore {
  static const String _baseStoreName = 'store_name';
  static const String _baseAddress = 'store_address';
  static const String _baseContact = 'store_contact';
  static const String _baseGst = 'store_gst';
  static const String _baseHeader = 'store_header';
  static const String _baseFooter = 'store_footer';
  static const String _baseLogo = 'store_logo';

  static const String _keyPrinterIp = 'printer_ip';
  static const String _keyPrinterPort = 'printer_port';
  static const String _keyPaperSize = 'paper_size'; // 80 or 58

  static Future<String> _key(String base) async {
    final storeId = await TokenStorage.getSelectedStore();
    return '${base}_${storeId ?? 'default'}';
  }

  // ─────────────────────────────────────────────
  // LOAD
  // ─────────────────────────────────────────────
  static Future<Map<String, String>> loadStoreDetails() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString(await _key(_baseStoreName)) ?? '',
      'address': prefs.getString(await _key(_baseAddress)) ?? '',
      'contact': prefs.getString(await _key(_baseContact)) ?? '',
      'gst': prefs.getString(await _key(_baseGst)) ?? '',
      'header': prefs.getString(await _key(_baseHeader)) ?? '',
      'footer': prefs.getString(await _key(_baseFooter)) ?? '',
      'logo': prefs.getString(await _key(_baseLogo)) ?? '',
    };
  }

  static Future<Map<String, dynamic>> loadPrinterSettings() async {
    final prefs = await SharedPreferences.getInstance();
    // Use store-specific keys if possible, effectively making printer settings per-store
    // We reuse the _key helper to generate keys like 'printer_ip_store123'
    final ipKey = await _key(_keyPrinterIp);
    final portKey = await _key(_keyPrinterPort);
    final paperKey = await _key(_keyPaperSize);

    return {
      'ip': prefs.getString(ipKey) ?? '192.168.1.100',
      'port': prefs.getInt(portKey) ?? 9100,
      'paper': prefs.getInt(paperKey) ?? 80,
    };
  }

  // ─────────────────────────────────────────────
  // SAVE
  // ─────────────────────────────────────────────
  static Future<void> saveStoreDetails({
    required String name,
    required String address,
    required String contact,
    required String gst,
    required String header,
    required String footer,
    required String logo,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(await _key(_baseStoreName), name);
    await prefs.setString(await _key(_baseAddress), address);
    await prefs.setString(await _key(_baseContact), contact);
    await prefs.setString(await _key(_baseGst), gst);
    await prefs.setString(await _key(_baseHeader), header);
    await prefs.setString(await _key(_baseFooter), footer);
    await prefs.setString(await _key(_baseLogo), logo);
  }

  static Future<void> savePrinterSettings({
    required String ip,
    required int port,
    required int paper,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(await _key(_keyPrinterIp), ip);
    await prefs.setInt(await _key(_keyPrinterPort), port);
    await prefs.setInt(await _key(_keyPaperSize), paper);
  }

  static const String _keyBluetoothDevice = 'bluetooth_device_address';

  static Future<void> saveBluetoothDevice(String address) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyBluetoothDevice, address);
  }

  static Future<String?> loadBluetoothDevice() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyBluetoothDevice);
  }
}
