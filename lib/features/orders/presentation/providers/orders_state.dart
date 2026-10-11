import 'package:develsystems_qr_orders/features/orders/domain/entities/order.dart';

class OrdersState {
  final bool isLoading;
  final bool isSending;
  final List<Order> orders;
  final String? error;

  const OrdersState(
      {this.isLoading = false,
      this.isSending = false,
      this.orders = const [],
      this.error});

  OrdersState copyWith(
          {bool? isLoading,
          bool? isSending,
          List<Order>? orders,
          String? error}) =>
      OrdersState(
        isLoading: isLoading ?? this.isLoading,
        isSending: isSending ?? this.isSending,
        orders: orders ?? this.orders,
        error: error,
      );
}
