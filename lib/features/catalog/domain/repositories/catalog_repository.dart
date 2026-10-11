import '../entities/product.dart';

/// Contrato del catálogo: la UI solo lee SQLite, la red solo refresca.
abstract class CatalogRepository {
  Future<List<Product>> cachedProducts();
  Future<List<Product>> refreshCatalog();
  Future<Product?> findById(int id);
}
