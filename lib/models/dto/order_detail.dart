class OrderDetail {
  final String id;
  final int quantity;
  final String order;
  final int sellingPrice;
  final int costPrice;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Sku sku;

  OrderDetail({
    required this.id,
    required this.quantity,
    required this.sellingPrice,
    required this.order,
    required this.costPrice,
    required this.createdAt,
    required this.updatedAt,
    required this.sku,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      id: json['_id'] as String,
      quantity: json['quantity'] as int,
      order: json['order'] as String,
      sellingPrice: json['sellingPrice'] as int,
      costPrice: json['costPrice'] as int,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      sku: Sku.fromJson(json['sku']),
    );
  }
}

class Sku {
  final String id;
  final String sku;
  final String barcode;
  final int costPrice;
  final int sellingPrice;
  final int stockOnHand;
  final String imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Attribute> attributes;
  final Product product;

  Sku({
    required this.id,
    required this.sku,
    required this.barcode,
    required this.costPrice,
    required this.sellingPrice,
    required this.stockOnHand,
    required this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.attributes,
    required this.product,
  });

  factory Sku.fromJson(Map<String, dynamic> json) {
    return Sku(
      id: json['_id'] as String,
      sku: json['sku'] as String,
      barcode: json['barcode'] as String,
      costPrice: json['costPrice'] as int,
      sellingPrice: json['sellingPrice'] as int,
      stockOnHand: json['stockOnHand'] as int,
      imageUrl: json['imageUrl'] as String,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      attributes: (json['attributes'] as List<dynamic>)
          .map((attr) => Attribute.fromJson(attr))
          .toList(),
      product: Product.fromJson(json['product']),
    );
  }
}

class Attribute {
  final String name;
  final String value;

  Attribute({
    required this.name,
    required this.value,
  });

  factory Attribute.fromJson(Map<String, dynamic> json) {
    return Attribute(
      name: json['name'] as String,
      value: json['value'] as String,
    );
  }
}

class Product {
  final String id;
  final String code;
  final String name;
  final String description;
  final String imageUrl;
  final Category category;
  final Brand brand;
  final String status;
  final int basePrice;
  final int minStockLevel;
  final int maxStockLevel;
  final int views;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.brand,
    required this.status,
    required this.basePrice,
    required this.minStockLevel,
    required this.maxStockLevel,
    required this.views,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String,
      category: Category.fromJson(json['category']),
      brand: Brand.fromJson(json['brand']),
      status: json['status'] as String,
      basePrice: json['basePrice'] as int,
      minStockLevel: json['minStockLevel'] as int,
      maxStockLevel: json['maxStockLevel'] as int,
      views: json['views'] as int,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class Category {
  final String id;
  final String name;
  final String? parentCategory;
  final String imageUrl;

  Category({
    required this.id,
    required this.name,
    this.parentCategory,
    required this.imageUrl,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'] as String,
      name: json['name'] as String,
      parentCategory: json['parentCategory'],
      imageUrl: json['imageUrl'] as String,
    );
  }
}

class Brand {
  final String id;
  final String name;
  final String imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  Brand({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: json['_id'] as String,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
