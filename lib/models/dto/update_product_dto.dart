import 'package:flutter_ecommerce/models/dto/create_sku_dto.dart';

class UpdateProductDto {
  final String? name;
  final String? description;
  final String? category;
  final String? brand;
  final double? basePrice;
  final int? minStockLevel;
  final double? discountPercentage;
  final int? maxStockLevel;
  final List<String>? attributeNames;
  final List<CreateSkuDto>? skus;
  final String? imageUrl;

  UpdateProductDto({
    this.name,
    this.description,
    this.category,
    this.brand,
    this.basePrice,
    this.discountPercentage,
    this.minStockLevel,
    this.maxStockLevel,
    this.attributeNames,
    this.skus,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (description != null) data['description'] = description;
    if (category != null) data['category'] = category;
    if (brand != null) data['brand'] = brand;
    if (basePrice != null) data['basePrice'] = basePrice;
    if (discountPercentage != null)
      data['discountPercentage'] = discountPercentage;
    if (minStockLevel != null) data['minStockLevel'] = minStockLevel;
    if (maxStockLevel != null) data['maxStockLevel'] = maxStockLevel;
    if (attributeNames != null) data['attributeNames'] = attributeNames;
    if (skus != null) data['skus'] = skus!.map((sku) => sku.toJson()).toList();
    if (imageUrl != null) data['imageUrl'] = imageUrl;
    return data;
  }

  UpdateProductDto copyWith({
    String? name,
    String? description,
    String? category,
    String? brand,
    double? basePrice,
    double? discountPercentage,
    int? minStockLevel,
    int? maxStockLevel,
    List<String>? attributeNames,
    List<CreateSkuDto>? skus,
    String? imageUrl,
  }) {
    return UpdateProductDto(
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      basePrice: basePrice ?? this.basePrice,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      minStockLevel: minStockLevel ?? this.minStockLevel,
      maxStockLevel: maxStockLevel ?? this.maxStockLevel,
      attributeNames: attributeNames ?? this.attributeNames,
      skus: skus ?? this.skus,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
