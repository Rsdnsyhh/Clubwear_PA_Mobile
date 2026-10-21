
import 'dart:async';
import '../services/order_firestore_service.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/cart_item.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../services/cart_firestore_service.dart';
import '../services/product_firestore_service.dart';

const _clothing = ['S', 'M', 'L', 'XL', 'XXL'];
const _pants = ['28', '30', '32', '34', '36'];
const _shoes = ['39', '40', '41', '42', '43', '44'];
const _oneSize = ['All Size'];

class AppUser {
  const AppUser({required this.name, required this.email});

  final String name;
  final String email;

  String get initial => name.isEmpty ? '?' : name[0].toUpperCase();
}

class _Account {
  _Account(this.name, this.email, this.password);

  final String name;
  final String email;
  final String password;
}

class ClubwearProvider extends ChangeNotifier {
  final OrderFirestoreService _orderService = OrderFirestoreService();
  ClubwearProvider() {
    _authSubscription =
        FirebaseAuth.instance.authStateChanges().listen(_handleAuthChange);
  }

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<List<Product>>? _productSubscription;
  StreamSubscription<List<CartItem>>? _cartSubscription;

  final CartFirestoreService _cartService = CartFirestoreService();

  // ===================== AUTENTIKASI =====================

  void _handleAuthChange(User? firebaseUser) async {
    _productSubscription?.cancel();
    _cartSubscription?.cancel();

    if (firebaseUser == null) {
      _user = null;
      _cart.clear();
      products = List<Product>.from(seedProducts);
      notifyListeners();
      return;
    }

    final email = firebaseUser.email ?? '';
    final displayName = firebaseUser.displayName?.trim();

    _user = AppUser(
      name: displayName != null && displayName.isNotEmpty
          ? displayName
          : email.split('@').first,
      email: email,
    );

    try {
      final added = await ProductFirestoreService()
          .syncMissingProducts(seedProducts);

      debugPrint('Produk baru ditambahkan: $added');
    } catch (e) {
      debugPrint('Gagal sinkronisasi produk: $e');
    }

    _productSubscription =
        ProductFirestoreService().getProducts().listen(
              (loadedProducts) {
            if (loadedProducts.isNotEmpty) {
              products = loadedProducts;

              _cartSubscription?.cancel();
              _cartSubscription = _cartService.watchCart(products).listen(
                    (loadedItems) {
                  _cart
                    ..clear()
                    ..addEntries(
                      loadedItems.map(
                            (item) => MapEntry(item.key, item),
                      ),
                    );

                  notifyListeners();
                },
                onError: (Object error) {
                  debugPrint('Gagal memuat keranjang: $error');
                },
              );
            }

            notifyListeners();
          },
          onError: (Object error) {
            debugPrint('Gagal memuat produk Firestore: $error');
          },
        );

    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _productSubscription?.cancel();
    _cartSubscription?.cancel();
    super.dispose();
  }

  // ===================== KONFIGURASI =====================

  static const int maxQuantity = 10;
  static const int freeShippingMin = 500000;
  static const int shippingFee = 20000;

  // ===================== NAVIGASI =====================

  int _tabIndex = 0;

  int get tabIndex => _tabIndex;

  void setTab(int index) {
    if (index == _tabIndex) return;

    _tabIndex = index;
    notifyListeners();
  }

  // ===================== AKUN DEMO =====================

  final List<_Account> _accounts = [];
  AppUser? _user;

  AppUser? get user => _user;

  String? register({
    required String name,
    required String email,
    required String password,
  }) {
    final normalized = email.trim().toLowerCase();

    if (_accounts.any((a) => a.email == normalized)) {
      return 'Email sudah terdaftar. Silakan masuk.';
    }

    _accounts.add(_Account(name.trim(), normalized, password));
    return null;
  }

  String? login(String email, String password) {
    final normalized = email.trim().toLowerCase();

    _Account? found;

    for (final account in _accounts) {
      if (account.email == normalized) {
        found = account;
      }
    }

    if (found != null && found.password != password) {
      return 'Password salah.';
    }

    final name = found?.name ?? normalized.split('@').first;

    _user = AppUser(name: name, email: normalized);
    notifyListeners();

    return null;
  }

  String? updateProfile({
    required String name,
    required String email,
  }) {
    final current = _user;

    if (current == null) return 'Kamu belum masuk.';

    final newName = name.trim();
    final newEmail = email.trim().toLowerCase();

    final usedByOther = _accounts.any(
          (a) => a.email == newEmail && a.email != current.email,
    );

    if (usedByOther) {
      return 'Email sudah dipakai akun lain.';
    }

    final index =
    _accounts.indexWhere((a) => a.email == current.email);

    if (index != -1) {
      _accounts[index] = _Account(
        newName,
        newEmail,
        _accounts[index].password,
      );
    }

    _user = AppUser(name: newName, email: newEmail);
    notifyListeners();

    return null;
  }

