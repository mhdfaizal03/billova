import 'package:billova/utils/constants/colors.dart';
import 'package:billova/utils/widgets/curve_screen.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors().browcolor,
      body: CurveScreen(
        child: Column(),
      ),
    );
  }
}