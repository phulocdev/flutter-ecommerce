class Sku {
  final String id;
  final int stockQuantity;
  final double costPrice;
  final double sellingPrice;
  final int stockOnHand;
  final List<String> attributeValues;

  Sku({
    required this.id,
    required this.stockQuantity,
    required this.costPrice,
    required this.sellingPrice,
    required this.stockOnHand,
    required this.attributeValues,
  });

  Sku copyWith({
    String? id,
    int? stockQuantity,
    double? costPrice,
    double? sellingPrice,
    int? stockOnHand,
    List<String>? attributeValues,
  }) {
    return Sku(
      id: id ?? this.id,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      costPrice: costPrice ?? this.costPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      stockOnHand: stockOnHand ?? this.stockOnHand,
      attributeValues: attributeValues ?? this.attributeValues,
    );
  }

  String get formattedPrice => '\$${sellingPrice.toStringAsFixed(2)}';
}
