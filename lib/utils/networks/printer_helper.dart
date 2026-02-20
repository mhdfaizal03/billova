import 'dart:io';
import 'package:billova/models/model/models/order_model.dart';
import 'package:billova/data/services/settings_service.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:esc_pos_printer_plus/esc_pos_printer_plus.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:image/image.dart' as img;

class PrinterHelper {
  // --- Network Printing ---
  static Future<bool> printViaNetwork(OrderModel order) async {
    try {
      final settings = await SettingsService.loadPrinterSettings();
      final store = await SettingsService.loadStoreDetails();

      final String ip = settings['ip'] ?? "";
      final int port = settings['port'] ?? 9100;
      final int paperSize = settings['paper'] ?? 80;

      if (ip.isEmpty) return false;

      final profile = await CapabilityProfile.load();
      final printer = NetworkPrinter(
        paperSize == 80 ? PaperSize.mm80 : PaperSize.mm58,
        profile,
      );

      // Add timeout to connect
      final PosPrintResult res = await printer.connect(
        ip,
        port: port,
        timeout: const Duration(seconds: 5),
      );

      if (res == PosPrintResult.success) {
        await _generateNetworkTicket(printer, order, store, paperSize);
        printer.disconnect();
        return true;
      }
      return false;
    } catch (e) {
      print("Network Print Error: $e");
      return false;
    }
  }

  // --- Test Print ---
  static Future<bool> testPrint({required bool isNetwork}) async {
    try {
      final settings = await SettingsService.loadPrinterSettings();
      final int paperSize = settings['paper'] ?? 80;
      final profile = await CapabilityProfile.load();

      if (isNetwork) {
        final String ip = settings['ip'] ?? "";
        final int port = settings['port'] ?? 9100;
        if (ip.isEmpty) return false;

        final printer = NetworkPrinter(
          paperSize == 80 ? PaperSize.mm80 : PaperSize.mm58,
          profile,
        );
        final res = await printer.connect(
          ip,
          port: port,
          timeout: const Duration(seconds: 4),
        );
        if (res == PosPrintResult.success) {
          printer.text(
            "TEST PRINT SUCCESS!",
            styles: const PosStyles(
              align: PosAlign.center,
              bold: true,
              height: PosTextSize.size2,
              width: PosTextSize.size2,
            ),
          );
          printer.feed(2);
          printer.cut();
          printer.disconnect();
          return true;
        }
        return false;
      } else {
        // Bluetooth
        bool isConnected = await PrintBluetoothThermal.connectionStatus;
        if (!isConnected) {
          final address =
              settings['bluetooth_device_address'] ??
              await SettingsService.loadBluetoothDevice();
          if (address == null) return false;
          bool connected = await PrintBluetoothThermal.connect(
            macPrinterAddress: address,
          );
          if (!connected) return false;
        }

        final generator = Generator(
          paperSize == 80 ? PaperSize.mm80 : PaperSize.mm58,
          profile,
        );
        List<int> bytes = [];
        bytes.addAll(
          generator.text(
            "TEST PRINT SUCCESS!",
            styles: const PosStyles(
              align: PosAlign.center,
              bold: true,
              height: PosTextSize.size2,
              width: PosTextSize.size2,
            ),
          ),
        );
        bytes.addAll(generator.feed(2));
        bytes.addAll(generator.cut());
        return await PrintBluetoothThermal.writeBytes(bytes);
      }
    } catch (e) {
      return false;
    }
  }

