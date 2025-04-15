import 'package:intl/intl.dart';

class Product {
  final String id;
  final String name;
  final String imageUrl;
  final double price;
  final String description;

  Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.description,
  });

  String get formattedPrice {
    final priceFormatter =
        NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
    return priceFormatter.format(price);
  }
}