  // Logout Firebase tidak menghapus keranjang di Firestore.
  Future<void> logout() async {
    if (FirebaseAuth.instance.currentUser != null) {
      await FirebaseAuth.instance.signOut();
    } else {
      _user = null;
      _cart.clear();
      notifyListeners();
    }

    _favoriteIds.clear();
    _orders.clear();
    _orderSeq = 0;
    _address = '';
    _tabIndex = 0;

    notifyListeners();
  }

  // ===================== PRODUK =====================

  static const List<Product> seedProducts = [
    // ---------- KAOS ----------
    Product(
      id: 'p01',
      name: 'Heat-Reactive Print T-Shirt',
      category: ProductCategory.kaos,
      price: 435000,
      rating: 4.4,
      sold: 248,
      stock: 0,
      isNew: true,
      sizes: _clothing,
      color: Color(0xFFEDEBE6),
      image: 'assets/images/kaos/p01.jpg',
    ),
    Product(
      id: 'p02',
      name: 'T-Shirt With Sunlight-Reactive Slogan',
      category: ProductCategory.kaos,
      price: 435000,
      originalPrice: 544000,
      rating: 4.3,
      sold: 452,
      sizes: _clothing,
      color: Color(0xFFDDEEE8),
      image: 'assets/images/kaos/p02.jpg',
    ),
    Product(
      id: 'p03',
      name: 'Contrast Printed T-Shirt',
      category: ProductCategory.kaos,
      price: 435000,
      rating: 4.8,
      sold: 26,
      stock: 3,
      sizes: _clothing,
      color: Color(0xFFF1ECDD),
      image: 'assets/images/kaos/p03.jpg',
    ),
    Product(
      id: 'p04',
      name: 'Faded Printed T-Shirt',
      category: ProductCategory.kaos,
      price: 435000,
      originalPrice: 544000,
      rating: 4.7,
      sold: 846,
      sizes: _clothing,
      color: Color(0xFFD9D2CC),
      image: 'assets/images/kaos/p04.jpg',
    ),
    Product(
      id: 'p05',
      name: 'Tie-Dye Printed T-Shirt',
      category: ProductCategory.kaos,
      price: 435000,
      rating: 4.8,
      sold: 66,
      sizes: _clothing,
      color: Color(0xFFE5DCE6),
      image: 'assets/images/kaos/p05.jpg',
    ),

    // ---------- KEMEJA ----------
    Product(
      id: 'p06',
      name: 'Oxford Cotton Shirt',
      category: ProductCategory.kemeja,
      price: 489000,
      originalPrice: 612000,
      rating: 4.6,
      sold: 512,
      sizes: _clothing,
      color: Color(0xFFDDE6F0),
      image: 'assets/images/kemeja/p06.jpg',
    ),
    Product(
      id: 'p07',
      name: 'Linen Blend Overshirt',
      category: ProductCategory.kemeja,
      price: 559000,
      rating: 4.4,
      sold: 143,
      stock: 5,
      isNew: true,
      sizes: _clothing,
      color: Color(0xFFE8E1D2),
      image: 'assets/images/kemeja/p07.jpg',
    ),
    Product(
      id: 'p08',
      name: 'Striped Short Sleeve Shirt',
      category: ProductCategory.kemeja,
      price: 429000,
      rating: 4.5,
      sold: 231,
      sizes: _clothing,
      color: Color(0xFFE2E8E4),
      image: 'assets/images/kemeja/p08.jpg',
    ),
    Product(
      id: 'p09',
      name: 'Relaxed Poplin Shirt',
      category: ProductCategory.kemeja,
      price: 459000,
      originalPrice: 574000,
      rating: 4.3,
      sold: 184,
      sizes: _clothing,
      color: Color(0xFFEFEDE8),
      image: 'assets/images/kemeja/p09.jpg',
    ),
    Product(
      id: 'p10',
      name: 'Flannel Check Shirt',
      category: ProductCategory.kemeja,
      price: 519000,
      rating: 4.7,
      sold: 97,
      isNew: true,
      sizes: _clothing,
      color: Color(0xFFE6D5CF),
      image: 'assets/images/kemeja/p10.jpg',
    ),

    // ---------- CELANA ----------
    Product(
      id: 'p11',
      name: 'Wide-Leg Cargo Trousers',
      category: ProductCategory.celana,
      price: 629000,
      originalPrice: 786000,
      rating: 4.7,
      sold: 698,
      sizes: _pants,
      color: Color(0xFFD8D3C4),
      image: 'assets/images/celana/p11.jpg',
    ),
    Product(
      id: 'p12',
      name: 'Relaxed Fit Chino Pants',
      category: ProductCategory.celana,
      price: 519000,
      rating: 4.5,
      sold: 377,
      sizes: _pants,
      color: Color(0xFFE3D9C8),
      image: 'assets/images/celana/p12.jpg',
    ),
    Product(
      id: 'p13',
      name: 'Straight Fit Jeans',
      category: ProductCategory.celana,
      price: 599000,
      rating: 4.6,
      sold: 455,
      sizes: _pants,
      color: Color(0xFFCBD7E4),
      image: 'assets/images/celana/p13.jpg',
    ),
    Product(
      id: 'p14',
      name: 'Jogger Sweatpants',
      category: ProductCategory.celana,
      price: 399000,
      originalPrice: 499000,
      rating: 4.4,
      sold: 612,
      sizes: _pants,
      color: Color(0xFFDADADA),
      image: 'assets/images/celana/p14.jpg',
    ),
    Product(
      id: 'p15',
      name: 'Pleated Baggy Trousers',
      category: ProductCategory.celana,
      price: 579000,
      rating: 4.5,
      sold: 128,
      isNew: true,
      sizes: _pants,
      color: Color(0xFFE0DCD3),
      image: 'assets/images/celana/p15.jpg',
    ),

    // ---------- JAKET ----------
    Product(
      id: 'p16',
      name: 'Washed Denim Trucker Jacket',
      category: ProductCategory.jaket,
      price: 799000,
      originalPrice: 999000,
      rating: 4.8,
      sold: 421,
      sizes: _clothing,
      color: Color(0xFFC9D6E3),
      image: 'assets/images/jaket/p16.jpg',
    ),
    Product(
      id: 'p17',
      name: 'Lightweight Bomber Jacket',
      category: ProductCategory.jaket,
      price: 859000,
      rating: 4.6,
      sold: 205,
      isNew: true,
      sizes: _clothing,
      color: Color(0xFFD2D8CF),
      image: 'assets/images/jaket/p17.jpg',
    ),
    Product(
      id: 'p18',
      name: 'Zip Hoodie Jacket',
      category: ProductCategory.jaket,
      price: 649000,
      rating: 4.5,
      sold: 538,
      sizes: _clothing,
      color: Color(0xFFDCDCDC),
      image: 'assets/images/jaket/p18.jpg',
    ),
    Product(
      id: 'p19',
      name: 'Coach Windbreaker',
      category: ProductCategory.jaket,
      price: 689000,
      originalPrice: 861000,
      rating: 4.4,
      sold: 266,
      sizes: _clothing,
      color: Color(0xFFD5DDD8),
      image: 'assets/images/jaket/p19.jpg',
    ),
    Product(
      id: 'p20',
      name: 'Varsity Jacket',
      category: ProductCategory.jaket,
      price: 949000,
      rating: 4.7,
      sold: 74,
      isNew: true,
      sizes: _clothing,
      color: Color(0xFFE4D3D0),
      image: 'assets/images/jaket/p20.jpg',
    ),

    // ---------- SWEATER ----------
    Product(
      id: 'p21',
      name: 'Sweatshirt With Printed Slogans',
      category: ProductCategory.sweater,
      price: 568000,
      originalPrice: 710000,
      rating: 4.6,
      sold: 753,
      sizes: _clothing,
      color: Color(0xFFCFE8DC),
      image: 'assets/images/sweater/p21.jpg',
    ),
    Product(
      id: 'p22',
      name: 'Sweatshirt With Embroidery And Slogans',
      category: ProductCategory.sweater,
      price: 568000,
      originalPrice: 710000,
      rating: 4.3,
      sold: 801,
      sizes: _clothing,
      color: Color(0xFFE6E8EE),
      image: 'assets/images/sweater/p22.jpg',
    ),
    Product(
      id: 'p23',
      name: 'Ribbed Knit Sweater',
      category: ProductCategory.sweater,
      price: 529000,
      rating: 4.5,
      sold: 289,
      sizes: _clothing,
      color: Color(0xFFEADFD3),
      image: 'assets/images/sweater/p23.jpg',
    ),
    Product(
      id: 'p24',
      name: 'Oversized Crewneck Sweatshirt',
      category: ProductCategory.sweater,
      price: 459000,
      rating: 4.6,
      sold: 390,
      sizes: _clothing,
      color: Color(0xFFE3E1DC),
      image: 'assets/images/sweater/p24.jpg',
    ),
    Product(
      id: 'p25',
      name: 'Textured Knit Cardigan',
      category: ProductCategory.sweater,
      price: 599000,
      originalPrice: 749000,
      rating: 4.4,
      sold: 118,
      sizes: _clothing,
      color: Color(0xFFE8DDD0),
      image: 'assets/images/sweater/p25.jpg',
    ),

    // ---------- SEPATU ----------
    Product(
      id: 'p26',
      name: 'Chunky Leather Sneakers',
      category: ProductCategory.sepatu,
      price: 899000,
      originalPrice: 1124000,
      rating: 4.7,
      sold: 634,
      sizes: _shoes,
      color: Color(0xFFE9E7E2),
      image: 'assets/images/sepatu/p26.jpg',
    ),
    Product(
      id: 'p27',
      name: 'Canvas Low-Top Sneakers',
      category: ProductCategory.sepatu,
      price: 459000,
      rating: 4.4,
      sold: 912,
      sizes: _shoes,
      color: Color(0xFFDEDCD6),
      image: 'assets/images/sepatu/p27.jpg',
    ),
    Product(
      id: 'p28',
      name: 'Retro Running Shoes',
      category: ProductCategory.sepatu,
      price: 779000,
      rating: 4.6,
      sold: 347,
      isNew: true,
      sizes: _shoes,
      color: Color(0xFFDCE3E8),
      image: 'assets/images/sepatu/p28.jpg',
    ),
    Product(
      id: 'p29',
      name: 'Suede Derby Shoes',
      category: ProductCategory.sepatu,
      price: 849000,
      rating: 4.5,
      sold: 112,
      sizes: _shoes,
      color: Color(0xFFE2D5C6),
      image: 'assets/images/sepatu/p29.jpg',
    ),
    Product(
      id: 'p30',
      name: 'Slip-On Loafers',
      category: ProductCategory.sepatu,
      price: 629000,
      originalPrice: 786000,
      rating: 4.3,
      sold: 205,
      sizes: _shoes,
      color: Color(0xFFD9D0C7),
      image: 'assets/images/sepatu/p30.jpg',
    ),

    // ---------- AKSESORIS ----------
    Product(
      id: 'p31',
      name: 'Woven Leather Belt',
      category: ProductCategory.aksesoris,
      price: 199000,
      rating: 4.3,
      sold: 158,
      sizes: _oneSize,
      color: Color(0xFFE5D8C9),
      image: 'assets/images/aksesoris/p31.jpg',
    ),
    Product(
      id: 'p32',
      name: 'Classic Baseball Cap',
      category: ProductCategory.aksesoris,
      price: 229000,
      originalPrice: 286000,
      rating: 4.6,
      sold: 540,
      sizes: _oneSize,
      color: Color(0xFFD7DDE0),
      image: 'assets/images/aksesoris/p32.jpg',
    ),
    Product(
      id: 'p33',
      name: 'Crossbody Utility Bag',
      category: ProductCategory.aksesoris,
      price: 379000,
      rating: 4.5,
      sold: 97,
      isNew: true,
      sizes: _oneSize,
      color: Color(0xFFD9D6CF),
      image: 'assets/images/aksesoris/p33.jpg',
    ),
    Product(
      id: 'p34',
      name: 'Minimal Quartz Watch',
      category: ProductCategory.aksesoris,
      price: 449000,
      rating: 4.7,
      sold: 276,
      sizes: _oneSize,
      color: Color(0xFFDFDFDF),
      image: 'assets/images/aksesoris/p34.jpg',
    ),
    Product(
      id: 'p35',
      name: 'Cotton Tote Bag',
      category: ProductCategory.aksesoris,
      price: 149000,
      rating: 4.2,
      sold: 331,
      sizes: _oneSize,
      color: Color(0xFFEFEADF),
      image: 'assets/images/aksesoris/p35.jpg',
    ),
  ];

