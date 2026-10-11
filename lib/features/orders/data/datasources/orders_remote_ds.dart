import 'package:dio/dio.dart';

import '../../../../config/constants.dart';
import '../../../../core/http/dio_client.dart';
import '../../domain/entities/order.dart';

class OrdersRemoteDs {
  final Dio dio;
  OrdersRemoteDs(this.dio);

  Future<String> submit(Order order) async {
    try {
      final res = await dio.post('/carts/add', data: {
        'userId': AppConstants.demoUserId,
        'products': order.items
            .map((e) => {'id': e.productId, 'quantity': e.qty})
            .toList(),
      });
      final data = res.data;
      if (data is Map && data['id'] != null) {
        return data['id'].toString();
      }
      throw const ApiException('JSON inválido en confirmación');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
