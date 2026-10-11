import 'package:develsystems_qr_orders/features/orders/data/repositories/orders_repository_impl.dart';
import 'package:develsystems_qr_orders/features/orders/domain/entities/order.dart';
import 'package:develsystems_qr_orders/features/orders/presentation/providers/orders_providers.dart';
import 'package:develsystems_qr_orders/features/orders/presentation/providers/orders_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrdersNotifier extends Notifier<OrdersState> {
  @override
  OrdersState build() => const OrdersState();

  Future<void> init() async {
    final repo = ref.read(ordersRepositoryProvider);
    state = state.copyWith(isLoading: true);
    await repo.recoverSendingToUnknown();
    state =
        state.copyWith(isLoading: false, orders: await repo.pendingAndOthers());
  }

  Future<void> refresh() async {
    final repo = ref.read(ordersRepositoryProvider);
    state = state.copyWith(orders: await repo.pendingAndOthers());
  }

  Future<void> createWithItems(List<OrderItem> items) async {
    final repo = ref.read(ordersRepositoryProvider);
    await repo.createOrder(items);
    await refresh();
  }

  /// Enviar pendientes: bloquea doble toque con isSending.
  Future<void> sendPending() async {
    if (state.isSending) return;
    state = state.copyWith(isSending: true, error: null);
    try {
      final repo = ref.read(ordersRepositoryProvider);
      await repo.sendAllPending();
      state = state.copyWith(orders: await repo.pendingAndOthers());
    } catch (e) {
      state = state.copyWith(error: e.toString());
    } finally {
      state = state.copyWith(isSending: false);
    }
  }

  /// Reintento manual de un unknown (decisión explícita, no masivo).
  Future<void> retryUnknown(Order order) async {
    final repo = ref.read(ordersRepositoryProvider) as OrdersRepositoryImpl;
    await repo.sendOne(order);
    await refresh();
  }
}
