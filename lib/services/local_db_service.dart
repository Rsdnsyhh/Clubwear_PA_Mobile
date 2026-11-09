import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../models/order.dart';

/// Database lokal (SQLite) untuk data yang sebelumnya hanya tersimpan di
/// memori. Yaitu favorit, alamat pengiriman, dan riwayat pesanan.
/// Menggunakan shared_preferences jika tidak mendukung SQLite
class LocalDbService {
  LocalDbService._();

  static final LocalDbService instance = LocalDbService._();

  static const String _dbName = 'clubwear_local.db';
  static const int _dbVersion = 1;

  Database? _db;

  /// true jika platform ini mendukung sqflite.
  bool get usesSqlite =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS);

  String get backendName =>
      usesSqlite ? 'SQLite (sqflite)' : 'shared_preferences (tanpa sqflite)';

  Future<Database> get _database async => _db ??= await _open();

  // ---- Penyimpanan cadangan untuk platform tanpa sqflite ----
  SharedPreferences? _prefs;

  Future<SharedPreferences> get _store async =>
      _prefs ??= await SharedPreferences.getInstance();

  String _favKey(String uid) => 'fav_$uid';
  String _addrKey(String uid) => 'addr_$uid';
  String _ordersKey(String uid) => 'orders_$uid';

  Map<String, dynamic> _orderToMap(Order o) => {
        'id': o.id,
        'date_ms': o.date.millisecondsSinceEpoch,
        'subtotal': o.subtotal,
        'shipping': o.shipping,
        'address': o.address,
        'lines': [
          for (final l in o.lines)
            {
              'name': l.name,
              'category': l.category,
              'size': l.size,
              'quantity': l.quantity,
              'price': l.price,
            },
        ],
      };

  Order _orderFromMap(Map<String, dynamic> m) => Order(
        id: m['id'] as String,
        date: DateTime.fromMillisecondsSinceEpoch((m['date_ms'] as num).toInt()),
        subtotal: (m['subtotal'] as num).toInt(),
        shipping: (m['shipping'] as num).toInt(),
        address: m['address'] as String? ?? '',
        lines: [
          for (final l in (m['lines'] as List? ?? const []))
            OrderLine(
              name: (l as Map)['name'] as String,
              category: l['category'] as String,
              size: l['size'] as String,
              quantity: (l['quantity'] as num).toInt(),
              price: (l['price'] as num).toInt(),
            ),
        ],
      );

  Future<Database> _open() async {
    final path = p.join(await getDatabasesPath(), _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
      onUpgrade: (db, oldVersion, newVersion) async {},
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE favorites (
        user_uid   TEXT NOT NULL,
        product_id TEXT NOT NULL,
        PRIMARY KEY (user_uid, product_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE user_profiles (
        user_uid TEXT PRIMARY KEY,
        address  TEXT NOT NULL DEFAULT ''
      )
    ''');

    await db.execute('''
      CREATE TABLE orders (
        user_uid TEXT NOT NULL,
        id       TEXT NOT NULL,
        date_ms  INTEGER NOT NULL,
        subtotal INTEGER NOT NULL,
        shipping INTEGER NOT NULL,
        address  TEXT NOT NULL,
        PRIMARY KEY (user_uid, id)
      )
    ''');

    await db.execute('''
      CREATE TABLE order_lines (
        line_id  INTEGER PRIMARY KEY AUTOINCREMENT,
        user_uid TEXT NOT NULL,
        order_id TEXT NOT NULL,
        name     TEXT NOT NULL,
        category TEXT NOT NULL,
        size     TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        price    INTEGER NOT NULL,
        FOREIGN KEY (user_uid, order_id)
          REFERENCES orders (user_uid, id) ON DELETE CASCADE
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_order_lines_order ON order_lines (user_uid, order_id)',
    );
  }

  Future<Set<String>> getFavoriteIds(String uid) async {
    if (!usesSqlite) {
      final sp = await _store;
      return (sp.getStringList(_favKey(uid)) ?? const <String>[]).toSet();
    }
    final db = await _database;
    final rows = await db.query(
      'favorites',
      columns: ['product_id'],
      where: 'user_uid = ?',
      whereArgs: [uid],
    );

    return rows.map((r) => r['product_id'] as String).toSet();
  }

  Future<void> addFavorite(String uid, String productId) async {
    if (!usesSqlite) {
      final sp = await _store;
      final list = sp.getStringList(_favKey(uid)) ?? <String>[];
      if (!list.contains(productId)) {
        await sp.setStringList(_favKey(uid), [...list, productId]);
      }
      return;
    }
    final db = await _database;
    await db.insert(
      'favorites',
      {'user_uid': uid, 'product_id': productId},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> removeFavorite(String uid, String productId) async {
    if (!usesSqlite) {
      final sp = await _store;
      final list = sp.getStringList(_favKey(uid)) ?? <String>[];
      await sp.setStringList(
        _favKey(uid),
        list.where((id) => id != productId).toList(),
      );
      return;
    }
    final db = await _database;
    await db.delete(
      'favorites',
      where: 'user_uid = ? AND product_id = ?',
      whereArgs: [uid, productId],
    );
  }


  Future<String> getAddress(String uid) async {
    if (!usesSqlite) {
      final sp = await _store;
      return sp.getString(_addrKey(uid)) ?? '';
    }
    final db = await _database;
    final rows = await db.query(
      'user_profiles',
      columns: ['address'],
      where: 'user_uid = ?',
      whereArgs: [uid],
      limit: 1,
    );

    if (rows.isEmpty) return '';
    return rows.first['address'] as String? ?? '';
  }

  Future<void> saveAddress(String uid, String address) async {
    if (!usesSqlite) {
      final sp = await _store;
      await sp.setString(_addrKey(uid), address);
      return;
    }
    final db = await _database;
    await db.insert(
      'user_profiles',
      {'user_uid': uid, 'address': address},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }


  /// Menyimpan satu pesanan beserta semua barisnya dalam satu transaksi
  Future<void> saveOrder(String uid, Order order) async {
    if (!usesSqlite) {
      final sp = await _store;
      final raw = sp.getStringList(_ordersKey(uid)) ?? <String>[];
      final kept = raw.where((s) {
        final m = jsonDecode(s) as Map<String, dynamic>;
        return m['id'] != order.id;
      }).toList();
      kept.add(jsonEncode(_orderToMap(order)));
      await sp.setStringList(_ordersKey(uid), kept);
      return;
    }
    final db = await _database;

    await db.transaction((txn) async {
      await txn.insert(
        'orders',
        {
          'user_uid': uid,
          'id': order.id,
          'date_ms': order.date.millisecondsSinceEpoch,
          'subtotal': order.subtotal,
          'shipping': order.shipping,
          'address': order.address,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      final batch = txn.batch();
      for (final line in order.lines) {
        batch.insert('order_lines', {
          'user_uid': uid,
          'order_id': order.id,
          'name': line.name,
          'category': line.category,
          'size': line.size,
          'quantity': line.quantity,
          'price': line.price,
        });
      }
      await batch.commit(noResult: true);
    });
  }

  Future<List<Order>> getOrders(String uid) async {
    if (!usesSqlite) {
      final sp = await _store;
      final raw = sp.getStringList(_ordersKey(uid)) ?? const <String>[];
      final orders = raw
          .map((s) => _orderFromMap(jsonDecode(s) as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      return orders;
    }
    final db = await _database;

    final orderRows = await db.query(
      'orders',
      where: 'user_uid = ?',
      whereArgs: [uid],
      orderBy: 'date_ms DESC',
    );

    if (orderRows.isEmpty) return [];

    final lineRows = await db.query(
      'order_lines',
      where: 'user_uid = ?',
      whereArgs: [uid],
      orderBy: 'line_id ASC',
    );

    final linesByOrder = <String, List<OrderLine>>{};
    for (final r in lineRows) {
      final orderId = r['order_id'] as String;
      linesByOrder.putIfAbsent(orderId, () => []).add(
            OrderLine(
              name: r['name'] as String,
              category: r['category'] as String,
              size: r['size'] as String,
              quantity: (r['quantity'] as num).toInt(),
              price: (r['price'] as num).toInt(),
            ),
          );
    }

    return orderRows.map((r) {
      final id = r['id'] as String;
      return Order(
        id: id,
        date: DateTime.fromMillisecondsSinceEpoch(
          (r['date_ms'] as num).toInt(),
        ),
        lines: linesByOrder[id] ?? const [],
        subtotal: (r['subtotal'] as num).toInt(),
        shipping: (r['shipping'] as num).toInt(),
        address: r['address'] as String,
      );
    }).toList();
  }


  /// Menghapus seluruh data lokal satu pengguna
  Future<void> clearUser(String uid) async {
    if (!usesSqlite) {
      final sp = await _store;
      await sp.remove(_favKey(uid));
      await sp.remove(_addrKey(uid));
      await sp.remove(_ordersKey(uid));
      return;
    }
    final db = await _database;
    await db.transaction((txn) async {
      await txn.delete('favorites', where: 'user_uid = ?', whereArgs: [uid]);
      await txn.delete('user_profiles', where: 'user_uid = ?', whereArgs: [uid]);
      // order_lines ikut terhapus lewat ON DELETE CASCADE.
      await txn.delete('orders', where: 'user_uid = ?', whereArgs: [uid]);
    });
  }

  @visibleForTesting
  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
