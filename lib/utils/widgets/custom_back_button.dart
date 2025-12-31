import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class CustomBackButton extends StatelessWidget {
  Function()? onTap;
  CustomBackButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => Get.back(closeOverlays: true),
      child: SafeArea(
        child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[300],
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          child: Center(
            child: Icon(Icons.keyboard_arrow_left, weight: 30, size: 18),
          ),
        ),
      ),
    );
  }
}

class CustomAppBarBack extends StatelessWidget {
  Function()? onTap;
  CustomAppBarBack({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: GestureDetector(
        onTap: onTap ?? () => Get.back(),
        child: CircleAvatar(child: Icon(Icons.keyboard_arrow_left)),
      ),
    );
  }
}
