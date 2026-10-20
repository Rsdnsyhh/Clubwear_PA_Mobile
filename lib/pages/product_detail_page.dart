import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/clubwear_provider.dart';
import '../widgets/common_widgets.dart';
import '../widgets/product_card.dart';
import '../widgets/size_picker_dialog.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key, required this.product});

  final Product product;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  String? _size;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    if (widget.product.sizes.length == 1) _size = widget.product.sizes.first;
  }

  void _addToCart() {
    final size = _size;
    if (size == null) return;

    final provider = context.read<ClubwearProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final product = widget.product;

    provider.addToCart(product, size, quantity: _quantity);

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 3),
          content: Text('$_quantity × ${product.name} (Ukuran $size) masuk keranjang'),
          action: SnackBarAction(
            label: 'LIHAT',
            textColor: Colors.white,
            onPressed: () {
              provider.setTab(2);
              navigator.pop();
            },
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final maxQty = context.read<ClubwearProvider>().maxQuantityFor(product);

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LayoutBuilder(
                        builder: (context, box) {
                          final height = math.min(box.maxWidth, 460.0);
                          return ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(28),
                            ),
                            child: SizedBox(
                              height: height,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  ProductImage(product: product),
                                  Positioned(
                                    top: 0,
                                    left: 0,
                                    right: 0,
                                    child: SafeArea(
                                      bottom: false,
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Row(
                                          children: [
                                            Material(
                                              color: Colors.white
                                                  .withValues(alpha: 0.92),
                                              shape: const CircleBorder(),
                                              child: InkWell(
                                                customBorder:
                                                    const CircleBorder(),
                                                onTap: () =>
                                                    Navigator.of(context).pop(),
                                                child: const SizedBox(
                                                  width: 40,
                                                  height: 40,
                                                  child: Icon(
                                                    Icons.arrow_back_rounded,
                                                    size: 22,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const Spacer(),
                                            FavoriteButton(
                                              productId: product.id,
                                              size: 40,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.category.label.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 11,
                                letterSpacing: 1.4,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              product.name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(Icons.star_rounded,
                                    size: 18, color: AppColors.star),
                                const SizedBox(width: 4),
                                Text(
                                  '${product.rating}  •  ${product.sold} terjual',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 10,
                              children: [
                                Text(
                                  formatRupiah(product.price),
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                if (product.hasDiscount) ...[
                                  Text(
                                    formatRupiah(product.originalPrice!),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textMuted,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.accent,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '-${product.discountPercent}%',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            if (product.isSoldOut || product.stock <= 5) ...[
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  const Icon(Icons.local_fire_department_outlined,
                                      size: 18, color: AppColors.accent),
                                  const SizedBox(width: 6),
                                  Text(
                                    product.isSoldOut
                                        ? 'Stok habis'
                                        : 'Stok tinggal ${product.stock}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.accent,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 22),
                            Container(height: 1, color: AppColors.border),
                            const SizedBox(height: 22),
                            Row(
                              children: [
                                const Text(
                                  'Pilih Ukuran',
                                  style: TextStyle(
                                      fontSize: 15, fontWeight: FontWeight.w600),
                                ),
                                const Spacer(),
                                if (_size != null)
                                  Text(
                                    'Terpilih: $_size',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                for (final size in product.sizes)
                                  SizeChip(
                                    label: size,
                                    selected: _size == size,
                                    onTap: () => setState(() => _size = size),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 26),
                            const Text(
                              'Deskripsi',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              product.description,
                              style: const TextStyle(
                                fontSize: 13.5,
                                height: 1.55,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            for (final detail in product.details)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(top: 2),
                                      child: Icon(Icons.check_circle_outline,
                                          size: 17, color: AppColors.primary),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        detail,
                                        style: const TextStyle(
                                            fontSize: 13.5, height: 1.4),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 10,
                      offset: Offset(0, -3),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      QuantityStepper(
                        quantity: _quantity,
                        maxQuantity: maxQty,
                        onDecrement: _quantity > 1
                            ? () => setState(() => _quantity--)
                            : null,
                        onIncrement: () => setState(() => _quantity++),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: PrimaryButton(
                          label: product.isSoldOut
                              ? 'Stok habis'
                              : _size == null
                                  ? 'Pilih ukuran dulu'
                                  : 'Tambah ke Keranjang',
                          icon: product.isSoldOut || _size == null
                              ? null
                              : Icons.shopping_bag_outlined,
                          onPressed: product.isSoldOut || _size == null
                              ? null
                              : _addToCart,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
