import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/models/product.dart';
import 'package:flutter_ecommerce/screens/product_detail_screen.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product});
  final Product product;

  void _navigateToProductDetailScreen(BuildContext context, Product product) {
    Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
      return ProductDetail(product: product);
    }));
  }

  @override
  Widget build(BuildContext context) {
    const double cardBorderRadius = 15.0;
    final Border cardBorder = Border.all(
      color: Colors.grey.shade300,
      width: 1.0,
    );

    return InkWell(
      onTap: () {
        _navigateToProductDetailScreen(context, product);
      },
      borderRadius: BorderRadius.circular(cardBorderRadius),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: cardBorder,
          borderRadius: BorderRadius.circular(cardBorderRadius),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Center(child: Icon(Icons.broken_image, color: Colors.grey)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 7.0),
              child: Text(
                product.name,
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Text(
                product.formattedPrice,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.redAccent, fontWeight: FontWeight.w500),
              ),
            ),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
