import 'package:flutter/material.dart';

class CustomInput extends StatelessWidget {
  final IconData icon;
  final String hint;
  final TextEditingController controller;
  final bool isPassword;
  final bool readOnly;
  final VoidCallback? onTap;
  final TextInputType? keyboardType;

  const CustomInput({
    super.key,
    required this.icon,
    required this.hint,
    required this.controller,
    this.isPassword = false,
    this.readOnly = false,
    this.onTap,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inputTheme = theme.inputDecorationTheme;
    final fillColor = inputTheme.fillColor ??
        (theme.brightness == Brightness.dark
            ? theme.colorScheme.surfaceVariant
            : Colors.grey[100]);
    final iconColor = inputTheme.prefixIconColor ??
        theme.colorScheme.onSurface.withOpacity(0.7);

    return TextField(
      controller: controller,
      obscureText: isPassword,
      readOnly: readOnly,
      keyboardType: keyboardType,
      onTap: onTap,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: iconColor),
        hintText: hint,
        hintStyle: inputTheme.hintStyle ??
            TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
        filled: true,
        fillColor: fillColor,
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
