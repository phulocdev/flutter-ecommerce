import 'package:flutter_ecommerce/models/brand.dart';
import 'package:flutter_ecommerce/services/api_client.dart';

class BrandApiService {
  final ApiClient _apiClient;
  BrandApiService(this._apiClient);

  Future<List<Brand>> getBrands() async {
    try {
      final response = await _apiClient.get('/brands');

      if (response is Map<String, dynamic> && response.containsKey('data')) {
        final List<dynamic> brandList = response['data'];

        if (brandList is List<dynamic>) {
          return brandList
              .map((BrandJson) => Brand.fromJson(BrandJson))
              .toList();
        } else {
          throw Exception('Invalid API response: data should be list.');
        }
      } else {
        throw Exception('Invalid API response: Unexpected response format.');
      }
    } catch (e) {
      print('Error fetching Brands: $e');
      rethrow;
    }
  }
}
