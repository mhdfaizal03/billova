import 'package:shared_preferences/shared_preferences.dart';

class SettingsLocalStore {
  static const String _keyStoreName = 'store_name';
  static const String _keyAddress = 'store_address';
  static const String _keyContact = 'store_contact';
  static const String _keyGst = 'store_gst';
  static const String _keyHeader = 'store_header';
  static const String _keyFooter = 'store_footer';
  static const String _keyLogo = 'store_logo';

  static const String _keyPrinterIp = 'printer_ip';
  static const String _keyPrinterPort = 'printer_port';
  static const String _keyPaperSize = 'paper_size'; // 80 or 58

  // ─────────────────────────────────────────────
  // LOAD
  // ─────────────────────────────────────────────
  static Future<Map<String, String>> loadStoreDetails() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString(_keyStoreName) ?? '',
      'address': prefs.getString(_keyAddress) ?? '',
      'contact': prefs.getString(_keyContact) ?? '',
      'gst': prefs.getString(_keyGst) ?? '',
      'header': prefs.getString(_keyHeader) ?? '',
      'footer': prefs.getString(_keyFooter) ?? '',
      'logo': prefs.getString(_keyLogo) ?? '',
    };
  }

  static Future<Map<String, dynamic>> loadPrinterSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'ip': prefs.getString(_keyPrinterIp) ?? '192.168.1.100',
      'port': prefs.getInt(_keyPrinterPort) ?? 9100,
      'paper': prefs.getInt(_keyPaperSize) ?? 80,
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
    await prefs.setString(_keyStoreName, name);
    await prefs.setString(_keyAddress, address);
    await prefs.setString(_keyContact, contact);
    await prefs.setString(_keyGst, gst);
    await prefs.setString(_keyHeader, header);
    await prefs.setString(_keyFooter, footer);
    await prefs.setString(_keyLogo, logo);
  }

  static Future<void> savePrinterSettings({
    required String ip,
    required int port,
    required int paper,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPrinterIp, ip);
    await prefs.setInt(_keyPrinterPort, port);
    await prefs.setInt(_keyPaperSize, paper);
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
