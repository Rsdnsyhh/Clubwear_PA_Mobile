import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product.dart';

class ProductFirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> uploadProducts(List<Product> products) async {
    final batch = _db.batch();
    for (final product in products) {
      final docRef = _db.collection('products').doc(product.id);
      batch.set(docRef, {
        'name': product.name,
        'category': product.category.name,
        'price': product.price,
        'originalPrice': product.originalPrice,
        'sold': 0, // mulai dari 0 (real-time nanti)
        'stock': product.stock,
        'isNew': product.isNew,
        'image': product.image,
        'sizes': product.sizes,
        'color': product.color.toARGB32(),
      }, SetOptions(merge: true));
    }
    await batch.commit();
  }

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
          color: Color((data['color'] as num?)?.toInt() ?? 0xFFE0E0E0),
        );
      }).toList();
    });
  }

  /// Tambah produk baru — sold otomatis 0.
  Future<String> addProduct({
    required String name,
    required ProductCategory category,
    required int price,
    int? originalPrice,
    required int stock,
    required List<String> sizes,
    String image = '',
    bool isNew = false,
  }) async {
    final docRef = _db.collection('products').doc();
    await docRef.set({
      'name': name,
      'category': category.name,
      'price': price,
      'originalPrice': originalPrice,
      'sold': 0,
      'stock': stock,
      'isNew': isNew,
      'image': image,
      'sizes': sizes,
      'color': 0xFFE0E0E0,
    });
    return docRef.id;
  }

  Future<void> updateProduct(Product product) async {
    await _db.collection('products').doc(product.id).update({
      'name': product.name,
      'category': product.category.name,
      'price': product.price,
      'originalPrice': product.originalPrice,
      'stock': product.stock,
      'isNew': product.isNew,
      'image': product.image,
      'sizes': product.sizes,
      'color': product.color.toARGB32(),
    });
  }

  Future<void> deleteProduct(String productId) async {
    await _db.collection('products').doc(productId).delete();
  }

  /// Dipanggil saat checkout: tambah `sold`, kurangi `stock`.
  Future<void> incrementSoldAndDecreaseStock(
      String productId,
      int quantity,
      ) async {
    await _db.collection('products').doc(productId).update({
      'sold': FieldValue.increment(quantity),
      'stock': FieldValue.increment(-quantity),
    });
  }
}