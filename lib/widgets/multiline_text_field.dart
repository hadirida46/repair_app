  import 'package:flutter/material.dart';

  class CustomMultilineTextField extends StatelessWidget {
    final TextEditingController controller;
    final String label;
    final IconData icon;
    final String? Function(String?)? validator;

    const CustomMultilineTextField({
      super.key,
      required this.controller,
      required this.label,
      required this.icon,
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
        validator: validator,
        keyboardType: TextInputType.multiline,
        minLines: 3,
        maxLines: null, 
        style: const TextStyle(
          fontFamily: 'Roboto',
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
