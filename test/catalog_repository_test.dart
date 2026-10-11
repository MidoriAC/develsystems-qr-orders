import 'package:develsystems_qr_orders/core/db/app_database.dart';
import 'package:develsystems_qr_orders/core/http/dio_client.dart';
import 'package:develsystems_qr_orders/features/catalog/data/datasources/catalog_local_ds.dart';
import 'package:develsystems_qr_orders/features/catalog/data/datasources/catalog_remote_ds.dart';
import 'package:develsystems_qr_orders/features/catalog/data/repositories/catalog_repository_impl.dart';
import 'package:develsystems_qr_orders/features/catalog/domain/entities/product.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class MockCatalogRemote extends Mock implements CatalogRemoteDs {}

Product _p(int id, String title) => Product(
      id: id,
      title: title,
      price: id * 10.0,
      updatedAt: DateTime(2026),
      tags: const ['demo'],
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late CatalogRepositoryImpl repo;
  late MockCatalogRemote remote;

  setUp(() async {
    AppDatabase.instance.setOverridePathForTest(inMemoryDatabasePath);
    await AppDatabase.instance.close();
    remote = MockCatalogRemote();
    repo = CatalogRepositoryImpl(
      local: CatalogLocalDs(() => AppDatabase.instance.db),
      remote: remote,
    );
  });

  tearDown(() => AppDatabase.instance.close());

  test('refresh guarda la descarga y la devuelve', () async {
    when(() => remote.fetchProducts())
        .thenAnswer((_) async => [_p(1, 'Uno'), _p(2, 'Dos')]);
    final fresh = await repo.refreshCatalog();
    expect(fresh, hasLength(2));
    expect(await repo.cachedProducts(), hasLength(2));
  });

  test('fallo de red conserva la última copia válida', () async {
    when(() => remote.fetchProducts())
        .thenAnswer((_) async => [_p(1, 'Uno')]);
    await repo.refreshCatalog();
    when(() => remote.fetchProducts()).thenThrow(
        const ApiException('Sin conexión', isConnection: true));
    expect(() => repo.refreshCatalog(), throwsA(isA<ApiException>()));
    expect(await repo.cachedProducts(), hasLength(1));
  });

  test('findById usa caché sin tocar la red', () async {
    when(() => remote.fetchProducts())
        .thenAnswer((_) async => [_p(5, 'Cinco')]);
    await repo.refreshCatalog();
    reset(remote);
    final found = await repo.findById(5);
    expect(found?.title, 'Cinco');
    verifyNever(() => remote.fetchById(any()));
  });
}
