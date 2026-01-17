import 'package:billova/utils/constants/colors.dart';
import 'package:flutter/material.dart';

class CustomButtons extends StatelessWidget {
  final Function()? onPressed;
  final Widget text;
  const CustomButtons({super.key, required this.onPressed, required this.text});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      minWidth: double.infinity,
      height: 60,
      color: AppColors().browcolor,
      textColor: AppColors().lighttextColor,
      onPressed: onPressed,
      child: text,
    );
  }
}
