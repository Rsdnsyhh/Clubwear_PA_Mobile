import 'product.dart';

class CartItem {
  CartItem({required this.product, required this.size, this.quantity = 1});

  final Product product;
  final String size;
  int quantity;

  /// Produk yang sama dengan ukuran berbeda dihitung sebagai item berbeda.
  String get key => keyOf(product, size);

  int get subtotal => product.price * quantity;

  static String keyOf(Product product, String size) => '${product.id}_$size';
}
