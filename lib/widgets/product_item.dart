// widgets/product_item.dart
import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/models/product.dart';
import 'package:flutter_ecommerce/screens/product_detail_screen.dart'; // Import màn hình chi tiết

class ProductItem extends StatelessWidget {
  final Product product;

  const ProductItem({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias, // Để bo tròn ảnh nếu dùng Card
      elevation: 2.0, // Thêm đổ bóng nhẹ
      shape: RoundedRectangleBorder( // Bo góc nhẹ cho Card
         borderRadius: BorderRadius.circular(8.0),
      ),
      child: InkWell( // Sử dụng InkWell để có hiệu ứng ripple khi nhấn
        onTap: () {
          // *** Điều hướng đến màn hình chi tiết khi nhấn vào ***
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetail(product: product), // Truyền sản phẩm vào
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh sản phẩm
            Expanded( // Cho ảnh chiếm phần không gian còn lại phía trên
              child: Image.network(
                product.imageUrl,
                width: double.infinity,
                fit: BoxFit.cover, // Đảm bảo ảnh che phủ không gian
                // Thêm placeholder và error widget cho ảnh preview
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator(strokeWidth: 2.0));
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(child: Icon(Icons.image_not_supported, color: Colors.grey, size: 40));
                },
              ),
            ),
            // Thông tin tên và giá
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500
                    ),
                    maxLines: 2, // Giới hạn 2 dòng
                    overflow: TextOverflow.ellipsis, // Hiển thị '...' nếu quá dài
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.formattedPrice,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}