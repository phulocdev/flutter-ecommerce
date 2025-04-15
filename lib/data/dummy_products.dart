// data/dummy_products.dart
import 'package:flutter_ecommerce/models/product.dart'; // Đảm bảo đường dẫn đúng

// Sử dụng prefix trong ID để dễ phân biệt:
// d = discounted, n = new, bs = best seller, s = storage,
// m = monitor, l = laptop, mo = mouse, k = keyboard

List<Product> discountedProducts = [
  Product(
      id: 'd1',
      name: "Laptop Gaming Nitro 5",
      imageUrl: "https://picsum.photos/seed/d1/250",
      price: 21500000, // Giá ví dụ (VND)
      description:
          'Laptop gaming Acer Nitro 5 với chip Intel Core i5, card đồ họa RTX 3050, màn hình 144Hz. Chiến game mượt mà, thiết kế hầm hố.'),
  Product(
      id: 'd2',
      name: "Màn hình cong Samsung 34\"",
      imageUrl: "https://picsum.photos/seed/d2/250",
      price: 8990000, // Giá ví dụ (VND)
      description:
          'Màn hình ultrawide cong 34 inch, độ phân giải WQHD, tần số quét 100Hz. Tối ưu cho làm việc đa nhiệm và giải trí.'),
  Product(
      id: 'd3',
      name: "Chuột Logitech G502 Hero",
      imageUrl: "https://picsum.photos/seed/d3/250",
      price: 950000, // Giá ví dụ (VND)
      description:
          'Chuột gaming có dây G502 Hero với cảm biến HERO 25K, 11 nút lập trình được, thiết kế công thái học.'),
  Product(
      id: 'd4',
      name: "Bàn phím cơ DareU EK87",
      imageUrl: "https://picsum.photos/seed/d4/250",
      price: 499000, // Giá ví dụ (VND)
      description:
          'Bàn phím cơ Tenkeyless (TKL) giá rẻ, switch D độc quyền, LED Rainbow. Phù hợp cho người mới bắt đầu.'),
  Product(
      id: 'd5',
      name: "Tai nghe Gaming Rapoo VH500",
      imageUrl: "https://picsum.photos/seed/d5/250",
      price: 390000, // Giá ví dụ (VND)
      description:
          'Tai nghe chụp tai gaming với âm thanh vòm 7.1 giả lập, mic khử ồn, LED RGB. Thoải mái khi đeo trong thời gian dài.'),
];

List<Product> newProducts = [
  Product(
      id: 'n1',
      name: "MacBook Air M3 13 inch",
      imageUrl: "https://picsum.photos/seed/n1/250",
      price: 28500000, // Giá ví dụ (VND)
      description:
          'MacBook Air mới nhất với chip Apple M3 mạnh mẽ, thời lượng pin khủng, thiết kế mỏng nhẹ. Hoàn hảo cho công việc và sáng tạo.'),
  Product(
      id: 'n2',
      name: "Màn hình LG UltraFine 4K 27\"",
      imageUrl: "https://picsum.photos/seed/n2/250",
      price: 12500000, // Giá ví dụ (VND)
      description:
          'Màn hình 4K sắc nét, tấm nền IPS, hỗ trợ HDR, cổng USB-C. Lựa chọn tuyệt vời cho đồ họa và dựng phim.'),
  Product(
      id: 'n3',
      name: "Chuột Razer Viper V3 Pro",
      imageUrl: "https://picsum.photos/seed/n3/250",
      price: 3800000, // Giá ví dụ (VND)
      description:
          'Chuột gaming không dây siêu nhẹ mới nhất từ Razer, cảm biến Focus Pro 30K, switch quang học Gen-3.'),
  Product(
      id: 'n4',
      name: "Bàn phím cơ Keychron Q1 Pro",
      imageUrl: "https://picsum.photos/seed/n4/250",
      price: 4500000, // Giá ví dụ (VND)
      description:
          'Bàn phím cơ custom không dây, layout 75%, vỏ nhôm CNC, hỗ trợ QMK/VIA. Trải nghiệm gõ phím đỉnh cao.'),
  Product(
      id: 'n5',
      name: "Webcam Insta360 Link",
      imageUrl: "https://picsum.photos/seed/n5/250",
      price: 7200000, // Giá ví dụ (VND)
      description:
          'Webcam 4K tích hợp gimbal AI, tự động theo dõi và lấy nét. Chất lượng hình ảnh vượt trội cho họp trực tuyến và streaming.'),
];

