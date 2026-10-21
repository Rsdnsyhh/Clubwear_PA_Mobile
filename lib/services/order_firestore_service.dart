import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:firebase_auth/firebase_auth.dart';

import '../models/order.dart';

class OrderFirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveOrder(Order order) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw StateError('Pengguna belum login.');
    }

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
      'lines': order.lines.map((line) => {
        'name': line.name,
        'category': line.category,
        'size': line.size,
        'quantity': line.quantity,
        'price': line.price,
        'subtotal': line.subtotal,
      }).toList(),
    });
  }

  Stream<List<Map<String, dynamic>>> watchOrders() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw StateError('Pengguna belum login.');
    }

    return _db
        .collection('users')
        .doc(user.uid)
        .collection('orders')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
      return {
        'id': doc.id,
        ...doc.data(),
      };
    }).toList());
  }
}
