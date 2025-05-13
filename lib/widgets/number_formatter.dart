import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Custom TextEditingController that formats numbers with commas
class NumberFormattingController extends TextEditingController {
  final bool decimal;
  // final String locale;

  NumberFormattingController({String? text, this.decimal = false})
      : super(text: text);

  // NumberFormattingController({
  //   String? text,
  //   this.decimal = false,
  //   this.locale = 'vi_VN',
  // }) : super(text: text);

  final NumberFormat _formatter = NumberFormat.decimalPattern('vi_VN');

  String _formatValue(String text) {
    if (text.isEmpty) return '';

    // Remove all non-digit characters except decimal point if allowed
    String digitsOnly = decimal
        ? text.replaceAll(RegExp(r'[^\d.]'), '')
        : text.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.isEmpty) return '';

    // Handle decimal numbers
    if (decimal && digitsOnly.contains('.')) {
      List<String> parts = digitsOnly.split('.');
      if (parts.length > 1) {
        // Format the whole number part
        double value = double.tryParse(parts[0]) ?? 0;
        String formattedWhole = _formatter.format(value);

        // Keep the decimal part as is (up to 2 decimal places)
        String decimalPart = parts[1];
        if (decimalPart.length > 2) {
          decimalPart = decimalPart.substring(0, 2);
        }

        return '$formattedWhole.$decimalPart';
      }
    }

    // Format whole numbers
    double value = double.tryParse(digitsOnly) ?? 0;
    return _formatter.format(value);
  }

  double get numericValue {
    if (text.isEmpty) return 0;
    // Remove all non-numeric characters except decimal point
    final cleanText = text.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(cleanText) ?? 0;
  }

  int get intValue {
    return numericValue.toInt();
  }
  // // Get the raw numeric value without formatting
  // double get numericValue {
  //   // Remove all non-digit characters except decimal point
  //   String digitsOnly = text.replaceAll(RegExp(r'[^\d.]'), '');
  //   return double.tryParse(digitsOnly) ?? 0;
  // }

  // // Get the raw integer value without formatting
  // int get intValue {
  //   // Remove all non-digit characters
  //   String digitsOnly = text.replaceAll(RegExp(r'[^\d]'), '');
  //   return int.tryParse(digitsOnly) ?? 0;
  // }

  @override
  set text(String newText) {
    String formattedText = _formatValue(newText);
    value = value.copyWith(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
      composing: TextRange.empty,
    );
  }
}

// Custom TextInputFormatter for number formatting
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  final bool allowDecimal;

  ThousandsSeparatorInputFormatter({this.allowDecimal = false});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Handle selection and deletion
    if (newValue.text.length < oldValue.text.length) {
      return newValue;
    }

    // Remove all non-digit characters except decimal point if allowed
    String digitsOnly = allowDecimal
        ? newValue.text.replaceAll(RegExp(r'[^\d.]'), '')
        : newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Handle decimal numbers
    if (allowDecimal && digitsOnly.contains('.')) {
      List<String> parts = digitsOnly.split('.');
      if (parts.length > 2) {
        // More than one decimal point - keep only the first one
        digitsOnly = '${parts[0]}.${parts[1]}';
      }

      // Format the whole number part
      String wholeNumber = parts[0];
      String formattedWholeNumber = _formatNumber(wholeNumber);

      // Keep the decimal part as is (up to 2 decimal places)
      String decimalPart = parts.length > 1 ? parts[1] : '';
      if (decimalPart.length > 2) {
        decimalPart = decimalPart.substring(0, 2);
      }

      String formattedText = decimalPart.isEmpty
          ? formattedWholeNumber
          : '$formattedWholeNumber.$decimalPart';

      return TextEditingValue(
        text: formattedText,
        selection: TextSelection.collapsed(offset: formattedText.length),
      );
    }

    // Format whole numbers
    String formattedText = _formatNumber(digitsOnly);

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }

  String _formatNumber(String value) {
    // Convert to numeric value and format with thousands separators
    if (value.isEmpty) return '';

    final formatter = NumberFormat('#,###', 'vi_VN');
    final numericValue = int.tryParse(value) ?? 0;
    return formatter.format(numericValue);
  }
}
