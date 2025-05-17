import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData prefixIcon;
  final TextInputType? keyboardType;
  final bool enabled;
  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.label,
    required this.prefixIcon,
    this.keyboardType,
    this.enabled = true,
    this.maxLines = 1,
    this.inputFormatters,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final borderColor = Colors.grey;
    final errorColor = colorScheme.error;

    return Theme(
      data: theme.copyWith(
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.8)),
          hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.5)),
          errorStyle: TextStyle(color: errorColor),
          hoverColor: Colors.transparent,
        ),
      ),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        maxLines: maxLines,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: TextStyle(color: colorScheme.onSurface),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(prefixIcon,
              color: enabled
                  ? colorScheme.primary
                  : colorScheme.onSurface.withOpacity(0.5)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: borderColor, width: 1.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: borderColor, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.primary, width: 2.0),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: errorColor, width: 1.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: errorColor, width: 2.0),
          ),
          filled: true,
          fillColor: enabled
              ? colorScheme.surface
              : colorScheme.surfaceVariant.withOpacity(0.5),
          hoverColor: Colors.transparent,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          errorMaxLines: 2,
        ),
        validator: validator,
      ),
    );
  }
}
