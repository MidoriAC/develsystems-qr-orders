import 'package:develsystems_qr_orders/features/catalog/presentation/providers/catalog_providers.dart';
import 'package:develsystems_qr_orders/features/catalog/presentation/providers/catalog_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CatalogNotifier extends Notifier<CatalogState> {
  @override
  CatalogState build() => const CatalogState();

  Future<void> loadCachedThenRefresh() async {
    final repo = ref.read(catalogRepositoryProvider);
    final cached = await repo.cachedProducts();
    state = state.copyWith(items: cached);
    if (cached.isEmpty) state = state.copyWith(isLoading: true);
    try {
      final fresh = await repo.refreshCatalog();
      state = state.copyWith(
          isLoading: false, items: fresh, isOffline: false, error: null);
    } catch (e) {
      state = state.copyWith(
          isLoading: false, error: e.toString(), isOffline: true);
    }
  }

  void setQuery(String q) => state = state.copyWith(query: q);
}
