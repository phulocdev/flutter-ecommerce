import 'package:flutter_ecommerce/models/dto/create_order_dto.dart';
import 'package:flutter_ecommerce/models/dto/create_order_response.dart';
import 'package:flutter_ecommerce/services/api_client.dart';

class OrderApiService {
  final ApiClient _apiClient;

  OrderApiService(this._apiClient);

  Future create(CreateOrderRequestDto dto) async {
    try {
      final response = await _apiClient.post('/orders', body: dto.toJson());
      return CreateOrderResponseDto.fromJson(response);
    } on ApiException catch (e) {
      rethrow;
    } catch (e) {
      print("Lỗi không xác định: $e");
      rethrow;
    }
  }
}
