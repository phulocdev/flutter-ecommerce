// lib/data/dummy_products.dart
import 'package:flutter_ecommerce/models/product.dart'; // Adjust import path as needed

final now = DateTime.now();

const categories = [
  {
    '_id': '6806f160f9b0714e1aaf2759',
    'name': 'Laptop',
    'parentCategory': null,
    'imageUrl': ''
  },
  {'_id': '6806f160f9b0714e1aaf2760', 'name': 'Monitor', 'parentCategory': null, 'imageUrl': ''},
  {'_id': '6806f160f9b0714e1aaf2761', 'name': 'Keyboard', 'parentCategory': null, 'imageUrl': ''},
  {
    '_id': '6806f160f9b0714e1aaf2762',
    'name': 'Mouse',
    'parentCategory': null,
    'imageUrl': ''
  },
  {'_id': '6806f160f9b0714e1aaf2763', 'name': 'Storage', 'parentCategory': null, 'imageUrl': ''},
  {'_id': '6806f160f9b0714e1aaf2764', 'name': 'Headphones', 'parentCategory': null, 'imageUrl': ''},
  {'_id': '6806f160f9b0714e1aaf2765', 'name': 'Graphic Card', 'parentCategory': null, 'imageUrl': ''},

];

List<Product> laptopProducts = [
  Product(
    id: '67dd1c4db940e33f97abacb4',
    name: "Laptop ASUS Vivobook 15",
    description: "Laptop Asus Vivobook 15 với bộ vi xử lý Intel Core i5.",
    imageUrl: "https://picsum.photos/seed/Laptop_ASUS_Vivobook/250/250",
    category: "6806f160f9b0714e1aaf2759",
    brand: "ASUS",
    status: "Published",
    basePrice: 25250000,
    isDeleted: false,
    deletedAt: null,
    createdAt: now.subtract(const Duration(days: 2)),
    updatedAt: now.subtract(const Duration(days: 2)),
  ),
  Product(
    id: '67dd1c4db940e33f97abacb5',
    name: "Laptop Dell XPS 13 Plus",
    description: "Dell XPS 13 Plus với thiết kế tràn viền, Core i7.",
    imageUrl: "https://picsum.photos/seed/Laptop_Dell_XPS/250/250",
    category: "6806f160f9b0714e1aaf2759",
    brand: "Dell",
    status: "Published",
    basePrice: 32990000,
    isDeleted: false,
    deletedAt: null,
    createdAt: now.subtract(const Duration(days: 3)),
    updatedAt: now.subtract(const Duration(days: 3)),
  ),
  Product(
    id: '67dd1c4db940e33f97abacbf',
    name: "Laptop Gaming MSI Katana GF66",
    description: "Laptop Gaming MSI Katana GF66 với RTX 3050Ti.",
    imageUrl: "https://picsum.photos/seed/Laptop_MSI_Katana/250/250",
    category: "6806f160f9b0714e1aaf2759",
    brand: "MSI",
    status: "Published",
    basePrice: 27990000,
    isDeleted: false,
    deletedAt: null,
    createdAt: now.add(const Duration(days: 5)),
    updatedAt: now.add(const Duration(days: 5)),
  ),
    Product(
    id: '67dd1c4db940e33f97abacb6',
    name: "MacBook Pro 14 M2",
    description: "MacBook Pro 14 M2 với hiệu năng vượt trội.",
    imageUrl: "https://picsum.photos/seed/MacBook_Pro_14/250/250",
    category: "6806f160f9b0714e1aaf2759",
    brand: "Apple",
    status: "Published",
    basePrice: 45990000,
    isDeleted: false,
    deletedAt: null,
    createdAt: now.subtract(const Duration(days: 4)),
    updatedAt: now.subtract(const Duration(days: 4)),
  ),
];

List<Product> monitorProducts = [
  Product(
    id: '67dd1c4db940e33f97abacb7',
    name: "Màn hình cong Samsung Odyssey G9",
    description: "Màn hình cong siêu rộng cho trải nghiệm chơi game đỉnh cao.",
    imageUrl: "https://picsum.photos/seed/Monitor_Samsung_Odyssey/250/250",
    category: "6806f160f9b0714e1aaf2760",
    brand: "Samsung",
    status: "Published",
    basePrice: 30990000,
    isDeleted: false,
    deletedAt: null,
    createdAt: now.subtract(const Duration(days: 5)),
    updatedAt: now.subtract(const Duration(days: 5)),
  ),
   Product(
    id: '67dd1c4db940e33f97abacbc',
    name: "Màn hình Dell UltraSharp U2723QE",
    description: "Màn hình Dell UltraSharp U2723QE 4K USB-C Hub.",
    imageUrl: "https://picsum.photos/seed/Monitor_Dell_U2723QE/250/250",
    category: "6806f160f9b0714e1aaf2760",
    brand: "Dell",
    status: "Published",
    basePrice: 15990000,
    isDeleted: false,
    deletedAt: null,
    createdAt: now.add(const Duration(days: 2)),
    updatedAt: now.add(const Duration(days: 2)),
  ),
];

