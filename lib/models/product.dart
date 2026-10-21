import 'package:flutter/material.dart';

enum ProductCategory {
  kaos('Kaos', Icons.checkroom),
  kemeja('Kemeja', Icons.checkroom),
  celana('Celana', Icons.checkroom),
  jaket('Jaket', Icons.checkroom),
  sweater('Sweater', Icons.checkroom),
  sepatu('Sepatu', Icons.hiking),
  aksesoris('Aksesoris', Icons.watch_outlined);

  const ProductCategory(this.label, this.icon);
  final String label;
  final IconData icon;
}

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.sizes,
    required this.color,
    this.sold = 0,
    this.originalPrice,
    this.stock = 20,
    this.isNew = false,
    this.image = '',
  });

  final String id;
  final String name;
  final ProductCategory category;
  final int price;
  final int? originalPrice;
  final int sold;
  final int stock;
  final bool isNew;
  final String image;
  final List<String> sizes;
  final Color color;

  bool get hasDiscount => originalPrice != null && originalPrice! > price;
  int get discountPercent => hasDiscount
      ? (((originalPrice! - price) / originalPrice!) * 100).round()
      : 0;
  bool get isSoldOut => stock <= 0;

  String get description => switch (category) {
    ProductCategory.kaos =>
    'Kaos dengan bahan lembut dan potongan boxy yang nyaman dipakai '
        'seharian. Mudah dipadukan dengan celana atau jaket apa saja.',
    ProductCategory.kemeja =>
    'Kemeja dengan jahitan rapi dan kerah yang jatuh sempurna. Cocok '
        'untuk tampilan santai maupun semi-formal.',
    ProductCategory.celana =>
    'Celana dengan potongan modern dan bahan yang kuat namun tetap '
        'nyaman untuk bergerak sepanjang hari.',
    ProductCategory.jaket =>
    'Jaket ringan sebagai pelapis outfit favoritmu. Detail jahitan kuat '
        'dan siap menemani aktivitas harianmu.',
    ProductCategory.sweater =>
    'Sweater hangat dengan tekstur halus di kulit. Pilihan tepat untuk '
        'gaya kasual yang tetap rapi.',
    ProductCategory.sepatu =>
    'Sepatu dengan sol empuk dan desain bersih yang serasi dengan '
        'berbagai gaya, dari kampus sampai akhir pekan.',
    ProductCategory.aksesoris =>
    'Aksesoris pelengkap untuk menyempurnakan tampilanmu. Desain '
        'simpel, mudah dipadukan, dan tahan lama.',
  };

  List<String> get details => switch (category) {
    ProductCategory.kaos => [
      'Bahan katun combed, adem dan menyerap keringat',
      'Model boxy / oversized fit',
      'Sablon tahan cuci',
    ],
    ProductCategory.kemeja => [
      'Bahan katun berkualitas, tidak mudah kusut',
      'Regular fit dengan kancing penuh',
      'Cocok untuk kasual dan semi-formal',
    ],
    ProductCategory.celana => [
      'Bahan twill tebal dan kuat',
      'Pinggang nyaman dengan saku fungsional',
      'Potongan modern',
    ],
    ProductCategory.jaket => [
      'Lapisan ringan, tidak gerah',
      'Resleting kuat dan saku dalam',
      'Cocok untuk aktivitas harian',
    ],
    ProductCategory.sweater => [
      'Bahan fleece / knit lembut',
      'Ribbing elastis di leher dan lengan',
      'Hangat tanpa terasa berat',
    ],
    ProductCategory.sepatu => [
      'Sol karet anti-selip',
      'Bantalan empuk di bagian dalam',
      'Upper kuat dan mudah dibersihkan',
    ],
    ProductCategory.aksesoris => [
      'Material berkualitas dan awet',
      'Ukuran All Size / adjustable',
      'Desain simpel, mudah dipadukan',
    ],
  };
}

String formatRupiah(int value) {
  final digits = value.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
    buffer.write(digits[i]);
  }
  final sign = value < 0 ? '-' : '';
  return '${sign}Rp$buffer';
}