  List<Product> products = List<Product>.from(seedProducts);

  // ===================== FAVORIT =====================

  final Set<String> _favoriteIds = {};

  int get favoriteCount => _favoriteIds.length;

  bool isFavorite(String productId) =>
      _favoriteIds.contains(productId);

  List<Product> get favoriteProducts =>
      products.where((p) => _favoriteIds.contains(p.id)).toList();

  void toggleFavorite(String productId) {
    if (!_favoriteIds.remove(productId)) {
      _favoriteIds.add(productId);
    }

    notifyListeners();
  }

  // ===================== KERANJANG =====================

  final Map<String, CartItem> _cart = {};

  List<CartItem> get cartItems => _cart.values.toList();

  bool get isCartEmpty => _cart.isEmpty;

  int get cartCount =>
      _cart.values.fold(0, (sum, item) => sum + item.quantity);

  int get cartTotal =>
      _cart.values.fold(0, (sum, item) => sum + item.subtotal);

  int get shipping =>
      _cart.isEmpty || cartTotal >= freeShippingMin ? 0 : shippingFee;

  int get grandTotal => cartTotal + shipping;

  int get amountToFreeShipping =>
      cartTotal >= freeShippingMin ? 0 : freeShippingMin - cartTotal;

  int maxQuantityFor(Product product) =>
      product.stock < maxQuantity ? product.stock : maxQuantity;

