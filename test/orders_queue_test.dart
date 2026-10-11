import 'package:develsystems_qr_orders/core/db/app_database.dart';
import 'package:develsystems_qr_orders/core/http/dio_client.dart';
import 'package:develsystems_qr_orders/features/orders/data/datasources/orders_local_ds.dart';
import 'package:develsystems_qr_orders/features/orders/data/datasources/orders_remote_ds.dart';
import 'package:develsystems_qr_orders/features/orders/data/repositories/orders_repository_impl.dart';
import 'package:develsystems_qr_orders/features/orders/domain/entities/order.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class MockOrdersRemote extends Mock implements OrdersRemoteDs {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late OrdersRepositoryImpl repo;
  late MockOrdersRemote remote;

  setUpAll(() {
    registerFallbackValue(Order(
      id: 'fallback',
      status: OrderStatus.pending,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    ));
  });

  setUp(() async {
    AppDatabase.instance.setOverridePathForTest(inMemoryDatabasePath);
    await AppDatabase.instance.close();
    remote = MockOrdersRemote();
    repo = OrdersRepositoryImpl(
      local: OrdersLocalDs(() => AppDatabase.instance.db),
      remote: remote,
    );
  });

  tearDown(() => AppDatabase.instance.close());

  const item = OrderItem(
      productId: 1, qty: 2, nameSnapshot: 'A', priceSnapshot: 9.99);

  test('éxito confirma con referencia y excluye de reenvíos', () async {
    when(() => remote.submit(any())).thenAnswer((_) async => 'cart-1');
    final created = await repo.createOrder([item]);
    await repo.sendAllPending();
    final fetched = await repo.getById(created.id);
    expect(fetched!.status, OrderStatus.confirmed);
    expect(fetched.remoteRef, 'cart-1');
    clearInteractions(remote);
    await repo.sendAllPending();
    verifyNever(() => remote.submit(any()));
  });

  test('error HTTP marca error y reintenta con el mismo ID', () async {
    when(() => remote.submit(any())).thenThrow(
        const ApiException('HTTP 500', statusCode: 500));
    final created = await repo.createOrder([item]);
    await repo.sendAllPending();
    final fetched = await repo.getById(created.id);
    expect(fetched!.status, OrderStatus.error);
    expect(fetched.attempts, 1);
    expect(fetched.lastError, contains('500'));
    expect(await repo.pendingAndOthers(), hasLength(1));
  });

  test('timeout deja unknown y no entra en lote masivo', () async {
    when(() => remote.submit(any()))
        .thenThrow(const ApiException('Timeout', isTimeout: true));
    final created = await repo.createOrder([item]);
    await repo.sendAllPending();
    expect((await repo.getById(created.id))!.status, OrderStatus.unknown);
    clearInteractions(remote);
    await repo.sendAllPending();
    verifyNever(() => remote.submit(any()));
  });

  test('doble ejecución no inicia dos lotes', () async {
    when(() => remote.submit(any())).thenAnswer((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      return 'cart-9';
    });
    await repo.createOrder([item]);
    await Future.wait([repo.sendAllPending(), repo.sendAllPending()]);
    verify(() => remote.submit(any())).called(1);
  });
}
