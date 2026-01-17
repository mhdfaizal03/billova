import 'package:flutter/material.dart';

class CustomField extends StatelessWidget {
  final String text;
  final Widget suffix;
  final bool obscure;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final void Function(String)? onChanged;

  const CustomField({
    super.key,
    required this.text,
    this.suffix = const SizedBox(),
    this.obscure = false,
    this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[300],
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(10),
        ),
        suffixIcon: suffix,
        labelText: text,
      ),
    );
  }
}