  // Simpan item ke Firestore milik pengguna yang sedang login.
  void _saveCartItem(CartItem item) {
    if (FirebaseAuth.instance.currentUser == null) return;

    _cartService.saveItem(item).catchError((Object error) {
      debugPrint('Gagal menyimpan item keranjang: $error');
    });
  }

  // Hapus item dari Firestore milik pengguna yang sedang login.
  void _deleteCartItem(String key) {
    if (FirebaseAuth.instance.currentUser == null) return;

    _cartService.removeItem(key).catchError((Object error) {
      debugPrint('Gagal menghapus item keranjang: $error');
    });
  }

  void addToCart(Product product, String size, {int quantity = 1}) {
    final limit = maxQuantityFor(product);

    if (limit <= 0 || quantity <= 0) return;

    final key = CartItem.keyOf(product, size);
    final existing = _cart[key];

    if (existing != null) {
      final next = existing.quantity + quantity;
      existing.quantity = next > limit ? limit : next;
      _saveCartItem(existing);
    } else {
      final item = CartItem(
        product: product,
        size: size,
        quantity: quantity > limit ? limit : quantity,
      );

      _cart[key] = item;
      _saveCartItem(item);
    }

    notifyListeners();
  }

  void increaseQuantity(String key) {
    final item = _cart[key];

    if (item == null ||
        item.quantity >= maxQuantityFor(item.product)) {
      return;
    }

    item.quantity++;
    _saveCartItem(item);
    notifyListeners();
  }

