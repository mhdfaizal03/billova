import 'package:billova/utils/constants/colors.dart';
import 'package:billova/utils/widgets/curve_screen.dart';
import 'package:billova/utils/widgets/custom_back_button.dart';
import 'package:billova/view/drawer_items/items/erp_setup/billing_details_page.dart';
import 'package:billova/view/drawer_items/items/erp_setup/printer_settings_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final List<Map<String, dynamic>> _settings = [
    {
      "icon": Icons.business_rounded,
      "title": "Billing Details",
      "subtitle": "Store name, address, GST, and receipt messages",
      "page": () => const BillingDetailsPage(),
    },
    {
      "icon": Icons.print_rounded,
      "title": "Printer Settings",
      "subtitle": "Printer IP, port, and paper size",
      "page": () => const PrinterSettingsPage(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final primary = AppColors().browcolor;

    return Scaffold(
      backgroundColor: primary,
      appBar: AppBar(
        leading: CustomAppBarBack(),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        title: const Text("Settings"),
      ),
      body: CurveScreen(
        child: ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: _settings.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = _settings[index];
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListTile(
                onTap: () => Get.to(item['page']),
                leading: CircleAvatar(
                  backgroundColor: primary.withOpacity(0.1),
                  child: Icon(item['icon'], color: primary),
                ),
                title: Text(
                  item['title'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  item['subtitle'],
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              ),
            );
          },
        ),
      ),
    );
  }
}
