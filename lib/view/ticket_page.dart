import 'dart:io';
import 'package:billova/models/model/models/ticket_item_model.dart';
import 'package:billova/models/model/models/order_model.dart';
import 'package:billova/utils/local_Storage/sales_local_store.dart';
import 'package:billova/utils/local_Storage/settings_local_store.dart';
import 'package:billova/utils/networks/printer_helper.dart';
import 'package:billova/utils/constants/colors.dart';
import 'package:billova/utils/constants/sizes.dart';
import 'package:billova/utils/widgets/curve_screen.dart';
import 'package:billova/utils/widgets/custom_back_button.dart';
import 'package:billova/utils/widgets/custom_buttons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:billova/view/home/home_screen.dart';

class TicketPage extends StatefulWidget {
  final List<TicketItem> items;

  const TicketPage({super.key, required this.items});

  @override
  State<TicketPage> createState() => _TicketPageState();
}

class _TicketPageState extends State<TicketPage> {
  late List<TicketItem> items;

  @override
  void initState() {
    super.initState();
    items = widget.items.map((e) => e.copy()).toList();
  }

  int get totalAmount => items.fold(0, (sum, item) => sum + item.total);

  void _increaseQty(int index) {
    setState(() => items[index].quantity++);
  }

  void _decreaseQty(int index) {
    setState(() {
      if (items[index].quantity > 1) {
        items[index].quantity--;
      } else {
        items.removeAt(index);
      }
    });
  }

