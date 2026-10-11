import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../catalog/domain/entities/product.dart';
import '../../domain/entities/order.dart';

class DraftNotifier extends Notifier<Map<int, OrderItem>> {
  @override
  Map<int, OrderItem> build() => {};

  void addProduct(Product p, [int qty = 1]) {
    final prev = state[p.id];
    state = {
      ...state,
      p.id: OrderItem(
        productId: p.id,
        qty: (prev?.qty ?? 0) + qty,
        nameSnapshot: p.title,
        priceSnapshot: p.price,
      ),
    };
  }

  void increment(int productId) {
    final prev = state[productId];
    if (prev == null) return;
    state = {
      ...state,
      productId: OrderItem(
        productId: prev.productId,
        qty: prev.qty + 1,
        nameSnapshot: prev.nameSnapshot,
        priceSnapshot: prev.priceSnapshot,
      ),
    };
  }

  void decrement(int productId) {
    final prev = state[productId];
    if (prev == null) return;
    if (prev.qty <= 1) {
      final next = Map<int, OrderItem>.of(state)..remove(productId);
      state = next;
      return;
    }
    state = {
      ...state,
      productId: OrderItem(
        productId: prev.productId,
        qty: prev.qty - 1,
        nameSnapshot: prev.nameSnapshot,
        priceSnapshot: prev.priceSnapshot,
      ),
    };
  }

  void remove(int productId) {
    final next = Map<int, OrderItem>.of(state)..remove(productId);
    state = next;
  }

  void clear() => state = {};

  double get total => state.values.fold(0, (s, e) => s + e.lineTotal);
}

final draftProvider =
    NotifierProvider<DraftNotifier, Map<int, OrderItem>>(DraftNotifier.new);
