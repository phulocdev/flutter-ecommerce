// lib/data/dummy_products.dart
import 'package:flutter_ecommerce/models/product.dart'; // Adjust import path as needed

// Note: Using picsum.photos with seeds for varied images.
// Format: https://picsum.photos/seed/{seed_name}/250/250

List<Product> discountedProducts = [
  Product(
      id: 'd1',
      name: "Laptop Gaming ROG",
      description: "High-performance gaming laptop with latest GPU.",
      imageUrl: "https://picsum.photos/seed/d_laptop_gaming/250/250",
      price: 1199.99),
  Product(
      id: 'd2',
      name: "Màn hình cong 34\"",
      description: "Ultrawide curved monitor for immersive experience.",
      imageUrl: "https://picsum.photos/seed/d_monitor_curved/250/250",
      price: 449.50),
  Product(
      id: 'd3',
      name: "Chuột Logitech G502 Hero",
      description: "Popular high-performance wired gaming mouse.",
      imageUrl: "https://picsum.photos/seed/d_mouse_g502/250/250",
      price: 49.99),
  Product(
      id: 'd4',
      name: "Bàn phím RGB Cơ",
      description: "Mechanical keyboard with customizable RGB lighting.",
      imageUrl: "https://picsum.photos/seed/d_keyboard_rgb/250/250",
      price: 89.90),
  Product(
      id: 'd5',
      name: "Tai nghe HyperX Cloud II",
      description: "Comfortable gaming headset with 7.1 surround sound.",
      imageUrl: "https://picsum.photos/seed/d_headset_hyperx/250/250",
      price: 74.99),
];

List<Product> newProducts = [
  Product(
      id: 'n1',
      name: "MacBook Air M3",
      description: "Latest Apple MacBook Air with M3 chip.",
      imageUrl: "https://picsum.photos/seed/n_macbook_air/250/250",
      price: 1199.00),
  Product(
      id: 'n2',
      name: "Màn hình Studio Display",
      description: "Apple's 5K Retina display for creators.",
      imageUrl: "https://picsum.photos/seed/n_monitor_studio/250/250",
      price: 1599.00),
  Product(
      id: 'n3',
      name: "Chuột Razer Viper Mini",
      description: "Lightweight ambidextrous gaming mouse.",
      imageUrl: "https://picsum.photos/seed/n_mouse_viper/250/250",
      price: 39.99),
  Product(
      id: 'n4',
      name: "Bàn phím Keychron K2",
      description: "Compact wireless mechanical keyboard.",
      imageUrl: "https://picsum.photos/seed/n_keyboard_keychron/250/250",
      price: 89.99),
  Product(
      id: 'n5',
      name: "Webcam Logitech C920",
      description: "Popular Full HD webcam for streaming and calls.",
      imageUrl: "https://picsum.photos/seed/n_webcam_logitech/250/250",
      price: 59.99),
];

List<Product> bestSellers = [
  Product(
      id: 'bs1',
      name: "Laptop Dell XPS 15",
      description: "Premium Windows laptop with InfinityEdge display.",
      imageUrl: "https://picsum.photos/seed/bs_laptop_xps/250/250",
      price: 1499.00),
  Product(
      id: 'bs2',
      name: "Ổ cứng SSD Samsung 980 Pro 1TB",
      description: "Fast NVMe SSD for high-speed storage.",
      imageUrl: "https://picsum.photos/seed/bs_ssd_980pro/250/250",
      price: 99.99),
  Product(
      id: 'bs3',
      name: "Chuột không dây Logitech MX Anywhere 3",
      description: "Compact wireless mouse for productivity on the go.",
      imageUrl: "https://picsum.photos/seed/bs_mouse_mx/250/250",
      price: 79.99),
  Product(
      id: 'bs4',
      name: "Loa Bluetooth JBL Flip 6",
      description: "Portable waterproof Bluetooth speaker.",
      imageUrl: "https://picsum.photos/seed/bs_speaker_jbl/250/250",
      price: 129.95),
  Product(
      id: 'bs5',
      name: "Card đồ họa NVIDIA RTX 4070",
      description: "High-end graphics card for gaming and creation.",
      imageUrl: "https://picsum.photos/seed/bs_gpu_4070/250/250",
      price: 599.00),
];

List<Product> storageProducts = [
  Product(
      id: 's1',
      name: "SSD Crucial MX500 1TB",
      description: "Reliable SATA III SSD for everyday use.",
      imageUrl: "https://picsum.photos/seed/s_ssd_crucial/250/250",
      price: 64.99),
  Product(
      id: 's2',
      name: "HDD Seagate Barracuda 2TB",
      description: "Internal hard drive for bulk storage.",
      imageUrl: "https://picsum.photos/seed/s_hdd_seagate/250/250",
      price: 54.99),
  Product(
      id: 's3',
      name: "Ổ cứng di động WD My Passport 4TB",
      description: "Portable external hard drive with password protection.",
      imageUrl: "https://picsum.photos/seed/s_hdd_wd/250/250",
      price: 109.99),
  Product(
      id: 's4',
      name: "USB SanDisk Ultra 128GB",
      description: "USB 3.0 flash drive for quick file transfers.",
      imageUrl: "https://picsum.photos/seed/s_usb_sandisk/250/250",
      price: 14.99),
  Product(
      id: 's5',
      name: "Thẻ nhớ MicroSD Samsung Evo 256GB",
      description: "High-speed microSD card for phones and cameras.",
      imageUrl: "https://picsum.photos/seed/s_microsd_samsung/250/250",
      price: 24.99),
];

