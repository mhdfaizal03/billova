import 'package:flutter/material.dart';

class VanishKeyBoard {
  void vanish(BuildContext context) {
    FocusScope.of(context).unfocus();
  }
}
