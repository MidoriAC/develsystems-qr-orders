import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  Database? _db;
  String? _overridePath;

  void setOverridePathForTest(String path) => _overridePath = path;

  Future<Database> get db async {
    final current = _db;
    if (current != null && current.isOpen) return current;
    return _db = await _open();
  }

  Future<Database> _open() async {
    final path =
        _overridePath ?? p.join(await getDatabasesPath(), 'qr_orders.db');
    return openDatabase(
      path,
      version: 2,
      onConfigure: (d) async => d.execute('PRAGMA foreign_keys = ON'),
      onCreate: (d, v) async {
        await d.execute('''
          CREATE TABLE products(
            id INTEGER PRIMARY KEY,
            title TEXT NOT NULL,
            price REAL NOT NULL,
            thumbnail TEXT,
            updatedAt TEXT NOT NULL,
            description TEXT,
            category TEXT,
            brand TEXT,
            sku TEXT,
            stock INTEGER,
            rating REAL,
            discountPercentage REAL,
            availabilityStatus TEXT,
            tags TEXT,
            images TEXT
          )''');
        await d.execute('''
          CREATE TABLE orders(
            id TEXT PRIMARY KEY,
            status TEXT NOT NULL,
            createdAt TEXT NOT NULL,
            updatedAt TEXT NOT NULL,
            attempts INTEGER NOT NULL DEFAULT 0,
            lastError TEXT,
            remoteRef TEXT
          )''');
        await d.execute('''
          CREATE TABLE order_items(
            orderId TEXT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
            productId INTEGER NOT NULL,
            qty INTEGER NOT NULL,
            nameSnapshot TEXT NOT NULL,
            priceSnapshot REAL NOT NULL,
            PRIMARY KEY(orderId, productId)
          )''');
      },
      // v1 → v2: columnas enriquecidas (todas nulables: hay filas v1).
      onUpgrade: (d, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          for (final col in [
            'description TEXT',
            'category TEXT',
            'brand TEXT',
            'sku TEXT',
            'stock INTEGER',
            'rating REAL',
            'discountPercentage REAL',
            'availabilityStatus TEXT',
            'tags TEXT',
            'images TEXT',
          ]) {
            await d.execute('ALTER TABLE products ADD COLUMN $col');
          }
        }
      },
    );
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
