import 'package:intl/intl.dart';

class CreateSkuDto {
  // final int stockQuantity;
  final double costPrice;
  final double sellingPrice;
  final int stockOnHand;
  final List<String> attributeValues;
  final String? imageUrl;

  CreateSkuDto({
    // required this.stockQuantity,
    required this.costPrice,
    required this.sellingPrice,
    required this.stockOnHand,
    required this.attributeValues,
    this.imageUrl,
  });

  CreateSkuDto copyWith({
    // int? stockQuantity,
    double? costPrice,
    double? sellingPrice,
    int? stockOnHand,
    List<String>? attributeValues,
    String? imageUrl,
  }) {
    return CreateSkuDto(
      // stockQuantity: stockQuantity ?? this.stockQuantity,
      costPrice: costPrice ?? this.costPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      stockOnHand: stockOnHand ?? this.stockOnHand,
      attributeValues: attributeValues ?? this.attributeValues,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  String get formattedPrice {
    final formatter =
        NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
    return formatter.format(sellingPrice);
  }

  Map<String, dynamic> toJson() {
    return {
      // 'stockQuantity': stockQuantity,
      'costPrice': costPrice,
      'sellingPrice': sellingPrice,
      'stockOnHand': stockOnHand,
      'attributeValues': attributeValues,
      'imageUrl': imageUrl,
    };
  }
}
