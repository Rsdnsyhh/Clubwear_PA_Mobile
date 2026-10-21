import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/clubwear_provider.dart';
import '../pages/product_detail_page.dart';
import 'common_widgets.dart';
import 'size_picker_dialog.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
      builder: (_, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 14 * (1 - value)),
          child: child,
        ),
      ),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => ProductDetailPage(product: product),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ProductImage(product: product),
                      if (product.isSoldOut)
                        Container(color: Colors.white.withValues(alpha: 0.55)),
                      Positioned(
                          top: 10, left: 10, child: _Badge(product: product)),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: FavoriteButton(productId: product.id),
                      ),
                      Positioned(
                        right: 8,
                        bottom: 8,
                        child: _AddButton(product: product),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 34,
                        child: Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12.5, height: 1.3),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatRupiah(product.price),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(
                        height: 15,
                        child: product.hasDiscount
                            ? Text(
                                formatRupiah(product.originalPrice!),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 14, color: AppColors.star),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              'Terjual ${product.sold}  •  Stok ${product.stock}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Menampilkan gambar produk (asset / network). Jika gambar belum ada atau
/// gagal dimuat, tampil placeholder berwarna sehingga UI tetap rapi.
class ProductImage extends StatelessWidget {
  const ProductImage({super.key, required this.product, this.fit = BoxFit.cover});

  final Product product;
  final BoxFit fit;

  Widget _fallback() {
    return Container(
      color: product.color,
      alignment: Alignment.center,
      child: Icon(
        product.category.icon,
        size: 44,
        color: Colors.black.withValues(alpha: 0.22),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (product.image.isEmpty) return _fallback();

    if (product.image.startsWith('http')) {
      return Image.network(
        product.image,
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    }
    return Image.asset(
      product.image,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, __, ___) => _fallback(),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    String? text;
    Color color = AppColors.primary;

    if (product.isSoldOut) {
      text = 'HABIS';
      color = AppColors.textSecondary;
    } else if (product.hasDiscount) {
      text = '-${product.discountPercent}%';
      color = AppColors.accent;
    } else if (product.isNew) {
      text = 'BARU';
    }

    if (text == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class FavoriteButton extends StatelessWidget {
  const FavoriteButton({super.key, required this.productId, this.size = 32});

  final String productId;
  final double size;

  @override
  Widget build(BuildContext context) {
    final isFavorite = context
        .select<ClubwearProvider, bool>((p) => p.isFavorite(productId));

    return Material(
      color: Colors.white.withValues(alpha: 0.92),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () {
          final provider = context.read<ClubwearProvider>();
          final wasFavorite = provider.isFavorite(productId);
          provider.toggleFavorite(productId);
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                duration: const Duration(milliseconds: 1200),
                content: Text(wasFavorite
                    ? 'Dihapus dari favorit'
                    : 'Ditambahkan ke favorit'),
              ),
            );
        },
        child: SizedBox(
          width: size,
          height: size,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              key: ValueKey(isFavorite),
              size: size * 0.56,
              color: isFavorite ? AppColors.accent : AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final soldOut = product.isSoldOut;

    return Material(
      color: soldOut ? AppColors.disabled : AppColors.primary,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: soldOut ? null : () => showSizePickerDialog(context, product),
        child: const SizedBox(
          width: 34,
          height: 34,
          child: Icon(Icons.add, size: 20, color: Colors.white),
        ),
      ),
    );
  }
}
