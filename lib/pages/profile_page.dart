import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/order.dart';
import '../models/product.dart';
import '../providers/clubwear_provider.dart';
import '../widgets/common_widgets.dart';
import 'login_page.dart';

// =====================================================================
//  DIALOG ALAMAT (dipakai juga oleh halaman keranjang)
// =====================================================================

Future<void> showAddressDialog(BuildContext context) async {
  final provider = context.read<ClubwearProvider>();
  final saved = await showDialog<bool>(
    context: context,
    builder: (_) => _AddressDialog(initial: provider.address),
  );

  if (saved == true && context.mounted) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Alamat pengiriman disimpan.')),
      );
  }
}

class _AddressDialog extends StatefulWidget {
  const _AddressDialog({required this.initial});

  final String initial;

  @override
  State<_AddressDialog> createState() => _AddressDialogState();
}

class _AddressDialogState extends State<_AddressDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller =
  TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    context.read<ClubwearProvider>().setAddress(_controller.text);
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Alamat Pengiriman'),
      content: SizedBox(
        width: 380,
        child: Form(
          key: _formKey,
          child: TextFormField(
            controller: _controller,
            autofocus: true,
            minLines: 3,
            maxLines: 4,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) {
              final text = (value ?? '').trim();
              if (text.isEmpty) return 'Alamat wajib diisi';
              if (text.length < 10) return 'Alamat terlalu singkat (min. 10 karakter)';
              return null;
            },
            decoration: InputDecoration(
              hintText: 'Contoh: Jl. Pramuka No. 10, Samarinda',
              hintStyle: const TextStyle(color: AppColors.textMuted),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Batal'),
        ),
        TextButton(onPressed: _save, child: const Text('Simpan')),
      ],
    );
  }
}

// =====================================================================
//  DIALOG EDIT PROFIL
// =====================================================================

class _EditProfileDialog extends StatefulWidget {
  const _EditProfileDialog({
    required this.initialName,
    required this.initialEmail,
  });

  final String initialName;
  final String initialEmail;

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController =
  TextEditingController(text: widget.initialName);
  late final TextEditingController _emailController =
  TextEditingController(text: widget.initialEmail);
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final error = context.read<ClubwearProvider>().updateProfile(
      name: _nameController.text,
      email: _emailController.text,
    );

    if (error != null) {
      setState(() => _error = error);
      return;
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Profil'),
      content: SizedBox(
        width: 380,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                controller: _nameController,
                hint: 'Username',
                icon: Icons.person_outline,
                textInputAction: TextInputAction.next,
                validator: (v) => Validators.notEmpty(v, 'Username'),
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller: _emailController,
                hint: 'Email',
                icon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                validator: Validators.email,
                onSubmitted: (_) => _save(),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.error_outline,
                        size: 16, color: AppColors.accent),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _error!,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Batal'),
        ),
        TextButton(onPressed: _save, child: const Text('Simpan')),
      ],
    );
  }
}

