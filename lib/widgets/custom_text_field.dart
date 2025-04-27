import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType keyboardType;
  final bool isPassword;
  final double textFieldHeight;
  final String? Function(String?)? validator;
  final bool enabled;   

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
    this.textFieldHeight = 60.0,
    this.validator,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    const primaryOrange = Color(0xFFFF9800);

    final borderStyle = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: primaryOrange),
    );

    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      validator: validator,
      enabled: enabled,
      style: const TextStyle(
        fontFamily:
            'Roboto',
        fontSize: 16.0, 
        color: Colors.black, 
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 16.0,
          color: primaryOrange,
        ),
        prefixIcon: Icon(icon, color: primaryOrange),
        enabledBorder: borderStyle,
        focusedBorder: borderStyle,
        errorBorder: borderStyle,
        focusedErrorBorder: borderStyle,
      ),
    );
  }
}
