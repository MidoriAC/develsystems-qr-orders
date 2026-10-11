import '../entities/order.dart';

abstract class OrdersRepository {
  Future<Order> createOrder(List<OrderItem> items);
  Future<List<Order>> pendingAndOthers();
  Future<Order?> getById(String id);
  Future<void> recoverSendingToUnknown();
  Future<Order> sendOne(Order order);
  Future<void> sendAllPending();
}
