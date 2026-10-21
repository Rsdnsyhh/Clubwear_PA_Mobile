
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/cart_item.dart';
import '../models/product.dart';
import '../providers/clubwear_provider.dart';
import '../widgets/common_widgets.dart';
import '../widgets/product_card.dart';
import 'profile_page.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  // Memproses checkout dan menyimpan pesanan ke Firestore.
  Future<void> _checkout(
      BuildContext context,
      ClubwearProvider provider,
      ) async {
    if (!provider.hasAddress) {
      final fillNow = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          icon: const Icon(
            Icons.location_off_outlined,
            size: 32,
            color: AppColors.accent,
          ),
          title: const Text('Alamat belum diisi'),
          content: const Text(
            'Isi alamat pengiriman terlebih dahulu sebelum melakukan checkout.',
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Nanti'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Isi Alamat'),
            ),
          ],
        ),
      );

      if (fillNow == true && context.mounted) {
        await showAddressDialog(context);
      }
      return;
    }

    try {
      final order = await provider.placeOrder();

      if (!context.mounted || order == null) return;

      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => OrderDetailPage(
            order: order,
            justOrdered: true,
          ),
        ),
      );
    } catch (error, stackTrace) {
      debugPrint('ERROR CHECKOUT: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan pesanan: $error'),
          duration: const Duration(seconds: 8),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Consumer<ClubwearProvider>(
        builder: (context, provider, _) {
          final items = provider.cartItems;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageHeader(
                title: 'Keranjang',
                subtitle: items.isEmpty
                    ? 'Belum ada barang'
                    : '${provider.cartCount} barang siap di-checkout',
                icon: Icons.shopping_bag_rounded,
              ),
              Expanded(
                child: items.isEmpty
                    ? EmptyState(
                  icon: Icons.shopping_bag_outlined,
                  title: 'Keranjangmu masih kosong',
                  subtitle:
                  'Yuk, temukan outfit favoritmu di Clubwear.',
                  actionLabel: 'Mulai Belanja',
                  onAction: () => provider.setTab(0),
                )
                    : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    18,
                    16,
                    16,
                  ),
                  itemCount: items.length + 1,
                  separatorBuilder: (_, __) =>
                  const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    if (i == 0) {
                      return _ShippingProgress(
                        provider: provider,
                      );
                    }

                    final item = items[i - 1];

                    return Dismissible(
                      key: ValueKey(item.key),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) {
                        provider.removeFromCart(item.key);
                      },
                      background: const SizedBox.shrink(),
                      secondaryBackground: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 24),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.delete_outline,
                          color: Colors.white,
                        ),
                      ),
                      child: _CartItemTile(item: item),
                    );
                  },
                ),
              ),
              if (items.isNotEmpty)
                _SummaryBar(
                  provider: provider,
                  onCheckout: () => _checkout(context, provider),
                ),
            ],
          );
        },
      ),
    );
  }
}

// Widget progress gratis ongkir.
class _ShippingProgress extends StatelessWidget {
  const _ShippingProgress({required this.provider});

  final ClubwearProvider provider;

  @override
  Widget build(BuildContext context) {
    final remaining = provider.amountToFreeShipping;
    final unlocked = remaining == 0;
    final progress = math.min(
      1.0,
      provider.cartTotal / ClubwearProvider.freeShippingMin,
    );

    return AppCard(
      radius: 16,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                unlocked
                    ? Icons.local_shipping
                    : Icons.local_shipping_outlined,
                size: 20,
                color: unlocked ? AppColors.primary : AppColors.gold,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  unlocked
                      ? 'Selamat! Kamu dapat gratis ongkir.'
                      : 'Belanja ${formatRupiah(remaining)} lagi untuk gratis ongkir.',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.border,
              color: unlocked ? AppColors.primary : AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget satu produk di keranjang.
class _CartItemTile extends StatelessWidget {
  const _CartItemTile({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ClubwearProvider>();

    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: 88,
              height: 104,
              child: ProductImage(product: item.product),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => provider.removeFromCart(item.key),
                      borderRadius: BorderRadius.circular(20),
                      child: const Padding(
                        padding: EdgeInsets.all(2),
                        child: Icon(
                          Icons.delete_outline,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Ukuran: ${item.size}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  formatRupiah(item.product.price),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    QuantityStepper(
                      quantity: item.quantity,
                      maxQuantity: provider.maxQuantityFor(item.product),
                      onIncrement: () =>
                          provider.increaseQuantity(item.key),
                      onDecrement: () =>
                          provider.decreaseQuantity(item.key),
                    ),
                    const Spacer(),
                    if (item.quantity > 1)
                      Text(
                        formatRupiah(item.subtotal),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Widget ringkasan belanja dan tombol checkout.
class _SummaryBar extends StatelessWidget {
  const _SummaryBar({
    required this.provider,
    required this.onCheckout,
  });

  final ClubwearProvider provider;
  final VoidCallback onCheckout;

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasAddress = provider.hasAddress;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () => showAddressDialog(context),
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Icon(
                    hasAddress
                        ? Icons.location_on_outlined
                        : Icons.warning_amber_rounded,
                    size: 18,
                    color: hasAddress
                        ? AppColors.primary
                        : AppColors.accent,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      hasAddress
                          ? provider.address
                          : 'Alamat pengiriman belum diatur',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: hasAddress
                            ? AppColors.primary
                            : AppColors.accent,
                        fontWeight: hasAddress
                            ? FontWeight.w400
                            : FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    hasAddress ? 'Ubah' : 'Atur',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          _row(
            'Subtotal (${provider.cartCount} barang)',
            formatRupiah(provider.cartTotal),
          ),
          _row(
            'Ongkos kirim',
            provider.shipping == 0
                ? 'Gratis'
                : formatRupiah(provider.shipping),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    formatRupiah(provider.grandTotal),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: PrimaryButton(
                  gold: true,
                  label: 'Checkout',
                  icon: Icons.shopping_bag_outlined,
                  onPressed: onCheckout,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
