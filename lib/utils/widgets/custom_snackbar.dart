import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

class CustomSnackBar {
  static void show({
    required BuildContext context,
    required String message,
    Color color = Colors.black,
    IconData icon = Icons.info_outline,
  }) {
    Flushbar(
      isDismissible: true,
      message: message,
      backgroundColor: color,
      flushbarPosition: FlushbarPosition.TOP,
      duration: Duration(milliseconds: 2000),
      margin: EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(8),
      icon: Icon(icon, color: Colors.white),
    )..show(context);
  }
}
