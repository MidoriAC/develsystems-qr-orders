import 'package:develsystems_qr_orders/features/catalog/domain/entities/product.dart';

class CatalogState {
  final bool isLoading;
  final List<Product> items;
  final String? error;
  final bool isOffline;
  final String query;

  const CatalogState(
      {this.isLoading = false,
      this.items = const [],
      this.error,
      this.isOffline = false,
      this.query = ''});

  CatalogState copyWith(
          {bool? isLoading,
          List<Product>? items,
          String? error,
          bool? isOffline,
          String? query}) =>
      CatalogState(
        isLoading: isLoading ?? this.isLoading,
        items: items ?? this.items,
        error: error,
        isOffline: isOffline ?? this.isOffline,
        query: query ?? this.query,
      );

  /// Búsqueda en memoria sobre la caché (funciona offline):
  /// nombre, categoría, marca y etiquetas.
  List<Product> get filtered {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return items;
    return items.where((p) {
      return p.title.toLowerCase().contains(q) ||
          (p.category?.toLowerCase().contains(q) ?? false) ||
          (p.brand?.toLowerCase().contains(q) ?? false) ||
          p.tags.any((t) => t.toLowerCase().contains(q));
    }).toList();
  }
}
