import 'package:sqflite/sqflite.dart';

import '../../domain/entities/product.dart';

/// Lectura/escritura SQLite de productos. No toca la tabla orders.
class CatalogLocalDs {
  final Future<Database> Function() dbGetter;
  CatalogLocalDs(this.dbGetter);

  Future<List<Product>> getAll() async {
    final db = await dbGetter();
    final rows = await db.query('products', orderBy: 'id ASC');
    return rows.map(Product.fromMap).toList();
  }

  Future<Product?> getById(int id) async {
    final db = await dbGetter();
    final rows =
        await db.query('products', where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return Product.fromMap(rows.first);
  }

  Future<void> upsertAll(List<Product> items) async {
    final db = await dbGetter();
    final batch = db.batch();
    for (final item in items) {
      batch.insert('products', item.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }
}