  Future<void> _confirmCancelOrder() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancel order?'),
        content: const Text(
          'This will remove all items in the ticket. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Yes, Cancel',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      Get.back(result: <TicketItem>[]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppColors().browcolor;

    return Scaffold(
      backgroundColor: primary,
      appBar: AppBar(
        leading: CustomAppBarBack(onTap: () => Get.back(result: items)),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Items",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: _confirmCancelOrder,
            child: const Text(
              'Cancel Order',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: CurveScreen(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              children: [
                Expanded(
                  child: items.isEmpty
                      ? const Center(
                          child: Text(
                            'No items added',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.only(top: 8),
                          itemCount: items.length,
                          separatorBuilder: (_, __) => const Divider(
                            height: 10,
                            endIndent: 20,
                            indent: 20,
                            thickness: 0.8,
                          ),
                          itemBuilder: (_, i) {
                            final item = items[i];

                            return Dismissible(
                              key: ValueKey(
                                '${item.productName}_${item.variantName}_${item.price}',
                              ),
                              direction: DismissDirection.endToStart,
                              confirmDismiss: (_) async {
                                return await _showDeleteConfirm(context, item);
                              },
                              background: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                alignment: Alignment.centerRight,
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(.9),
                                  borderRadius: BorderRadius.circular(0),
                                ),
                                child: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.white,
                                  size: 26,
                                ),
                              ),
                              onDismissed: (_) {
                                setState(() {
                                  items.removeAt(i);
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.variantName != null
                                                ? '${item.productName} (${item.variantName})'
                                                : item.productName,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '₹${item.price}',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      height: 34,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: primary.withOpacity(.3),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          _qtyButton(
                                            icon: Icons.remove,
                                            onTap: () => _decreaseQty(i),
                                          ),
                                          QtyEditable(
                                            value: item.quantity,
                                            onChanged: (v) {
                                              setState(() => item.quantity = v);
                                            },
                                          ),
                                          _qtyButton(
                                            icon: Icons.add,
                                            onTap: () => _increaseQty(i),
                                          ),
                                        ],
                                      ),
                                    ),
                                    sw10,
                                    SizedBox(
                                      width: 60,
                                      child: Text(
                                        '₹${item.total}',
                                        textAlign: TextAlign.end,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  decoration: BoxDecoration(
                    color: AppColors().creamcolor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.08),
                        blurRadius: 10,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'TOTAL',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '₹$totalAmount',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      sh10,
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 44,
                              child: CustomButtons(
                                onPressed: items.isEmpty
                                    ? null
                                    : () {
                                        Get.back(result: items);
                                      },
                                text: const Text('Save'),
                              ),
                            ),
                          ),
                          sw10,
                          Expanded(
                            child: SizedBox(
                              height: 44,
                              child: CustomButtons(
                                onPressed: items.isEmpty
                                    ? null
                                    : _showReceiptPreview,
                                text: const Text('Charge'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showReceiptPreview() async {
    final store = await SettingsLocalStore.loadStoreDetails();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
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
                    height: 60,
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
              if (store['address']!.isNotEmpty) Text(store['address']!),
              if (store['contact']!.isNotEmpty)
                Text("Tel: ${store['contact']}"),
              if (store['gst']!.isNotEmpty) Text("GST: ${store['gst']}"),
              const Divider(thickness: 1, height: 30),
              ...items.map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          "${item.quantity} x ${item.productName}${item.variantName != null ? ' (${item.variantName})' : ''}",
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      Text(
                        "₹${item.total}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(thickness: 1, height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "GRAND TOTAL",
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                  Text(
                    "₹$totalAmount",
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (store['footer']!.isNotEmpty)
                Text(
                  store['footer']!,
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: CustomButtons(
                  text: const Text("Print & Pay"),
                  onPressed: () async {
                    Navigator.pop(context);

                    final order = OrderModel(
                      id: "ORD-${DateTime.now().millisecondsSinceEpoch}",
                      items: items,
                      total: totalAmount,
                      dateTime: DateTime.now(),
                    );

                    await _showPrinterSelection(order);
                  },
                ),
              ),
            ],
          ),
        );
      },
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
              "Select Printer",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            sh20,
            ListTile(
              leading: const Icon(Icons.wifi, color: Colors.blue),
              title: const Text("Wifi / Network Printer"),
              subtitle: Text(settings['ip'] ?? "Not Configured"),
              onTap: () async {
                Get.back();
                await _processPayment(order, isNetwork: true);
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
                await _processPayment(order, isNetwork: false);
              },
            ),
            sh20,
          ],
        ),
      ),
    );
  }

  Future<void> _processPayment(
    OrderModel order, {
    required bool isNetwork,
  }) async {
    bool printed = false;
    if (isNetwork) {
      printed = await PrinterHelper.printViaNetwork(order);
    } else {
      printed = await PrinterHelper.printViaBluetooth(order);
    }

    await SalesLocalStore.saveOrder(order);

    Get.snackbar(
      printed ? "Payment Success" : "Payment Success (Print Failed)",
      printed
          ? "Receipt printed and saved"
          : "Order saved but printer not found",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: printed ? Colors.green : Colors.orange,
      colorText: Colors.white,
    );
    Get.offAll(() => HomeScreen()); // Navigate back to home and clear ticket
  }

  Future<bool> _showDeleteConfirm(BuildContext context, TicketItem item) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Remove item?'),
            content: Text(
              item.variantName != null
                  ? '${item.productName} (${item.variantName})'
                  : item.productName,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  Widget _qtyButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 34,
        height: 34,
        child: Icon(icon, size: 18, color: AppColors().browcolor),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class QtyEditable extends StatefulWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const QtyEditable({super.key, required this.value, required this.onChanged});

  @override
  State<QtyEditable> createState() => _QtyEditableState();
}

class _QtyEditableState extends State<QtyEditable> {
  late TextEditingController _ctr;
  late FocusNode _focusNode;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    _ctr = TextEditingController(text: widget.value.toString());
    _focusNode = FocusNode();

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _editing) {
        _submit();
      }
    });
  }

  @override
  void didUpdateWidget(covariant QtyEditable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_editing) {
      _ctr.text = widget.value.toString();
    }
  }

  void _submit() {
    final v = int.tryParse(_ctr.text) ?? widget.value;
    final safe = v < 1 ? 1 : v;

    _ctr.text = safe.toString();
    widget.onChanged(safe);

    setState(() => _editing = false);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 36,
      child: _editing
          ? TextField(
              controller: _ctr,
              focusNode: _focusNode,
              autofocus: true,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (value) {
                final v = int.tryParse(value);
                if (v != null && v > 0) {
                  widget.onChanged(v);
                }
              },
              onSubmitted: (_) => _submit(),
            )
          : GestureDetector(
              onTap: () {
                setState(() => _editing = true);
                Future.delayed(Duration.zero, () => _focusNode.requestFocus());
              },
              child: Center(
                child: Text(
                  widget.value.toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _ctr.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
