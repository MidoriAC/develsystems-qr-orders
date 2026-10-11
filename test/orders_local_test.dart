import 'package:develsystems_qr_orders/core/db/app_database.dart';
import 'package:develsystems_qr_orders/features/orders/data/datasources/orders_local_ds.dart';
import 'package:develsystems_qr_orders/features/orders/domain/entities/order.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late OrdersLocalDs ds;

  setUp(() async {
    AppDatabase.instance.setOverridePathForTest(inMemoryDatabasePath);
    await AppDatabase.instance.close();
    ds = OrdersLocalDs(() => AppDatabase.instance.db);
  });

  tearDown(() => AppDatabase.instance.close());

  const itemA =
      OrderItem(productId: 1, qty: 1, nameSnapshot: 'A', priceSnapshot: 10);
  const itemB =
      OrderItem(productId: 3, qty: 2, nameSnapshot: 'C', priceSnapshot: 5);

  test('fusiona duplicados por producto en una sola fila', () async {
    final order = await ds.insertOrder([
      itemA,
      const OrderItem(
          productId: 1, qty: 2, nameSnapshot: 'A', priceSnapshot: 10),
    ]);
    expect(order.items, hasLength(1));
    expect(order.items.first.qty, 3);
    expect(order.totalEstimated, 30);
  });

  test('persiste y recupera con total estimado', () async {
    final created = await ds.insertOrder([itemA, itemB]);
    final fetched = await ds.getById(created.id);
    expect(fetched, isNotNull);
    expect(fetched!.status, OrderStatus.pending);
    expect(fetched.items, hasLength(2));
    expect(fetched.totalEstimated, 20);
    expect(await ds.getAll(), hasLength(1));
  });

  test('recoverSending no deja pedidos bloqueados en sending', () async {
    final created = await ds.insertOrder([itemA]);
    await ds.updateOrder(created.copyWith(status: OrderStatus.sending));
    await ds.recoverSending();
    final fetched = await ds.getById(created.id);
    expect(fetched!.status, OrderStatus.unknown);
    expect(fetched.lastError, isNotNull);
  });
}