List<Product> monitorProducts = [
  Product(
      id: 'm1',
      name: "Màn hình LG UltraGear 27\" QHD",
      description: "27-inch QHD gaming monitor with 144Hz refresh rate.",
      imageUrl: "https://picsum.photos/seed/m_lg_ultragear/250/250",
      price: 299.99),
  Product(
      id: 'm2',
      name: "Màn hình Dell UltraSharp 32\" 4K",
      description: "32-inch 4K monitor for productivity and color accuracy.",
      imageUrl: "https://picsum.photos/seed/m_dell_ultrasharp/250/250",
      price: 649.99),
  Product(
      id: 'm3',
      name: "Màn hình ASUS TUF Gaming 24\" FHD",
      description: "24-inch Full HD gaming monitor, high refresh rate.",
      imageUrl: "https://picsum.photos/seed/m_asus_tuf/250/250",
      price: 199.00),
  Product(
      id: 'm4',
      name: "Màn hình Xiaomi Mi Curved 34\"",
      description: "Affordable ultrawide curved gaming monitor.",
      imageUrl: "https://picsum.photos/seed/m_xiaomi_curved/250/250",
      price: 399.99),
  Product(
      id: 'm5',
      name: "Màn hình HP 27\" FHD IPS",
      description: "27-inch IPS monitor with thin bezels for office use.",
      imageUrl: "https://picsum.photos/seed/m_hp_27ips/250/250",
      price: 179.99),
];

List<Product> laptopProducts = [
  Product(
      id: 'l1',
      name: "MacBook Pro 14\" M3",
      description: "Powerful Apple laptop for professionals.",
      imageUrl: "https://picsum.photos/seed/l_macbook_pro/250/250",
      price: 1599.00),
  Product(
      id: 'l2',
      name: "Dell Inspiron 15",
      description: "Versatile everyday laptop from Dell.",
      imageUrl: "https://picsum.photos/seed/l_dell_inspiron/250/250",
      price: 649.99),
  Product(
      id: 'l3',
      name: "ASUS ROG Zephyrus G14",
      description: "Compact and powerful gaming laptop.",
      imageUrl: "https://picsum.photos/seed/l_asus_rog/250/250",
      price: 1449.00),
  Product(
      id: 'l4',
      name: "HP Spectre x360 14",
      description: "Premium 2-in-1 convertible laptop.",
      imageUrl: "https://picsum.photos/seed/l_hp_spectre/250/250",
      price: 1249.99),
  Product(
      id: 'l5',
      name: "Lenovo Yoga Slim 7 Pro",
      description: "Thin and light laptop with a great display.",
      imageUrl: "https://picsum.photos/seed/l_lenovo_yoga/250/250",
      price: 999.00),
];

List<Product> mouseProducts = [
  Product(
      id: 'mo1',
      name: "Chuột Logitech MX Master 3S",
      description: "Advanced wireless mouse for productivity.",
      imageUrl: "https://picsum.photos/seed/mo_mx_master/250/250",
      price: 99.99),
  Product(
      id: 'mo2',
      name: "Chuột Razer DeathAdder V2",
      description: "Ergonomic wired gaming mouse.",
      imageUrl: "https://picsum.photos/seed/mo_deathadder/250/250",
      price: 49.99),
  Product(
      id: 'mo3',
      name: "Chuột không dây Xiaomi Mi Silent",
      description: "Affordable and quiet wireless mouse.",
      imageUrl: "https://picsum.photos/seed/mo_xiaomi/250/250",
      price: 14.99),
  Product(
      id: 'mo4',
      name: "Chuột Corsair Dark Core RGB Pro",
      description: "Wireless gaming mouse with multiple connection options.",
      imageUrl: "https://picsum.photos/seed/mo_corsair/250/250",
      price: 79.99),
  Product(
      id: 'mo5',
      name: "Chuột Microsoft Arc Mouse",
      description: "Unique, foldable mouse for portability.",
      imageUrl: "https://picsum.photos/seed/mo_microsoft_arc/250/250",
      price: 69.99),
];

List<Product> keyboardProducts = [
  Product(
      id: 'k1',
      name: "Bàn phím cơ Akko 3068B Plus",
      description: "Compact 65% layout wireless mechanical keyboard.",
      imageUrl: "https://picsum.photos/seed/k_akko_3068b/250/250",
      price: 95.00),
  Product(
      id: 'k2',
      name: "Bàn phím Logitech G Pro X TKL",
      description: "Tenkeyless gaming keyboard with swappable switches.",
      imageUrl: "https://picsum.photos/seed/k_logitech_gpro/250/250",
      price: 129.99),
  Product(
      id: 'k3',
      name: "Bàn phím Razer Huntsman Mini",
      description: "60% gaming keyboard with optical switches.",
      imageUrl: "https://picsum.photos/seed/k_razer_huntsman/250/250",
      price: 119.99),
  Product(
      id: 'k4',
      name: "Bàn phím Corsair K100 RGB Optical",
      description:
          "Flagship gaming keyboard with optical switches and iCUE wheel.",
      imageUrl: "https://picsum.photos/seed/k_corsair_k100/250/250",
      price: 229.99),
  Product(
      id: 'k5',
      name: "Bàn phím Apple Magic Keyboard",
      description: "Wireless keyboard designed for Mac.",
      imageUrl: "https://picsum.photos/seed/k_apple_magic/250/250",
      price: 99.00),
];
