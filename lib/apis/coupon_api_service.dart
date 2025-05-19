import 'package:flutter_ecommerce/models/coupon.dart';
import 'package:flutter_ecommerce/models/dto/coupon_query_dto.dart';
import 'package:flutter_ecommerce/models/dto/create_coupon_dto.dart';
import 'package:flutter_ecommerce/models/dto/validate_coupon_response.dart';
import 'package:flutter_ecommerce/services/api_client.dart';

class CouponApiService {
  final ApiClient _apiClient;

  CouponApiService(this._apiClient);

  Future<List<Coupon>> getCoupons({CouponQuery? query}) async {
    try {
      final queryParams = query?.toQueryMap() ?? {};
      final uri = Uri(
        path: '/coupons',
        queryParameters: queryParams,
      );

      final response = await _apiClient.get(uri.toString());

      if (response is Map<String, dynamic> && response.containsKey('data')) {
        final List<dynamic> commentList = response['data'];

        if (commentList is List<dynamic>) {
          return commentList
              .map((commentJson) => Coupon.fromJson(commentJson))
              .toList();
        } else {
          throw Exception('Invalid API response: data should be a list.');
        }
      } else {
        throw Exception('Invalid API response: Unexpected response format.');
      }
    } catch (e) {
      print('Error fetching Comments: $e');
      rethrow;
    }
  }

  // Future<Coupon> getCouponById(String id) async {
  //   final response = await _apiClient.get('/coupons/$id');
  //   return Coupon.fromJson(response.data);
  // }

  Future create(CreateCouponDto dto) async {
    final response = await _apiClient.post('/coupons', body: dto.toJson());
    return response;
  }

  Future toggleStatus(String id, bool isActive) async {
    final response = await _apiClient.patch('/coupons/$id', body: {
      'isActive': isActive,
    });
    return response;
  }

  Future<void> remove(String id) async {
    final res = await _apiClient.delete('/coupons/$id');
    return res;
  }

  Future<ValidateCouponResponse> validateCoupon(
      String code, int totalAmount) async {
    final response = await _apiClient.post('/coupons/validate/$code', body: {
      'totalAmount': totalAmount,
    });

    final apiResponse = ApiResponse.fromJson(
      response,
      (dataJson) => ValidateCouponResponse.fromJson(dataJson),
    );

    return apiResponse.data;
  }
}
