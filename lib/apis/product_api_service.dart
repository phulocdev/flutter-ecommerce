import 'package:flutter_ecommerce/models/dto/create_product_dto.dart';
import 'package:flutter_ecommerce/models/product.dart';
import 'package:flutter_ecommerce/services/api_client.dart';

class ProductApiService {
  final ApiClient _apiClient;

  ProductApiService(this._apiClient);

  Future<Product> getProductById(String productId) async {
    try {
      final response = await _apiClient.get('/products/$productId');

      if (response is Map<String, dynamic> && response.containsKey('data')) {
        final productData = response['data'];

        if (productData is Map<String, dynamic>) {
          return Product.fromJson(productData);
        } else {
          throw Exception('Invalid API response: data should be map.');
        }
      } else if (response is List<dynamic>) {
        throw Exception(
            'Invalid API response: Expected a map but received a list.');
      } else {
        throw Exception('Invalid API response: Unexpected response format.');
      }
    } catch (e) {
      print('Error fetching product with ID $productId: $e');
      rethrow;
    }
  }

  Future<List<Product>> getProducts() async {
    try {
      final response = await _apiClient.get('/products');

      if (response is Map<String, dynamic> && response.containsKey('data')) {
        final List<dynamic> productList = response['data'];

        if (productList is List<dynamic>) {
          return productList
              .map((productJson) => Product.fromJson(productJson))
              .toList();
        } else {
          throw Exception('Invalid API response: data should be list.');
        }
      } else {
        throw Exception('Invalid API response: Unexpected response format.');
      }
    } catch (e) {
      print('Error fetching products: $e');
      rethrow;
    }
  }

  Future create(CreateProductDto dto) async {
    try {
      final response = await _apiClient.post('/products', body: dto.toJson());
      return response;
    } on ApiException catch (e) {
      rethrow;
    } catch (e) {
      print("Lỗi không xác định: $e");
      rethrow;
    }
  }
}
