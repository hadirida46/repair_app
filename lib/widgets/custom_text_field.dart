import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType keyboardType;
  final bool isPassword;
  final double textFieldHeight;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
    this.textFieldHeight = 60.0,
    this.validator,
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
      style: const TextStyle(
        fontFamily:
            'Roboto', // Use a regular font like 'Roboto' for normal input
        fontSize: 16.0, // Regular font size
        color: Colors.black, // Regular black color for input text
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          fontFamily: 'Roboto', // Ensure the label also uses the regular font
          fontSize: 16.0, // Regular font size for label
          color: primaryOrange, // Orange color for label
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
