import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product.dart';

class ProductFirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. Tambah 1 Produk Baru
  Future<void> addProduct(Product product) async {
    final docRef = _db.collection('products').doc();
    await docRef.set({
      'name': product.name,
      'category': product.category.name,
      'price': product.price,
      'originalPrice': product.originalPrice,
      'sold': product.sold,
      'stock': product.stock,
      'isNew': product.isNew,
      'image': product.image,
      'sizes': product.sizes,
      'color': product.color.toARGB32(),
    });
  }

  // 2. Update Produk
  Future<void> updateProduct(Product product) async {
    await _db.collection('products').doc(product.id).update({
      'name': product.name,
      'category': product.category.name,
      'price': product.price,
      'originalPrice': product.originalPrice,
      'sold': product.sold,
      'stock': product.stock,
      'isNew': product.isNew,
      'image': product.image,
      'sizes': product.sizes,
      'color': product.color.toARGB32(),
    });
  }

  // 3. Hapus Produk
  Future<void> deleteProduct(String productId) async {
    await _db.collection('products').doc(productId).delete();
  }

  // 4. Update Stok & Jumlah Terjual
  Future<void> incrementSoldAndDecreaseStock(String productId, int quantity) async {
    final docRef = _db.collection('products').doc(productId);

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);

      if (snapshot.exists) {
        final currentStock = (snapshot.data()?['stock'] as num?)?.toInt() ?? 0;
        final currentSold = (snapshot.data()?['sold'] as num?)?.toInt() ?? 0;

        transaction.update(docRef, {
          'stock': currentStock - quantity,
          'sold': currentSold + quantity,
        });
      }
    });
  }

  // Mengunggah produk lokal ke Firestore.
  Future<void> uploadProducts(List<Product> products) async {
    final batch = _db.batch();

    for (final product in products) {
      final docRef = _db.collection('products').doc(product.id);

      batch.set(docRef, {
        'name': product.name,
        'category': product.category.name,
        'price': product.price,
        'originalPrice': product.originalPrice,
        'sold': product.sold,
        'stock': product.stock,
        'isNew': product.isNew,
        'image': product.image,
        'sizes': product.sizes,
        'color': product.color.toARGB32(),
      }, SetOptions(merge: true));
    }

    await batch.commit();
  }

  // Menambahkan hanya produk yang belum ada di Firestore.
  Future<int> syncMissingProducts(List<Product> products) async {
    final collection = _db.collection('products');
    final batch = _db.batch();
    int added = 0;

    for (final product in products) {
      final docRef = collection.doc(product.id);
      final snapshot = await docRef.get();

      if (!snapshot.exists) {
        batch.set(docRef, {
          'name': product.name,
          'category': product.category.name,
          'price': product.price,
          'originalPrice': product.originalPrice,
          'sold': product.sold,
          'stock': product.stock,
          'isNew': product.isNew,
          'image': product.image,
          'sizes': product.sizes,
          'color': product.color.toARGB32(),
        });

        added++;
      }
    }

    if (added > 0) {
      await batch.commit();
    }

    return added;
  }

  // Mengambil daftar produk dari Firestore secara real-time.
  Stream<List<Product>> getProducts() {
    return _db.collection('products').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();

        return Product(
          id: doc.id,
          name: data['name'] as String,
          category: ProductCategory.values.firstWhere(
                (category) => category.name == data['category'],
            orElse: () => ProductCategory.kaos,
          ),
          price: (data['price'] as num).toInt(),
          originalPrice: (data['originalPrice'] as num?)?.toInt(),
          sold: (data['sold'] as num?)?.toInt() ?? 0,
          stock: (data['stock'] as num?)?.toInt() ?? 20,
          isNew: data['isNew'] as bool? ?? false,
          image: data['image'] as String? ?? '',
          sizes: List<String>.from(data['sizes'] ?? []),
          color: Color(
            (data['color'] as num?)?.toInt() ?? 0xFFE0E0E0,
          ),
        );
      }).toList();
    });
  }
}