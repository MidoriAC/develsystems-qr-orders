enum OrderStatus { pending, sending, confirmed, error, unknown }

OrderStatus orderStatusFromString(String raw) {
  switch (raw) {
    case 'pending':
      return OrderStatus.pending;
    case 'sending':
      return OrderStatus.sending;
    case 'confirmed':
      return OrderStatus.confirmed;
    case 'error':
      return OrderStatus.error;
    default:
      return OrderStatus.unknown;
  }
}

String orderStatusToString(OrderStatus s) => s.name;

class OrderItem {
  final int productId;
  final int qty;
  final String nameSnapshot;
  final double priceSnapshot;

  const OrderItem({
    required this.productId,
    required this.qty,
    required this.nameSnapshot,
    required this.priceSnapshot,
  });

  double get lineTotal => priceSnapshot * qty;

  Map<String, Object?> toMap(String orderId) => {
        'orderId': orderId,
        'productId': productId,
        'qty': qty,
        'nameSnapshot': nameSnapshot,
        'priceSnapshot': priceSnapshot,
      };

  factory OrderItem.fromMap(Map<String, Object?> m) => OrderItem(
        productId: (m['productId'] as num).toInt(),
        qty: (m['qty'] as num).toInt(),
        nameSnapshot: (m['nameSnapshot'] as String?) ?? '',
        priceSnapshot: (m['priceSnapshot'] as num).toDouble(),
      );
}

class Order {
  final String id;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int attempts;
  final String? lastError;
  final String? remoteRef;
  final List<OrderItem> items;

  const Order({
    required this.id,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.attempts = 0,
    this.lastError,
    this.remoteRef,
    this.items = const [],
  });

  double get totalEstimated => items.fold(0, (sum, e) => sum + e.lineTotal);

  Order copyWith({
    OrderStatus? status,
    int? attempts,
    String? lastError,
    String? remoteRef,
    List<OrderItem>? items,
    DateTime? updatedAt,
  }) =>
      Order(
        id: id,
        status: status ?? this.status,
        createdAt: createdAt,
        updatedAt: updatedAt ?? DateTime.now(),
        attempts: attempts ?? this.attempts,
        lastError: lastError,
        remoteRef: remoteRef ?? this.remoteRef,
        items: items ?? this.items,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'status': orderStatusToString(status),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'attempts': attempts,
        'lastError': lastError,
        'remoteRef': remoteRef,
      };
}