List<Product> bestSellers = [
  Product(
      id: 'bs1',
      name: "Laptop Dell XPS 13",
      imageUrl: "https://picsum.photos/seed/bs1/250",
      price: 32000000, // Giá ví dụ (VND)
      description:
          'Laptop doanh nhân cao cấp với thiết kế viền mỏng InfinityEdge, hiệu năng ổn định, màn hình đẹp.'),
  Product(
      id: 'bs2',
      name: "Ổ cứng SSD Samsung 980 Pro 1TB",
      imageUrl: "https://picsum.photos/seed/bs2/250",
      price: 2300000, // Giá ví dụ (VND)
      description:
          'Ổ cứng SSD NVMe PCIe Gen4 tốc độ cao, tối ưu cho gaming và các tác vụ nặng. Thời gian tải ứng dụng siêu nhanh.'),
  Product(
      id: 'bs3',
      name: "Chuột Logitech MX Anywhere 3S",
      imageUrl: "https://picsum.photos/seed/bs3/250",
      price: 1850000, // Giá ví dụ (VND)
      description:
          'Chuột không dây nhỏ gọn, hoạt động trên mọi bề mặt, cuộn MagSpeed siêu nhanh, kết nối đa thiết bị.'),
  Product(
      id: 'bs4',
      name: "Loa Bluetooth JBL Charge 5",
      imageUrl: "https://picsum.photos/seed/bs4/250",
      price: 3100000, // Giá ví dụ (VND)
      description:
          'Loa di động chống nước IP67, âm thanh JBL Original Pro Sound mạnh mẽ, pin 20 giờ, tích hợp sạc dự phòng.'),
  Product(
      id: 'bs5',
      name: "Card đồ họa NVIDIA RTX 4070",
      imageUrl: "https://picsum.photos/seed/bs5/250",
      price: 16500000, // Giá ví dụ (VND)
      description:
          'Card đồ họa hiệu năng cao với kiến trúc Ada Lovelace, hỗ trợ DLSS 3, Ray Tracing. Chơi game 2K max setting.'),
];

List<Product> storageProducts = [
  Product(
      id: 's1',
      name: "SSD Western Digital Blue SN580 1TB",
      imageUrl: "https://picsum.photos/seed/s1/250",
      price: 1550000, // Giá ví dụ (VND)
      description:
          'Ổ cứng SSD NVMe PCIe Gen4 tầm trung, tốc độ đọc/ghi tốt, phù hợp nâng cấp cho laptop và PC phổ thông.'),
  Product(
      id: 's2',
      name: "HDD Seagate Barracuda 2TB",
      imageUrl: "https://picsum.photos/seed/s2/250",
      price: 1400000, // Giá ví dụ (VND)
      description:
          'Ổ cứng HDD 3.5 inch dung lượng lớn, tốc độ 7200RPM, thích hợp lưu trữ dữ liệu, phim ảnh, game.'),
  Product(
      id: 's3',
      name: "Ổ cứng di động WD My Passport 4TB",
      imageUrl: "https://picsum.photos/seed/s3/250",
      price: 2800000, // Giá ví dụ (VND)
      description:
          'Ổ cứng gắn ngoài dung lượng 4TB, kết nối USB 3.0, thiết kế nhỏ gọn, có phần mềm sao lưu và bảo mật.'),
  Product(
      id: 's4',
      name: "USB Sandisk Ultra Flair 128GB",
      imageUrl: "https://picsum.photos/seed/s4/250",
      price: 250000, // Giá ví dụ (VND)
      description:
          'USB 3.0 tốc độ cao, vỏ kim loại bền bỉ, dung lượng 128GB đủ lưu trữ tài liệu và dữ liệu quan trọng.'),
  Product(
      id: 's5',
      name: "Thẻ nhớ MicroSD Samsung EVO Plus 256GB",
      imageUrl: "https://picsum.photos/seed/s5/250",
      price: 480000, // Giá ví dụ (VND)
      description:
          'Thẻ nhớ tốc độ cao Class 10, U3, V30. Phù hợp cho điện thoại, máy tính bảng, camera hành trình quay 4K.'),
];

