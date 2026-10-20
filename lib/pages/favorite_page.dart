import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/clubwear_provider.dart';
import '../widgets/common_widgets.dart';
import '../widgets/product_card.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = context.watch<ClubwearProvider>().favoriteProducts;

    return SafeArea(
      top: false,
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'Favorit',
            subtitle: items.isEmpty
                ? 'Simpan produk incaranmu di sini'
                : '${items.length} produk tersimpan',
            icon: Icons.favorite_rounded,
          ),
          Expanded(
            child: items.isEmpty
                ? const EmptyState(
              icon: Icons.favorite_border,
              title: 'Belum ada favorit',
              subtitle:
              'Ketuk ikon hati pada produk untuk menyimpannya di sini.',
            )
                : CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                  sliver: SliverGrid(
                    gridDelegate:
                    const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 220,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.6,
                    ),
                    delegate: SliverChildBuilderDelegate(
                          (context, index) =>
                          ProductCard(product: items[index]),
                      childCount: items.length,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}