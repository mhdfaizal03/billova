import 'package:billova/main.dart';
import 'package:flutter/material.dart';

class ConstrainBox extends StatelessWidget {
  Widget child;
  ConstrainBox({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: mq.height * .9,
        minWidth: mq.width,
      ),
      child: child,
    );
  }
}
