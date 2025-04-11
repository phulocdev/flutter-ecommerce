import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/models/product.dart';

class ProductDetail extends StatelessWidget {
  const ProductDetail({super.key, required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text(
          product.name,
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w500, fontSize: 24),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Text(
          product.name,
          style: TextStyle(color: Colors.blue, fontSize: 28),
        ),
      ),
    );
  }
}