  void decreaseQuantity(String key) {
    final item = _cart[key];
    if (item == null) return;

    if (item.quantity <= 1) {
      _cart.remove(key);
      _deleteCartItem(key);
    } else {
      item.quantity--;
      _saveCartItem(item);
    }

    notifyListeners();
  }

  void removeFromCart(String key) {
    if (_cart.remove(key) != null) {
      _deleteCartItem(key);
      notifyListeners();
    }
  }

  void clearCart() {
    _cart.clear();

    if (FirebaseAuth.instance.currentUser != null) {
      _cartService.clearCart().catchError((Object error) {
        debugPrint('Gagal mengosongkan keranjang: $error');
      });
    }

    notifyListeners();
  }

  // ===================== ALAMAT & PESANAN =====================

  String _address = '';
  final List<Order> _orders = [];
  int _orderSeq = 0;

  String get address => _address;

  bool get hasAddress => _address.trim().isNotEmpty;

  List<Order> get orders => List.unmodifiable(_orders);

  void setAddress(String value) {
    _address = value.trim();
    notifyListeners();
  }


  Future<Order?> placeOrder() async {
    if (_cart.isEmpty || !hasAddress) return null;

    if (FirebaseAuth.instance.currentUser == null) {
      debugPrint('Checkout gagal: pengguna belum login.');
      return null;
    }

    final lines = [
      for (final item in _cart.values)
        OrderLine(
          name: item.product.name,
          category: item.product.category.label,
          size: item.size,
          quantity: item.quantity,
          price: item.product.price,
        ),
    ];

    final order = Order(
      id: buildOrderCode(_orderSeq + 1, lines),
      date: DateTime.now(),
      lines: lines,
      subtotal: cartTotal,
      shipping: shipping,
      address: _address,
    );

    try {
      await _orderService.saveOrder(order);
      await _cartService.clearCart();

      _orderSeq++;
      _orders.insert(0, order);
      _cart.clear();

      notifyListeners();
      return order;
    } catch (error) {
      debugPrint('Gagal menyimpan pesanan: $error');
      rethrow;
    }
  }

  // Mengunggah daftar produk lokal ke Firestore.
  Future<void> uploadProductsToFirebase() async {
    await ProductFirestoreService().uploadProducts(products);
  }
}
