import 'dart:io';
import 'dart:ui';
import 'package:billova/utils/widgets/custom_dialog_box.dart';
import 'package:billova/models/model/models/order_model.dart';
import 'package:billova/utils/constants/colors.dart';
import 'package:billova/utils/local_Storage/sales_local_store.dart';
import 'package:billova/utils/local_Storage/settings_local_store.dart';
import 'package:billova/utils/widgets/curve_screen.dart';
import 'package:billova/utils/widgets/custom_back_button.dart';
import 'package:billova/utils/widgets/custom_buttons.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:billova/utils/widgets/responsive_helper.dart';
import 'package:get/get.dart';
import 'package:billova/utils/networks/printer_helper.dart';
import 'package:billova/utils/widgets/custom_snackbar.dart';
import 'package:billova/utils/constants/sizes.dart';
import 'package:billova/utils/widgets/shimmer_helper.dart';

class SalesPage extends StatefulWidget {
  const SalesPage({super.key});

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  List<OrderModel> _orders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSales();
  }

  Future<void> _loadSales() async {
    final orders = await SalesLocalStore.getOrders();
    // Sort by newest first
    orders.sort((a, b) => b.dateTime.compareTo(a.dateTime));

    if (mounted) {
      setState(() {
        _orders = orders;
        _loading = false;
      });
    }
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
        title: const Text("Sales History"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => CustomDialogBox(
                  title: "Clear History?",
                  content: "This will delete all sales records permanently.",
                  saveText: "Yes, Clear",
                  onSave: () {
                    Navigator.pop(context, true);
                  },
                ),
              );
              if (confirm == true) {
                await SalesLocalStore.clearHistory();
                _loadSales();
              }
            },
          ),
        ],
      ),
      body: CurveScreen(
        child: _loading
            ? ShimmerHelper.buildListShimmer(itemCount: 8, itemHeight: 110)
            : _orders.isEmpty
            ? const Center(
                child: Text(
                  "No sales recorded yet",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
            : GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: ResponsiveHelper.isMobile(context) ? 1 : 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 12,
                  mainAxisExtent: 110, // 📏 Increased for safety
                ),
                itemCount: _orders.length,
                itemBuilder: (context, index) {
                  final order = _orders[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // --- Icon Segment ---
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.receipt_long_rounded,
                            color: primary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 14),

                        // --- Data Segment ---
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Order #${order.id}",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat(
                                  'dd MMM, hh:mm a',
                                ).format(order.dateTime),
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // --- Action Segment ---
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "₹${order.total.toStringAsFixed(2)}",
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                                color: primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            InkWell(
                              onTap: () => _showOrderDetail(order),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: primary.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: primary.withOpacity(0.1),
                                  ),
                                ),
                                child: const Text(
                                  "View Bill",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.brown,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  void _showOrderDetail(OrderModel order) async {
    final store = await SettingsLocalStore.loadStoreDetails();
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.all(20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (store['logo'] != null && store['logo']!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Image.file(
                    File(store['logo']!),
                    height: 50,
                    fit: BoxFit.contain,
                  ),
                ),
              Text(
                store['name']!.isEmpty ? "BILLOVA POS" : store['name']!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),

              const Divider(),
              ...order.items.map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "${item.quantity} x ${item.productName}${item.variantName != null ? ' (${item.variantName})' : ''}",
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text("₹${item.total}"),
                    ],
                  ),
                ),
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Subtotal"),
                  Text(
                    "₹${order.items.fold(0.0, (s, i) => s + i.subtotal).toStringAsFixed(2)}",
                  ), // Using subtotal from ticket item
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Tax"),
                  Text(
                    "₹${order.items.fold(0.0, (s, i) => s + i.taxAmount).toStringAsFixed(2)}",
                  ),
                ],
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "TOTAL",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "₹${order.total.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: CustomButtons(
                  text: const Text("Re-Print Receipt"),
                  onPressed: () {
                    Navigator.pop(context);
                    _showPrinterSelection(order);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showPrinterSelection(OrderModel order) async {
    final settings = await SettingsLocalStore.loadPrinterSettings();
    final btDevice = await SettingsLocalStore.loadBluetoothDevice();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Select Printer for Re-print",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            sh20,
            ListTile(
              leading: const Icon(Icons.wifi, color: Colors.blue),
              title: const Text("Wifi / Network Printer"),
              subtitle: Text(settings['ip'] ?? "Not Configured"),
              onTap: () async {
                Get.back();
                await _rePrint(order, isNetwork: true);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.bluetooth, color: Colors.blue),
              title: const Text("Bluetooth Printer"),
              subtitle: Text(
                btDevice != null ? "Paired Device" : "Not Configured",
              ),
              onTap: () async {
                Get.back();
                await _rePrint(order, isNetwork: false);
              },
            ),
            sh20,
          ],
        ),
      ),
    );
  }

  Future<void> _rePrint(OrderModel order, {required bool isNetwork}) async {
    bool printed = false;
    if (isNetwork) {
      printed = await PrinterHelper.printViaNetwork(order);
    } else {
      printed = await PrinterHelper.printViaBluetooth(order);
    }

    if (printed) {
      if (!mounted) return;
      CustomSnackBar.showSuccess(context, "Receipt sent to printer");
    } else {
      if (!mounted) return;
      CustomSnackBar.showError(context, "Could not connect to printer");
    }
  }
}
