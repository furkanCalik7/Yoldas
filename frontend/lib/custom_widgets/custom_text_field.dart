import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField(
      {super.key,
      this.hintText = "",
      this.obscureText = false,
      this.enabled = true,
      required this.validator,
      required this.controller,
      this.icon,
      this.onChanged});

  final String hintText;
  final bool obscureText;
  final Function validator;
  final TextEditingController controller;
  final IconData? icon;
  final bool enabled;
  final Function? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: enabled,
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.black54),
      ),
      validator: (value) => validator(value),
      onChanged: (value) {
        if (onChanged != null) {
          onChanged!(value);
        }
      },
    );
  }
}
