import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/order.dart';

class OrdersLocalDs {
  final Future<Database> Function() dbGetter;
  OrdersLocalDs(this.dbGetter);

  Future<Order> insertOrder(List<OrderItem> items) async {
    assert(items.isNotEmpty);
    // Fusiona duplicados por productId: una sola fila por producto (PK).
    final merged = <int, OrderItem>{};
    for (final i in items) {
      assert(i.qty > 0, 'cantidad debe ser > 0');
      final prev = merged[i.productId];
      merged[i.productId] = prev == null
          ? i
          : OrderItem(
              productId: i.productId,
              qty: prev.qty + i.qty,
              nameSnapshot: prev.nameSnapshot,
              priceSnapshot: prev.priceSnapshot,
            );
    }
    final db = await dbGetter();
    final id = const Uuid().v4();
    final now = DateTime.now().toIso8601String();
    await db.transaction((txn) async {
      await txn.insert('orders', {
        'id': id,
        'status': 'pending',
        'createdAt': now,
        'updatedAt': now,
        'attempts': 0,
      });
      for (final item in merged.values) {
        await txn.insert('order_items', item.toMap(id));
      }
    });
    return (await getById(id))!;
  }

  Future<List<Order>> getAll() async {
    final db = await dbGetter();
    final rows = await db.query('orders', orderBy: 'createdAt DESC');
    final out = <Order>[];
    for (final r in rows) {
      final items = await _itemsOf(r['id'] as String);
      out.add(_fromRow(r, items));
    }
    return out;
  }

  Future<Order?> getById(String id) async {
    final db = await dbGetter();
    final rows =
        await db.query('orders', where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return _fromRow(rows.first, await _itemsOf(id));
  }

  Future<List<OrderItem>> _itemsOf(String orderId) async {
    final db = await dbGetter();
    final rows = await db
        .query('order_items', where: 'orderId = ?', whereArgs: [orderId]);
    return rows.map(OrderItem.fromMap).toList();
  }

  Order _fromRow(Map<String, Object?> r, List<OrderItem> items) => Order(
        id: r['id'] as String,
        status: orderStatusFromString(r['status'] as String),
        createdAt: DateTime.parse(r['createdAt'] as String),
        updatedAt: DateTime.parse(r['updatedAt'] as String),
        attempts: (r['attempts'] as num).toInt(),
        lastError: r['lastError'] as String?,
        remoteRef: r['remoteRef'] as String?,
        items: items,
      );

  Future<void> updateOrder(Order order) async {
    final db = await dbGetter();
    await db.update('orders', order.toMap(),
        where: 'id = ?', whereArgs: [order.id]);
  }

  /// Al arrancar: ningún pedido queda bloqueado en `sending`.
  Future<void> recoverSending() async {
    final db = await dbGetter();
    await db.update(
      'orders',
      {
        'status': 'unknown',
        'lastError': 'App cerrada durante el envío',
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'status = ?',
      whereArgs: ['sending'],
    );
  }
}
