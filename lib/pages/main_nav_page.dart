import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/clubwear_provider.dart';
import '../widgets/common_widgets.dart';
import 'cart_page.dart';
import 'favorite_page.dart';
import 'home_page.dart';
import 'profile_page.dart';

/// Kerangka utama setelah login: 4 tab + bottom navigation melayang.
class MainNavPage extends StatelessWidget {
  const MainNavPage({super.key});

  static const _pages = <Widget>[
    HomePage(),
    FavoritePage(),
    CartPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final index = context.select<ClubwearProvider, int>((p) => p.tabIndex);

    // Tombol back di tab selain Beranda -> kembali ke Beranda dulu.
    return PopScope(
      canPop: index == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.read<ClubwearProvider>().setTab(0);
      },
      child: Scaffold(
        body: IndexedStack(index: index, children: _pages),
        bottomNavigationBar: const _BottomNav(),
      ),
    );
  }
}

class _NavData {
  const _NavData(this.label, this.icon, this.activeIcon);

  final String label;
  final IconData icon;
  final IconData activeIcon;
}

class _BottomNav extends StatelessWidget {
  const _BottomNav();

  static const _items = <_NavData>[
    _NavData('Beranda', Icons.home_outlined, Icons.home_rounded),
    _NavData('Favorit', Icons.favorite_border_rounded, Icons.favorite_rounded),
    _NavData('Keranjang', Icons.shopping_bag_outlined, Icons.shopping_bag),
    _NavData('Profil', Icons.person_outline_rounded, Icons.person_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClubwearProvider>();

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
        child: Container(
          height: 66,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            gradient: AppColors.heroGradient,
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                color: Color(0x4D0F1E36),
                blurRadius: 22,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              for (var i = 0; i < _items.length; i++)
                Expanded(
                  flex: provider.tabIndex == i ? 2 : 1,
                  child: _NavItem(
                    data: _items[i],
                    selected: provider.tabIndex == i,
                    badge: i == 2 ? provider.cartCount : 0,
                    onTap: () => provider.setTab(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.data,
    required this.selected,
    required this.badge,
    required this.onTap,
  });

  final _NavData data;
  final bool selected;
  final int badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final iconColor =
    selected ? AppColors.primary : Colors.white.withValues(alpha: 0.65);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          height: 46,
          padding: EdgeInsets.symmetric(horizontal: selected ? 14 : 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.gold : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    selected ? data.activeIcon : data.icon,
                    size: 23,
                    color: iconColor,
                  ),
                  if (badge > 0)
                    Positioned(
                      right: -9,
                      top: -6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1),
                        constraints: const BoxConstraints(minWidth: 16),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.primary : AppColors.gold,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$badge',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: selected ? AppColors.gold : AppColors.primary,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              if (selected) ...[
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    data.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}