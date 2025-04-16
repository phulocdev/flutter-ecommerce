import 'package:intl/intl.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final List<String> additionalImages;
  final List<String> reviews;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.additionalImages = const [],
    this.reviews = const [],
  });

  String get formattedPrice {
    final priceFormatter =
        NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
    return priceFormatter.format(price);
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'No Name',
      description: json['description'] as String? ?? 'No Description',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl:
          json['imageUrl'] as String? ?? 'https://via.placeholder.com/250',
    );
  }
}
