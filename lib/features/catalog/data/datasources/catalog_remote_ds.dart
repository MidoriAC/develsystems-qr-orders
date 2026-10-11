import 'package:dio/dio.dart';

import '../../../../config/constants.dart';
import '../../../../core/http/dio_client.dart';
import '../../domain/entities/product.dart';

/// GET https://dummyjson.com/products?limit=30 y GET /products/{id}.
class CatalogRemoteDs {
  final Dio dio;
  CatalogRemoteDs(this.dio);

  Future<List<Product>> fetchProducts() async {
    try {
      final res = await dio.get('/products',
          queryParameters: {'limit': AppConstants.catalogLimit});
      final data = res.data as Map<String, dynamic>;
      final list = (data['products'] as List).cast<Map<String, dynamic>>();
      return list.map(Product.fromDummyJson).toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Product?> fetchById(int id) async {
    try {
      final res = await dio.get('/products/$id');
      return Product.fromDummyJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final mapped = mapDioError(e);
      if (mapped.statusCode == 404) return null;
      throw mapped;
    }
  }
}