List<Product> monitorProducts = [
  Product(
      id: 'm1',
      name: "Màn hình LG 27UP600-W 27\" 4K",
      imageUrl: "https://picsum.photos/seed/m1/250",
      price: 6800000, // Giá ví dụ (VND)
      description:
          'Màn hình 27 inch độ phân giải 4K UHD, tấm nền IPS, HDR10. Hình ảnh sắc nét, màu sắc chính xác.'),
  Product(
      id: 'm2',
      name: "Màn hình Dell UltraSharp U3223QE 32\" 4K",
      imageUrl: "https://picsum.photos/seed/m2/250",
      price: 19500000, // Giá ví dụ (VND)
      description:
          'Màn hình cao cấp 31.5 inch 4K, tấm nền IPS Black cho độ tương phản cao, nhiều cổng kết nối, Hub USB-C.'),
  Product(
      id: 'm3',
      name: "Màn hình ASUS TUF Gaming VG249Q1R 24\"",
      imageUrl: "https://picsum.photos/seed/m3/250",
      price: 4100000, // Giá ví dụ (VND)
      description:
          'Màn hình gaming 23.8 inch Full HD, tấm nền IPS, tần số quét 165Hz, 1ms MPRT. Chơi game FPS mượt mà.'),
  Product(
      id: 'm4',
      name: "Màn hình Xiaomi Mi Curved Gaming 34\"",
      imageUrl: "https://picsum.photos/seed/m4/250",
      price: 8500000, // Giá ví dụ (VND)
      description:
          'Màn hình ultrawide cong 34 inch, độ phân giải WQHD, 144Hz, FreeSync Premium. Trải nghiệm game và phim ảnh sống động.'),
  Product(
      id: 'm5',
      name: "Màn hình HP M27fw 27\" Full HD",
      imageUrl: "https://picsum.photos/seed/m5/250",
      price: 3900000, // Giá ví dụ (VND)
      description:
          'Màn hình văn phòng 27 inch Full HD, tấm nền IPS, thiết kế viền mỏng, màu trắng trang nhã, công nghệ bảo vệ mắt.'),
];

List<Product> laptopProducts = [
  Product(
      id: 'l1',
      name: "MacBook Pro 14 inch M3 Pro",
      imageUrl: "https://picsum.photos/seed/l1/250",
      price: 48000000, // Giá ví dụ (VND)
      description:
          'MacBook Pro hiệu năng cực cao với chip M3 Pro, màn hình Liquid Retina XDR, hệ thống loa đỉnh cao. Dành cho chuyên gia.'),
  Product(
      id: 'l2',
      name: "Dell Inspiron 15 3530",
      imageUrl: "https://picsum.photos/seed/l2/250",
      price: 14500000, // Giá ví dụ (VND)
      description:
          'Laptop văn phòng phổ thông 15.6 inch, chip Intel Core i5 Gen 13, RAM 8GB, SSD 512GB. Đáp ứng tốt nhu cầu học tập, làm việc cơ bản.'),
  Product(
      id: 'l3',
      name: "ASUS ROG Strix G16 (2024)",
      imageUrl: "https://picsum.photos/seed/l3/250",
      price: 42000000, // Giá ví dụ (VND)
      description:
          'Laptop gaming mạnh mẽ với CPU Intel Core i9 Gen 14, card RTX 4060, màn hình Nebula 2.5K 240Hz.'),
  Product(
      id: 'l4',
      name: "HP Pavilion 14 dv2074TU",
      imageUrl: "https://picsum.photos/seed/l4/250",
      price: 16800000, // Giá ví dụ (VND)
      description:
          'Laptop học tập - văn phòng 14 inch nhỏ gọn, chip Core i5, RAM 16GB, thiết kế trẻ trung, vỏ kim loại.'),
  Product(
      id: 'l5',
      name: "Lenovo ThinkPad E14 Gen 5",
      imageUrl: "https://picsum.photos/seed/l5/250",
      price: 19500000, // Giá ví dụ (VND)
      description:
          'Laptop doanh nhân bền bỉ, bàn phím ThinkPad trứ danh, bảo mật vân tay, chip Intel Core i5. Đáng tin cậy cho công việc.'),
];