// =====================================================================
//  HALAMAN PROFIL
// =====================================================================

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar dari akun?'),
        content: const Text('Kamu perlu masuk lagi untuk melanjutkan belanja.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    context.read<ClubwearProvider>().logout();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginPage()),
          (route) => false,
    );
  }

  Future<void> _editProfile(BuildContext context) async {
    final user = context.read<ClubwearProvider>().user;
    if (user == null) return;

    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => _EditProfileDialog(
        initialName: user.name,
        initialEmail: user.email,
      ),
    );

    if (saved == true && context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Profil berhasil diperbarui.')),
        );
    }
  }

  void _showHelp(BuildContext context) {
    const faqs = <(String, String)>[
      ('Berapa lama pengiriman?',
      'Pesanan dikirim 1–2 hari kerja setelah checkout, lalu tiba dalam 2–5 hari tergantung lokasi.'),
      ('Bagaimana cara membaca kode pesanan?',
      'Contoh CW001-KAOS2-SEPATU1 artinya pesanan ke-1 berisi 2 kaos dan 1 sepatu.'),
      ('Bagaimana cara menukar ukuran?',
      'Penukaran bisa dilakukan maksimal 7 hari setelah barang diterima selama label masih terpasang.'),
      ('Kapan gratis ongkir berlaku?',
      'Gratis ongkir untuk total belanja minimal Rp500.000.'),
    ];

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      constraints: const BoxConstraints(maxWidth: 560),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (_) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pusat Bantuan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              for (final faq in faqs)
                ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: const EdgeInsets.only(bottom: 12),
                  shape: const Border(),
                  collapsedShape: const Border(),
                  title: Text(
                    faq.$1,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      faq.$2,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 8),
              const Row(
                children: [
                  Icon(Icons.mail_outline, size: 18),
                  SizedBox(width: 10),
                  Text('cs@clubwear.id', style: TextStyle(fontSize: 13)),
                ],
              ),
              const SizedBox(height: 8),
              const Row(
                children: [
                  Icon(Icons.chat_outlined, size: 18),
                  SizedBox(width: 10),
                  Text('WhatsApp 0812-0000-0000',
                      style: TextStyle(fontSize: 13)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClubwearProvider>();
    final user = provider.user;
    final orderCount = provider.orders.length;
    final top = MediaQuery.of(context).padding.top;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // ---------- HERO PROFIL ----------
        Container(
          padding: EdgeInsets.fromLTRB(20, top + 24, 20, 24),
          decoration: const BoxDecoration(
            gradient: AppColors.heroGradient,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [AppColors.gold, AppColors.goldLight],
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        user?.initial ?? '?',
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'Pengguna',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          user?.email ?? '-',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
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
                      side: BorderSide(
                          color: AppColors.gold.withValues(alpha: 0.6)),
                    ),
                    child: IconButton(
                      tooltip: 'Edit profil',
                      onPressed: () => _editProfile(context),
                      icon: const Icon(Icons.edit_outlined,
                          size: 20, color: AppColors.gold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.favorite_rounded,
                      value: provider.favoriteCount,
                      label: 'Favorit',
                      onTap: () => provider.setTab(1),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.shopping_bag_rounded,
                      value: provider.cartCount,
                      label: 'Di keranjang',
                      onTap: () => provider.setTab(2),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // ---------- MENU ----------
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          child: Column(
            children: [
              _MenuTile(
                icon: Icons.person_outline,
                color: AppColors.gold,
                label: 'Edit Profil',
                subtitle: 'Ubah username dan email',
                onTap: () => _editProfile(context),
              ),
              const SizedBox(height: 10),
              _MenuTile(
                icon: Icons.receipt_long_outlined,
                color: const Color(0xFF3B4A8C),
                label: 'Pesanan Saya',
                subtitle: orderCount == 0 ? null : '$orderCount pesanan',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const OrdersPage()),
                ),
              ),
              const SizedBox(height: 10),
              _MenuTile(
                icon: Icons.location_on_outlined,
                color: const Color(0xFF1F7A6B),
                label: 'Alamat Pengiriman',
                subtitle:
                provider.hasAddress ? provider.address : 'Belum diatur',
                onTap: () => showAddressDialog(context),
              ),
              const SizedBox(height: 10),
              _MenuTile(
                icon: Icons.help_outline,
                color: const Color(0xFFA23B4C),
                label: 'Pusat Bantuan',
                onTap: () => _showHelp(context),
              ),
              const SizedBox(height: 14),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border:
                  Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.cloud_off_outlined,
                        size: 18, color: AppColors.gold),
                    SizedBox(width: 10),
                    Text(
                      'Mode demo • data lokal',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              PrimaryButton(
                label: 'Keluar',
                icon: Icons.logout_rounded,
                onPressed: () => _logout(context),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Kartu statistik transparan di dalam hero profil.
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final int value;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: AppColors.gold),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$value',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      radius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, size: 21, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded,
              size: 22, color: AppColors.textMuted),
        ],
      ),
    );
  }
}

// =====================================================================
//  DAFTAR PESANAN
// =====================================================================

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<ClubwearProvider>().orders;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Pesanan Saya',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: orders.isEmpty
          ? const EmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'Belum ada pesanan',
        subtitle: 'Pesanan yang kamu checkout akan muncul di sini.',
      )
          : ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: orders.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) => _OrderCard(order: orders[i]),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => OrderDetailPage(order: order),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  order.id,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              const _StatusChip(),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            order.contentSummary,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 2),
          Text(
            formatTanggal(order.date),
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: AppColors.border),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '${order.itemCount} barang',
                style: const TextStyle(
                    fontSize: 12.5, color: AppColors.textSecondary),
              ),
              const Spacer(),
              Text(
                formatRupiah(order.total),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded,
                  size: 20, color: AppColors.textSecondary),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: const Text(
        'Diproses',
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// =====================================================================
//  RINCIAN PESANAN (halaman sukses checkout & detail dari riwayat)
// =====================================================================

class OrderDetailPage extends StatelessWidget {
  const OrderDetailPage({
    super.key,
    required this.order,
    this.justOrdered = false,
  });

  final Order order;

  /// true = tampil sebagai halaman "Pesanan berhasil dibuat".
  final bool justOrdered;

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
                fontSize: 12.5, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      text,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ClubwearProvider>();

    return Scaffold(
      appBar: justOrdered
          ? null
          : AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Detail Pesanan',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (justOrdered) ...[
                    const SizedBox(height: 8),
                    Center(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.6, end: 1),
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.elasticOut,
                        builder: (_, scale, child) =>
                            Transform.scale(scale: scale, child: child),
                        child: Container(
                          width: 84,
                          height: 84,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check_rounded,
                              color: Colors.white, size: 50),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Pesanan berhasil dibuat!',
                      textAlign: TextAlign.center,
                      style:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Terima kasih sudah belanja di Clubwear.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 13, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // ---------- KODE PESANAN ----------
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'KODE PESANAN',
                          style: TextStyle(
                            fontSize: 11,
                            letterSpacing: 1.4,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                order.id,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ),
                            IconButton(
                              tooltip: 'Salin kode',
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: order.id));
                                ScaffoldMessenger.of(context)
                                  ..hideCurrentSnackBar()
                                  ..showSnackBar(const SnackBar(
                                      content: Text('Kode pesanan disalin.')));
                              },
                              icon: const Icon(Icons.copy_rounded, size: 18),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.inventory_2_outlined,
                                size: 16, color: AppColors.textSecondary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Isi pesanan: ${order.contentSummary}',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ---------- INFO PESANAN ----------
                  AppCard(
                    child: Column(
                      children: [
                        _infoRow('Tanggal', formatTanggal(order.date)),
                        _infoRow('Status', 'Diproses'),
                        _infoRow('Dikirim ke',
                            order.address.isEmpty ? '-' : order.address),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ---------- RINCIAN PRODUK ----------
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle('Rincian Produk'),
                        for (var i = 0; i < order.lines.length; i++) ...[
                          if (i > 0)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Container(height: 1, color: AppColors.border),
                            ),
                          _LineRow(line: order.lines[i]),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ---------- RINGKASAN PEMBAYARAN ----------
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle('Ringkasan Pembayaran'),
                        _infoRow('Subtotal (${order.itemCount} barang)',
                            formatRupiah(order.subtotal)),
                        _infoRow(
                          'Ongkos kirim',
                          order.shipping == 0
                              ? 'Gratis'
                              : formatRupiah(order.shipping),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Divider(height: 1, color: AppColors.border),
                        ),
                        Row(
                          children: [
                            const Text(
                              'Total',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w700),
                            ),
                            const Spacer(),
                            Text(
                              formatRupiah(order.total),
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  if (justOrdered) ...[
                    const SizedBox(height: 20),
                    PrimaryButton(
                      label: 'Kembali ke Beranda',
                      onPressed: () {
                        provider.setTab(0);
                        Navigator.of(context).pop();
                      },
                    ),
                    const SizedBox(height: 4),
                    TextButton(
                      onPressed: () {
                        final navigator = Navigator.of(context);
                        provider.setTab(3);
                        navigator.pop();
                        navigator.push(
                          MaterialPageRoute<void>(
                            builder: (_) => const OrdersPage(),
                          ),
                        );
                      },
                      child: const Text(
                        'Lihat pesanan saya',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LineRow extends StatelessWidget {
  const _LineRow({required this.line});

  final OrderLine line;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                line.name,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '${line.category} • Ukuran ${line.size}',
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 2),
              Text(
                '${line.quantity} × ${formatRupiah(line.price)}',
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          formatRupiah(line.subtotal),
          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}