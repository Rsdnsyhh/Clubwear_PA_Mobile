
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/cart_item.dart';
import '../models/product.dart';

class CartFirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Referensi keranjang milik pengguna yang sedang login.
  CollectionReference<Map<String, dynamic>> _cartCollection() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw StateError('Pengguna belum login.');
    }

    return _db
        .collection('users')
        .doc(user.uid)
        .collection('cartItems');
  }

  // Menyimpan satu item keranjang ke Firestore.
  Future<void> saveItem(CartItem item) async {
    await _cartCollection().doc(item.key).set({
      'productId': item.product.id,
      'size': item.size,
      'quantity': item.quantity,
    });
  }

  // Menghapus satu item keranjang.
  Future<void> removeItem(String key) async {
    await _cartCollection().doc(key).delete();
  }

  // Mengosongkan keranjang pengguna.
  Future<void> clearCart() async {
    final collection = _cartCollection();
    final snapshot = await collection.get();

    final batch = _db.batch();

    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  // Membaca keranjang dan mengikuti perubahannya.
  Stream<List<CartItem>> watchCart(List<Product> products) {
    return _cartCollection().snapshots().map((snapshot) {
      final result = <CartItem>[];

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final productId = data['productId'] as String?;
        final size = data['size'] as String?;
        final quantity = (data['quantity'] as num?)?.toInt() ?? 1;

        final matches = products.where((p) => p.id == productId);

        if (matches.isEmpty || size == null || quantity < 1) {
          continue;
        }

        result.add(
          CartItem(
            product: matches.first,
            size: size,
            quantity: quantity,
          ),
        );
      }

      return result;
    });
  }
}
