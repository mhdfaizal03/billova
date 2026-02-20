import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

class CustomSnackBar {
  // New API: For Flushbar style
  static void showFlushbar(
    BuildContext context, {
    required String title,
    required String message,
    Color? backgroundColor,
    IconData? icon,
    int durationSeconds = 3,
  }) {
    Flushbar(
      title: title,
      message: message,
      icon: Icon(icon ?? Icons.info_outline, size: 28.0, color: Colors.white),
      backgroundColor: backgroundColor ?? Colors.black87,
      duration: Duration(seconds: durationSeconds),
      flushbarPosition: FlushbarPosition.TOP,
      margin: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
    ).show(context);
  }

  // Legacy/Existing API Match
  // existing call: CustomSnackBar.show(context: context, message: '...', color: ...)
  static void show({
    required BuildContext context,
    required String message,
    Color? color,
  }) {
    showFlushbar(
      context,
      title: "Notification",
      message: message,
      backgroundColor: color,
    );
  }

  static void showSuccess(BuildContext context, String message) {
    showFlushbar(
      context,
      title: "Success",
      message: message,
      backgroundColor: Colors.green.shade600,
      icon: Icons.check_circle_outline,
    );
  }

  static void showError(BuildContext context, String message) {
    showFlushbar(
      context,
      title: "Error",
      message: message,
      backgroundColor: Colors.red.shade600,
      icon: Icons.error_outline,
    );
  }

  static void showWarning(BuildContext context, String message) {
    showFlushbar(
      context,
      title: "Warning",
      message: message,
      backgroundColor: Colors.orange.shade700,
      icon: Icons.warning_amber_outlined,
    );
  }
}
