import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/clubwear_provider.dart';
import '../widgets/common_widgets.dart';
import '../widgets/product_card.dart';

enum SortOption {
  rekomendasi('Rekomendasi'),
  termurah('Harga terendah'),
  termahal('Harga tertinggi'),
  terlaris('Terlaris'),
  rating('Rating tertinggi');

  const SortOption(this.label);

  final String label;
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // State lokal halaman ini -> cukup setState.
  final _searchController = TextEditingController();
  String _query = '';
  ProductCategory? _category;
  SortOption _sort = SortOption.rekomendasi;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Product> _filter(List<Product> all) {
    final q = _query.trim().toLowerCase();
    return all.where((p) {
      final matchCategory = _category == null || p.category == _category;
      final matchQuery = q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.category.label.toLowerCase().contains(q);
      return matchCategory && matchQuery;
    }).toList();
  }

  List<Product> _sorted(List<Product> list) {
    switch (_sort) {
      case SortOption.rekomendasi:
        break;
      case SortOption.termurah:
        list.sort((a, b) => a.price.compareTo(b.price));
      case SortOption.termahal:
        list.sort((a, b) => b.price.compareTo(a.price));
      case SortOption.terlaris:
        list.sort((a, b) => b.sold.compareTo(a.sold));
      case SortOption.rating:
        list.sort((a, b) => b.rating.compareTo(a.rating));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final products =
    _sorted(_filter(context.read<ClubwearProvider>().products));

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _HomeHeader(
            controller: _searchController,
            hasText: _query.isNotEmpty,
            onChanged: (value) => setState(() => _query = value),
            onClear: () {
              _searchController.clear();
              setState(() => _query = '');
            },
          ),
        ),
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 0),
            child: _PromoCarousel(),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: _CategoryChips(
              selected: _category,
              onSelected: (value) => setState(() => _category = value),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 14),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.gold,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Rekomendasi untukmu',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${products.length} produk',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<SortOption>(
                  onSelected: (value) => setState(() => _sort = value),
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  itemBuilder: (_) => [
                    for (final option in SortOption.values)
                      CheckedPopupMenuItem<SortOption>(
                        value: option,
                        checked: option == _sort,
                        child: Text(option.label),
                      ),
                  ],
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.swap_vert_rounded,
                            size: 18, color: AppColors.gold),
                        const SizedBox(width: 6),
                        Text(
                          _sort.label,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
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
        if (products.isEmpty)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: EmptyState(
                icon: Icons.search_off_rounded,
                title: 'Produk tidak ditemukan',
                subtitle: 'Coba kata kunci atau kategori lain.',
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverGrid(
              // 2 kolom di HP, otomatis bertambah di layar lebar.
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.6,
              ),
              delegate: SliverChildBuilderDelegate(
                    (context, index) => ProductCard(product: products[index]),
                childCount: products.length,
              ),
            ),
          ),
      ],
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.controller,
    required this.hasText,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final bool hasText;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClubwearProvider>();
    final top = MediaQuery.of(context).padding.top;
    final cartCount = provider.cartCount;
    final name = provider.user?.name ?? 'Tamu';

    return Container(
      padding: EdgeInsets.fromLTRB(20, top + 18, 20, 24),
      decoration: const BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CLUBWEAR',
                      style: TextStyle(
                        color: AppColors.gold,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 3.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Halo, $name',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Temukan gaya terbaikmu hari ini',
                      style: TextStyle(
                        color: AppColors.goldLight,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              Material(
                color: AppColors.gold.withValues(alpha: 0.18),
                shape: CircleBorder(
                  side: BorderSide(color: AppColors.gold.withValues(alpha: 0.6)),
                ),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => provider.setTab(2),
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(Icons.shopping_bag_outlined,
                            size: 23, color: Colors.white),
                        if (cartCount > 0)
                          Positioned(
                            right: 5,
                            top: 5,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppColors.gold,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '$cartCount',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: controller,
            onChanged: onChanged,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Cari kaos, hoodie, celana...',
              hintStyle:
              const TextStyle(color: AppColors.textMuted, fontSize: 14),
              filled: true,
              fillColor: Colors.white,
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              prefixIcon:
              const Icon(Icons.search, color: AppColors.gold, size: 24),
              suffixIcon: hasText
                  ? IconButton(
                onPressed: onClear,
                icon: const Icon(Icons.close_rounded,
                    color: AppColors.textSecondary, size: 20),
              )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({required this.selected, required this.onSelected});

  /// null = "Semua"
  final ProductCategory? selected;
  final ValueChanged<ProductCategory?> onSelected;

  @override
  Widget build(BuildContext context) {
    final items = <ProductCategory?>[null, ...ProductCategory.values];

    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final category = items[i];
          final isSelected = category == selected;

          return GestureDetector(
            onTap: () => onSelected(category),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: isSelected
                  ? BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.gold, AppColors.goldLight],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              )
                  : BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    category?.icon ?? Icons.apps_rounded,
                    size: 18,
                    color: isSelected ? AppColors.primary : AppColors.gold,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    category?.label ?? 'Semua',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Slide {
  const _Slide(this.eyebrow, this.title, this.subtitle, this.background,
      this.circleA, this.circleB);

  final String eyebrow;
  final String title;
  final String subtitle;
  final Color background;
  final Color circleA;
  final Color circleB;
}

const _slides = <_Slide>[
  _Slide('KOLEKSI TERBARU', 'Essentials untuk\nsetiap harimu.',
      'Diskon hingga 30%', Color(0xFF5A1F2B), Color(0xFF73303D),
      Color(0xFFC9A24B)),
  _Slide('GRATIS ONGKIR', 'Belanja minimal\nRp500.000.',
      'Berlaku untuk seluruh Indonesia', Color(0xFF0F3D3A), Color(0xFF17524E),
      Color(0xFFEAD9A8)),
  _Slide('SEPATU & AKSESORIS', 'Lengkapi gayamu\nhari ini.',
      'Mulai dari Rp149.000', Color(0xFF2E2A52), Color(0xFF403B6B),
      Color(0xFFC9A24B)),
];

class _PromoCarousel extends StatefulWidget {
  const _PromoCarousel();

  @override
  State<_PromoCarousel> createState() => _PromoCarouselState();
}

class _PromoCarouselState extends State<_PromoCarousel> {
  final _controller = PageController();
  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_controller.hasClients) return;
      _controller.animateToPage(
        (_index + 1) % _slides.length,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: _slides.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (_, i) => _SlideView(slide: _slides[i]),
            ),
            Positioned(
              right: 20,
              bottom: 14,
              child: Row(
                children: [
                  for (var i = 0; i < _slides.length; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.only(left: 5),
                      width: i == _index ? 18 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: i == _index
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlideView extends StatelessWidget {
  const _SlideView({required this.slide});

  final _Slide slide;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: slide.background,
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -40,
            child: Container(
              width: 170,
              height: 170,
              decoration:
              BoxDecoration(color: slide.circleA, shape: BoxShape.circle),
            ),
          ),
          Positioned(
            right: 40,
            bottom: -70,
            child: Container(
              width: 130,
              height: 130,
              decoration:
              BoxDecoration(color: slide.circleB, shape: BoxShape.circle),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  slide.eyebrow,
                  style: TextStyle(
                    color: AppColors.goldLight.withValues(alpha: 0.9),
                    fontSize: 11,
                    letterSpacing: 1.8,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  slide.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    height: 1.15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  slide.subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.78),
                    fontSize: 12,
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