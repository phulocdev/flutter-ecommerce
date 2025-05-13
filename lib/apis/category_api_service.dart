import 'package:flutter_ecommerce/models/category.dart';
import 'package:flutter_ecommerce/services/api_client.dart';

class CategoryApiService {
  final ApiClient _apiClient;
  CategoryApiService(this._apiClient);

  Future<List<Category>> getCategories() async {
    try {
      final response = await _apiClient.get('/categories');

      if (response is Map<String, dynamic> && response.containsKey('data')) {
        final List<dynamic> CategoryList = response['data'];

        if (CategoryList is List<dynamic>) {
          return CategoryList.map(
              (CategoryJson) => Category.fromJson(CategoryJson)).toList();
        } else {
          throw Exception('Invalid API response: data should be list.');
        }
      } else {
        throw Exception('Invalid API response: Unexpected response format.');
      }
    } catch (e) {
      print('Error fetching Categorys: $e');
      rethrow;
    }
  }
}
