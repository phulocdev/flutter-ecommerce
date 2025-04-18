import 'package:flutter_ecommerce/models/product.dart';
import 'package:flutter_ecommerce/services/api_client.dart';

class ProductApiService {
  final ApiClient _apiClient;

  ProductApiService(this._apiClient);

  Future<Product> getProductById(String productId) async {
    try {
      final response = await _apiClient.get('/products/$productId');
      if (response is Map<String, dynamic>) {
        return Product.fromJson(response);
      } else {
        throw Exception('Invalid API response format for product details.');
      }
    } catch (e) {
      print('Error fetching product $productId: $e');
      rethrow;
    }
  }
}