  static Future<void> _generateNetworkTicket(
    NetworkPrinter printer,
    OrderModel order,
    Map<String, String> store,
    int paperSize,
  ) async {
    // Logo
    if (store['logo'] != null && store['logo']!.isNotEmpty) {
      final File file = File(store['logo']!);
      if (await file.exists()) {
        final img.Image? image = img.decodeImage(await file.readAsBytes());
        if (image != null) {
          final img.Image resized = img.copyResize(image, width: 200);
          printer.image(resized);
        }
      }
    }

    printer.text(
      store['name']?.toUpperCase() ?? "BILLOVA POS",
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );

    if (store['address']!.isNotEmpty) {
      printer.text(
        store['address']!,
        styles: const PosStyles(align: PosAlign.center),
      );
    }
    if (store['contact']!.isNotEmpty) {
      printer.text(
        "Contact: ${store['contact']}",
        styles: const PosStyles(align: PosAlign.center),
      );
    }
    if (store['gst']!.isNotEmpty) {
      printer.text(
        "GST: ${store['gst']}",
        styles: const PosStyles(align: PosAlign.center),
      );
    }

    printer.hr();
    printer.text("Order: ${order.id}", styles: const PosStyles(bold: true));
    printer.text("Date: ${order.dateTime.toString().split('.')[0]}");
    printer.hr();

    // Items
    for (var item in order.items) {
      printer.row([
        PosColumn(text: "${item.quantity}x ${item.productName}", width: 9),
        PosColumn(
          text: item.total.toString(),
          width: 3,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }

    printer.hr();

    // Subtotal & Tax
    double subtotal = order.items.fold(0, (s, i) => s + i.subtotal);
    double taxTotal = order.items.fold(0.0, (s, i) => s + i.taxAmount);

    printer.row([
      PosColumn(
        text: "Subtotal",
        width: 6,
        styles: const PosStyles(bold: false),
      ),
      PosColumn(
        text: subtotal.toStringAsFixed(0),
        width: 6,
        styles: const PosStyles(align: PosAlign.right, bold: false),
      ),
    ]);

    printer.row([
      PosColumn(text: "Tax", width: 6, styles: const PosStyles(bold: false)),
      PosColumn(
        text: taxTotal.toStringAsFixed(2),
        width: 6,
        styles: const PosStyles(align: PosAlign.right, bold: false),
      ),
    ]);

    printer.hr();
    printer.row([
      PosColumn(
        text: "TOTAL",
        width: 6,
        styles: const PosStyles(bold: true, height: PosTextSize.size2),
      ),
      PosColumn(
        text: order.total.toString(),
        width: 6,
        styles: const PosStyles(
          align: PosAlign.right,
          bold: true,
          height: PosTextSize.size2,
        ),
      ),
    ]);
    printer.hr();

    if (store['footer']!.isNotEmpty) {
      printer.feed(1);
      printer.text(
        store['footer']!,
        styles: const PosStyles(align: PosAlign.center),
      );
    }

    printer.feed(2);
    printer.cut();
  }

  // --- Bluetooth Printing ---
  static Future<bool> printViaBluetooth(OrderModel order) async {
    try {
      bool isConnected = await PrintBluetoothThermal.connectionStatus;
      if (!isConnected) {
        final address = await SettingsService.loadBluetoothDevice();
        if (address == null) return false;

        bool connected = await PrintBluetoothThermal.connect(
          macPrinterAddress: address,
        );
        if (!connected) return false;
      }

      final store = await SettingsService.loadStoreDetails();
      final settings = await SettingsService.loadPrinterSettings();
      final int paperSize = settings['paper'] ?? 80;

      final profile = await CapabilityProfile.load();
      final generator = Generator(
        paperSize == 80 ? PaperSize.mm80 : PaperSize.mm58,
        profile,
      );
      List<int> bytes = [];

      // Logo
      if (store['logo'] != null && store['logo']!.isNotEmpty) {
        final File file = File(store['logo']!);
        if (await file.exists()) {
          final img.Image? image = img.decodeImage(await file.readAsBytes());
          if (image != null) {
            final img.Image resized = img.copyResize(image, width: 200);
            bytes.addAll(generator.image(resized));
          }
        }
      }

      bytes.addAll(
        generator.text(
          store['name']?.toUpperCase() ?? "BILLOVA POS",
          styles: const PosStyles(
            align: PosAlign.center,
            bold: true,
            height: PosTextSize.size2,
            width: PosTextSize.size2,
          ),
        ),
      );

      if (store['address']!.isNotEmpty) {
        bytes.addAll(
          generator.text(
            store['address']!,
            styles: const PosStyles(align: PosAlign.center),
          ),
        );
      }
      if (store['contact']!.isNotEmpty) {
        bytes.addAll(
          generator.text(
            "Contact: ${store['contact']}",
            styles: const PosStyles(align: PosAlign.center),
          ),
        );
      }

      bytes.addAll(generator.hr());
      bytes.addAll(
        generator.text(
          "Order: ${order.id}",
          styles: const PosStyles(bold: true),
        ),
      );
      bytes.addAll(generator.hr());

      for (var item in order.items) {
        bytes.addAll(
          generator.row([
            PosColumn(text: "${item.quantity}x ${item.productName}", width: 9),
            PosColumn(
              text: item.total.toString(),
              width: 3,
              styles: const PosStyles(align: PosAlign.right),
            ),
          ]),
        );
      }

      bytes.addAll(generator.hr());

      // Subtotal & Tax values
      double subtotal = order.items.fold(0, (s, i) => s + i.subtotal);
      double taxTotal = order.items.fold(0.0, (s, i) => s + i.taxAmount);

      bytes.addAll(
        generator.row([
          PosColumn(text: "Subtotal", width: 6),
          PosColumn(
            text: subtotal.toStringAsFixed(0),
            width: 6,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ]),
      );

      bytes.addAll(
        generator.row([
          PosColumn(text: "Tax", width: 6),
          PosColumn(
            text: taxTotal.toStringAsFixed(2),
            width: 6,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ]),
      );

      bytes.addAll(generator.hr());
      bytes.addAll(
        generator.text(
          "TOTAL: ${order.total}",
          styles: const PosStyles(
            align: PosAlign.right,
            bold: true,
            height: PosTextSize.size2,
          ),
        ),
      );
      bytes.addAll(generator.hr());

      if (store['footer']!.isNotEmpty) {
        bytes.addAll(generator.feed(1));
        bytes.addAll(
          generator.text(
            store['footer']!,
            styles: const PosStyles(align: PosAlign.center),
          ),
        );
      }

      bytes.addAll(generator.feed(2));
      bytes.addAll(generator.cut());

      return await PrintBluetoothThermal.writeBytes(bytes);
    } catch (e) {
      return false;
    }
  }
}
