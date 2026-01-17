import 'package:billova/utils/constants/colors.dart';
import 'package:billova/utils/constants/sizes.dart';
import 'package:billova/utils/local_Storage/settings_local_store.dart';
import 'package:billova/utils/widgets/curve_screen.dart';
import 'package:billova/utils/widgets/custom_back_button.dart';
import 'package:billova/utils/widgets/custom_buttons.dart';
import 'package:billova/utils/widgets/custom_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:permission_handler/permission_handler.dart';

class PrinterSettingsPage extends StatefulWidget {
  const PrinterSettingsPage({super.key});

  @override
  State<PrinterSettingsPage> createState() => _PrinterSettingsPageState();
}

class _PrinterSettingsPageState extends State<PrinterSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _ipCtr = TextEditingController();
  final _portCtr = TextEditingController();
  int _selectedPaperSize = 80;

  // Bluetooth
  List<BluetoothInfo> _devices = [];
  BluetoothInfo? _selectedDevice;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await SettingsLocalStore.loadPrinterSettings();
    _ipCtr.text = data['ip'].toString();
    _portCtr.text = data['port'].toString();
    _selectedPaperSize = data['paper'] as int;

    // Load saved BT device
    final savedAddress = await SettingsLocalStore.loadBluetoothDevice();
    await _loadDevices(savedAddress);

    if (mounted) setState(() => _loading = false);
  }

  Future<void> _loadDevices([String? savedAddress]) async {
    // Request permissions
    await [
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.location,
    ].request();

    final allDevices = await PrintBluetoothThermal.pairedBluetooths;
    _devices = allDevices
        .where(
          (d) =>
              d.name.toLowerCase().contains("printer") ||
              d.name.toLowerCase().contains("thermal") ||
              d.name.toLowerCase().contains("pos") ||
              d.name.toLowerCase().contains("mtp") ||
              d.name.toLowerCase().contains("rpp"),
        )
        .toList();
    if (savedAddress != null) {
      try {
        _selectedDevice = _devices.firstWhere(
          (d) => d.macAdress == savedAddress,
        );
      } catch (_) {}
    }
    if (mounted) setState(() {});
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    await SettingsLocalStore.savePrinterSettings(
      ip: _ipCtr.text,
      port: int.tryParse(_portCtr.text) ?? 9100,
      paper: _selectedPaperSize,
    );

    if (_selectedDevice != null) {
      await SettingsLocalStore.saveBluetoothDevice(_selectedDevice!.macAdress);
    }

    setState(() => _loading = false);
    Get.snackbar(
      "Success",
      "Printer settings saved",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppColors().browcolor;

    return Scaffold(
      backgroundColor: primary,
      appBar: AppBar(
        leading: CustomAppBarBack(),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        title: const Text("Printer Configuration"),
      ),
      body: CurveScreen(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionTitle("WiFi / Network Printer"),
                          sh10,
                          CustomField(
                            text: "Printer IP Address",
                            controller: _ipCtr,
                            keyboardType: TextInputType.number,
                          ),
                          sh10,
                          CustomField(
                            text: "Port (Default 9100)",
                            controller: _portCtr,
                            keyboardType: TextInputType.number,
                          ),

                          sh20,
                          const Divider(),
                          sh20,

                          _sectionTitle("Bluetooth Printer"),
                          sh10,
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<BluetoothInfo>(
                                isExpanded: true,
                                hint: const Text("Select Bluetooth Printer"),
                                value: _selectedDevice,
                                items: _devices
                                    .map(
                                      (d) => DropdownMenuItem(
                                        value: d,
                                        child: Text(
                                          d.name.isEmpty
                                              ? "Unknown Device"
                                              : d.name,
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (val) =>
                                    setState(() => _selectedDevice = val),
                              ),
                            ),
                          ),
                          if (_devices.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0, left: 4),
                              child: Text(
                                "No paired devices found. Pair in phone settings first.",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ),

                          sh20,
                          const Divider(),
                          sh20,

                          _sectionTitle("Paper Size"),
                          Row(
                            children: [
                              Expanded(
                                child: RadioListTile<int>(
                                  title: const Text("80mm"),
                                  value: 80,
                                  groupValue: _selectedPaperSize,
                                  onChanged: (val) =>
                                      setState(() => _selectedPaperSize = val!),
                                ),
                              ),
                              Expanded(
                                child: RadioListTile<int>(
                                  title: const Text("58mm"),
                                  value: 58,
                                  groupValue: _selectedPaperSize,
                                  onChanged: (val) =>
                                      setState(() => _selectedPaperSize = val!),
                                ),
                              ),
                            ],
                          ),

                          sh30,
                          SizedBox(
                            height: 50,
                            width: double.infinity,
                            child: CustomButtons(
                              text: const Text("Save Configuration"),
                              onPressed: _save,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }
}
