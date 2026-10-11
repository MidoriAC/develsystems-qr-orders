import '../../../../core/http/dio_client.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/orders_repository.dart';
import '../datasources/orders_local_ds.dart';
import '../datasources/orders_remote_ds.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  final OrdersLocalDs local;
  final OrdersRemoteDs remote;
  bool _sendingBatch = false;

  OrdersRepositoryImpl({required this.local, required this.remote});

  @override
  Future<Order> createOrder(List<OrderItem> items) => local.insertOrder(items);

  @override
  Future<List<Order>> pendingAndOthers() => local.getAll();

  @override
  Future<Order?> getById(String id) => local.getById(id);

  @override
  Future<void> recoverSendingToUnknown() => local.recoverSending();

  @override
  Future<Order> sendOne(Order order) async {
    if (order.status == OrderStatus.confirmed) return order;
    var current = order.copyWith(
      status: OrderStatus.sending,
      attempts: order.attempts + 1,
      updatedAt: DateTime.now(),
    );
    await local.updateOrder(current);
    try {
      final ref = await remote.submit(current);
      current = current.copyWith(
        status: OrderStatus.confirmed,
        remoteRef: ref,
      );
      await local.updateOrder(current);
      return current;
    } on ApiException catch (e) {
      if (e.isTimeout) {
        //? Excepción para el timeOut
        current = current.copyWith(
          status: OrderStatus.unknown,
          lastError: e.message,
        );
      } else {
        current = current.copyWith(
          status: OrderStatus.error,
          lastError: e.message,
        );
      }
      await local.updateOrder(current);
      return current;
    }
  }

  @override
  Future<void> sendAllPending() async {
    if (_sendingBatch) return; // doble toque: no dos lotes
    _sendingBatch = true;
    try {
      final all = await local.getAll();
      // Solo pending/error reintentable. Unknown requiere decisión manual.
      final targets = all.where((o) =>
          o.status == OrderStatus.pending || o.status == OrderStatus.error);
      for (final o in targets) {
        await sendOne(o);
      }
    } finally {
      _sendingBatch = false;
    }
  }
}
