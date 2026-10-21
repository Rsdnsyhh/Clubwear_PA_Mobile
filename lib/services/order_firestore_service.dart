import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:firebase_auth/firebase_auth.dart';

import '../models/order.dart';

class OrderFirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveOrder(Order order) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('Pengguna belum login.');

    await _db
        .collection('users')
        .doc(user.uid)
        .collection('orders')
        .doc(order.id)
        .set({
      'orderCode': order.id,
      'date': Timestamp.fromDate(order.date),
      'address': order.address,
      'subtotal': order.subtotal,
      'shipping': order.shipping,
      'total': order.total,
      'itemCount': order.itemCount,
      'status': 'Menunggu pembayaran',
      'lines': order.lines
          .map((line) => {
        'name': line.name,
        'category': line.category,
        'size': line.size,
        'quantity': line.quantity,
        'price': line.price,
        'subtotal': line.subtotal,
      })
          .toList(),
    });
  }

  Stream<List<Map<String, dynamic>>> watchOrders() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('Pengguna belum login.');

    return _db
        .collection('users')
        .doc(user.uid)
        .collection('orders')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
      return {'id': doc.id, ...doc.data()};
    }).toList());
  }

  /// Dipakai dashboard admin — membaca semua order dari semua user.
  /// CATATAN: butuh index composite `orders.date` (desc).
  Stream<List<Order>> watchAllOrders() {
    return _db
        .collectionGroup('orders')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
      final data = doc.data();
      final rawLines = (data['lines'] as List<dynamic>? ?? []);
      final lines = rawLines.map((l) {
        final line = l as Map<String, dynamic>;
        return OrderLine(
          name: line['name'] as String? ?? '',
          category: line['category'] as String? ?? '',
          size: line['size'] as String? ?? '',
          quantity: (line['quantity'] as num?)?.toInt() ?? 1,
          price: (line['price'] as num?)?.toInt() ?? 0,
        );
      }).toList();

      return Order(
        id: data['orderCode'] as String? ?? doc.id,
        date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
        lines: lines,
        subtotal: (data['subtotal'] as num?)?.toInt() ?? 0,
        shipping: (data['shipping'] as num?)?.toInt() ?? 0,
        address: data['address'] as String? ?? '',
      );
    }).toList());
  }
}