List<Product> mouseProducts = [
  Product(
      id: 'mo1',
      name: "Chuột Logitech MX Master 3S",
      imageUrl: "https://picsum.photos/seed/mo1/250",
      price: 2450000, // Giá ví dụ (VND)
      description:
          'Chuột công thái học cao cấp, cuộn MagSpeed, nút bấm siêu êm, cảm biến 8K DPI, kết nối đa thiết bị qua Bluetooth/Logi Bolt.'),
  Product(
      id: 'mo2',
      name: "Chuột Razer DeathAdder V3",
      imageUrl: "https://picsum.photos/seed/mo2/250",
      price: 1600000, // Giá ví dụ (VND)
      description:
          'Chuột gaming có dây siêu nhẹ (59g), thiết kế công thái học tối ưu cho người thuận tay phải, cảm biến Focus Pro 30K.'),
  Product(
      id: 'mo3',
      name: "Chuột không dây Xiaomi Mi Dual Mode Silent",
      imageUrl: "https://picsum.photos/seed/mo3/250",
      price: 280000, // Giá ví dụ (VND)
      description:
          'Chuột không dây giá rẻ, kết nối Bluetooth/USB Receiver, nút bấm yên tĩnh, thiết kế đơn giản, phù hợp văn phòng.'),
  Product(
      id: 'mo4',
      name: "Chuột Corsair Harpoon RGB Wireless",
      imageUrl: "https://picsum.photos/seed/mo4/250",
      price: 1150000, // Giá ví dụ (VND)
      description:
          'Chuột gaming không dây Slipstream tốc độ cao, nhẹ (99g), cảm biến quang học 10K DPI, LED RGB.'),
  Product(
      id: 'mo5',
      name: "Chuột Microsoft Bluetooth Ergonomic",
      imageUrl: "https://picsum.photos/seed/mo5/250",
      price: 1050000, // Giá ví dụ (VND)
      description:
          'Chuột không dây Bluetooth thiết kế công thái học, thoải mái khi sử dụng lâu dài, 2 nút tùy chỉnh, hoạt động đa nền tảng.'),
];

List<Product> keyboardProducts = [
  Product(
      id: 'k1',
      name: "Bàn phím cơ AKKO 3087 v2 DS Horizon",
      imageUrl: "https://picsum.photos/seed/k1/250",
      price: 1350000, // Giá ví dụ (VND)
      description:
          'Bàn phím cơ TKL, keycap PBT Double-Shot, AKKO switch v2 (Blue/Orange/Pink). Phối màu đẹp mắt, chất lượng build tốt.'),
  Product(
      id: 'k2',
      name: "Bàn phím Logitech G Pro X TKL Lightspeed",
      imageUrl: "https://picsum.photos/seed/k2/250",
      price: 4200000, // Giá ví dụ (VND)
      description:
          'Bàn phím gaming không dây TKL cao cấp, kết nối Lightspeed, switch GX có thể thay nóng (hot-swap), LED RGB Lightsync.'),
  Product(
      id: 'k3',
      name: "Bàn phím Razer BlackWidow V4 Pro",
      imageUrl: "https://picsum.photos/seed/k3/250",
      price: 5800000, // Giá ví dụ (VND)
      description:
          'Bàn phím cơ fullsize cao cấp, Razer switch (Green/Yellow), núm xoay Command Dial, phím macro, LED Chroma RGB.'),
  Product(
      id: 'k4',
      name: "Bàn phím Corsair K70 RGB Pro",
      imageUrl: "https://picsum.photos/seed/k4/250",
      price: 3900000, // Giá ví dụ (VND)
      description:
          'Bàn phím cơ fullsize, switch Cherry MX, khung nhôm bền bỉ, keycap PBT Double-Shot, công nghệ siêu xử lý AXON.'),
  Product(
      id: 'k5',
      name: "Bàn phím Apple Magic Keyboard",
      imageUrl: "https://picsum.photos/seed/k5/250",
      price: 2500000, // Giá ví dụ (VND)
      description:
          'Bàn phím không dây cho Mac, thiết kế mỏng nhẹ, pin sạc, hành trình phím ổn định, kết nối Bluetooth nhanh chóng.'),
];


// Bạn có thể tạo thêm một list tổng hợp nếu cần
// List<Product> allProducts = [
//   ...discountedProducts,
//   ...newProducts,
//   ...bestSellers,
//   ...storageProducts,
//   ...monitorProducts,
//   ...laptopProducts,
//   ...mouseProducts,
//   ...keyboardProducts,
// ];