List<Product> keyboardProducts = [
  Product(
    id: '67dd1c4db940e33f97abacb8',
    name: "Bàn phím cơ Keychron K8 Pro",
    description: "Bàn phím cơ Keychron K8 Pro không dây, hot-swappable.",
    imageUrl: "https://picsum.photos/seed/Keyboard_Keychron/250/250",
    category: "6806f160f9b0714e1aaf2761",
    brand: "Keychron",
    status: "Published",
    basePrice: 3199000,
    isDeleted: false,
    deletedAt: null,
    createdAt: now.subtract(const Duration(days: 6)),
    updatedAt: now.subtract(const Duration(days: 6)),
  ),
   Product(
    id: '67dd1c4db940e33f97abacbe',
    name: "Bàn phím cơ Razer BlackWidow V3",
    description: "Bàn phím cơ Razer BlackWidow V3 với switch Razer Green.",
    imageUrl: "https://picsum.photos/seed/Keyboard_Razer_V3/250/250",
    category: "6806f160f9b0714e1aaf2761",
    brand: "Razer",
    status: "Published",
    basePrice: 2999000,
    isDeleted: false,
    deletedAt: null,
    createdAt: now.add(const Duration(days: 4)),
    updatedAt: now.add(const Duration(days: 4)),
  ),
];

List<Product> mouseProducts = [
  Product(
    id: '67dd1c4db940e33f97abacb9',
    name: "Chuột Logitech MX Master 3S",
    description: "Chuột Logitech MX Master 3S với công nghệ cuộn MagSpeed.",
    imageUrl: "https://picsum.photos/seed/Mouse_Logitech_MX/250/250",
    category: "6806f160f9b0714e1aaf2762",
    brand: "Logitech",
    status: "Published",
    basePrice: 2599000,
    isDeleted: false,
    deletedAt: null,
    createdAt: now.subtract(const Duration(days: 1)),
    updatedAt: now.subtract(const Duration(days: 1)),
  ),
];

List<Product> storageProducts = [
  Product(
    id: '67dd1c4db940e33f97abacba',
    name: "SSD Samsung 980 Pro 1TB",
    description: "SSD Samsung 980 Pro 1TB NVMe PCIe Gen4.",
    imageUrl: "https://picsum.photos/seed/SSD_Samsung_980/250/250",
    category: "6806f160f9b0714e1aaf2763",
    brand: "Samsung",
    status: "Published",
    basePrice: 3799000,
    isDeleted: false,
    deletedAt: null,
    createdAt: now,
    updatedAt: now,
  ),
 Product(
    id: '67dd1c4db940e33f97abacbd',
    name: "Ổ cứng di động WD My Passport 4TB",
    description: "Ổ cứng di động WD My Passport 4TB với mã hóa phần cứng.",
    imageUrl: "https://picsum.photos/seed/WD_My_Passport/250/250",
    category: "6806f160f9b0714e1aaf2763",
    brand: "Western Digital",
    status: "Published",
    basePrice: 2790000,
    isDeleted: false,
    deletedAt: null,
    createdAt: now.add(const Duration(days: 3)),
    updatedAt: now.add(const Duration(days: 3)),
  ),
];

List<Product> bestSellers = [

  Product(
    id: '67dd1c4db940e33f97abacc0',
    name: "Card đồ họa ASUS ROG Strix RTX 4080",
    description: "Card đồ họa ASUS ROG Strix RTX 4080 hiệu năng cao.",
    imageUrl: "https://picsum.photos/seed/GPU_ASUS_4080/250/250",
    category: "6806f160f9b0714e1aaf2765",
    brand: "ASUS",
    status: "Published",
    basePrice: 35990000,
    isDeleted: false,
    deletedAt: null,
    createdAt: now.add(const Duration(days: 6)),
    updatedAt: now.add(const Duration(days: 6)),
  ),

  Product(
    id: '67dd1c4db940e33f97abacbb',
    name: "Tai nghe Sony WH-1000XM5",
    description: "Tai nghe Sony WH-1000XM5 chống ồn chủ động.",
    imageUrl: "https://picsum.photos/seed/Headphone_Sony_XM5/250/250",
    category: "6806f160f9b0714e1aaf2764",
    brand: "Sony",
    status: "Published",
    basePrice: 8990000,
    isDeleted: false,
    deletedAt: null,
    createdAt: now.add(const Duration(days: 1)),
    updatedAt: now.add(const Duration(days: 1)),
  ),
];

List<Product> discountedProducts = [
  Product(
    id: '67dd1c4db940e33f97abacb4',
    name: "Laptop ASUS Vivobook 15 (Discounted)",
    description: "Laptop Asus Vivobook 15 với bộ vi xử lý Intel Core i5 (Discounted).",
    imageUrl: "https://picsum.photos/seed/Laptop_ASUS_Vivobook/250/250",
    category: "6806f160f9b0714e1aaf2759",
    brand: "ASUS",
    status: "Published",
    basePrice: 25250000 * 0.9, // 10% discount
    isDeleted: false,
    deletedAt: null,
    createdAt: now.subtract(const Duration(days: 2)),
    updatedAt: now.subtract(const Duration(days: 2)),
  ),
];

List<Product> newProducts = [

];