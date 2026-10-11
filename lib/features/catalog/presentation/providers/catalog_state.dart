import 'package:develsystems_qr_orders/features/catalog/domain/entities/product.dart';

class CatalogState {
  final bool isLoading;
  final List<Product> items;
  final String? error;
  final bool isOffline;

  const CatalogState(
      {this.isLoading = false,
      this.items = const [],
      this.error,
      this.isOffline = false});

  CatalogState copyWith(
          {bool? isLoading,
          List<Product>? items,
          String? error,
          bool? isOffline}) =>
      CatalogState(
        isLoading: isLoading ?? this.isLoading,
        items: items ?? this.items,
        error: error,
        isOffline: isOffline ?? this.isOffline,
      );
}
