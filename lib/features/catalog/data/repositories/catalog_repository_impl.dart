import '../../domain/entities/product.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../datasources/catalog_local_ds.dart';
import '../datasources/catalog_remote_ds.dart';

/// Conserva última copia válida si falla la red
class CatalogRepositoryImpl implements CatalogRepository {
  final CatalogLocalDs local;
  final CatalogRemoteDs remote;
  CatalogRepositoryImpl({required this.local, required this.remote});

  @override
  Future<List<Product>> cachedProducts() => local.getAll();

  @override
  Future<List<Product>> refreshCatalog() async {
    final fresh = await remote.fetchProducts();
    await local.upsertAll(fresh);
    return local.getAll();
  }

  @override
  Future<Product?> findById(int id) async {
    final cached = await local.getById(id);
    if (cached != null) return cached;
    try {
      final remoteOne = await remote.fetchById(id);
      if (remoteOne != null) await local.upsertAll([remoteOne]);
      return remoteOne;
    } catch (_) {
      return null; // offline sin dato: la UI informa "no disponible offline"
    }
  }
}
