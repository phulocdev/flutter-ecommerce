import 'package:flutter_ecommerce/models/dto/create_order_dto.dart';
import 'package:flutter_ecommerce/models/dto/create_order_response.dart';
import 'package:flutter_ecommerce/models/dto/order_detail.dart';
import 'package:flutter_ecommerce/services/api_client.dart';

class OrderApiService {
  final ApiClient _apiClient;

  OrderApiService(this._apiClient);

  Future<CreateOrderResponseDto> create(CreateOrderRequestDto dto) async {
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

  Future<List<Order>> getOrdersByCustomer() async {
    try {
      final uri = Uri(path: '/orders/customer');

      final response = await _apiClient.get(uri.toString());

      if (response is Map<String, dynamic> && response.containsKey('data')) {
        final List<dynamic> orderList = response['data'];

        if (orderList is List<dynamic>) {
          return orderList
              .map((orderJson) => Order.fromJson(orderJson))
              .toList();
        } else {
          throw Exception('Invalid API response: data should be a list.');
        }
      } else {
        throw Exception('Invalid API response: Unexpected response format.');
      }
    } catch (e) {
      print('Error fetching orders: $e');
      rethrow;
    }
  }

  Future<List<OrderDetail>> getOrderDetail(String id) async {
    try {
      final uri = Uri(path: '/orders/$id');

      final response = await _apiClient.get(uri.toString());

      if (response is Map<String, dynamic> && response.containsKey('data')) {
        final List<dynamic> orderDetailList = response['data'];

        if (orderDetailList is List<dynamic>) {
          return orderDetailList
              .map((orderJson) => OrderDetail.fromJson(orderJson))
              .toList();
        } else {
          throw Exception('Invalid API response: data should be a list.');
        }
      } else {
        throw Exception('Invalid API response: Unexpected response format.');
      }
    } catch (e) {
      print('Error fetching orders: $e');
      rethrow;
    }
  }
}
