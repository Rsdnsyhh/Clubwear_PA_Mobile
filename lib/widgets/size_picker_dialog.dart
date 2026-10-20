import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/clubwear_provider.dart';
import 'common_widgets.dart';
import 'product_card.dart';

/// Pop up pilih ukuran baju. Muncul saat tombol tambah keranjang ditekan.
Future<void> showSizePickerDialog(BuildContext context, Product product) {
  return showDialog<void>(
    context: context,
    builder: (_) => SizePickerDialog(product: product),
  );
}

class SizePickerDialog extends StatefulWidget {
  const SizePickerDialog({super.key, required this.product});

  final Product product;

  @override
  State<SizePickerDialog> createState() => _SizePickerDialogState();
}

class _SizePickerDialogState extends State<SizePickerDialog> {
  String? _selected;

  @override
  void initState() {
    super.initState();
    // Produk All Size: langsung terpilih.
    if (widget.product.sizes.length == 1) _selected = widget.product.sizes.first;
  }

  void _submit() {
    final size = _selected;
    if (size == null) return;

    final provider = context.read<ClubwearProvider>();
    final messenger = ScaffoldMessenger.of(context);

    provider.addToCart(widget.product, size);
    Navigator.of(context).pop();

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 3),
          content: Text('${widget.product.name} (Ukuran $size) masuk keranjang'),
          action: SnackBarAction(
            label: 'LIHAT',
            textColor: Colors.white,
            onPressed: () => provider.setTab(2),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: SizedBox(
                      width: 72,
                      height: 82,
                      child: ProductImage(product: product),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          formatRupiah(product.price),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  const Text(
                    'Pilih Ukuran',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  if (_selected != null)
                    Text(
                      'Terpilih: $_selected',
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
                      selected: _selected == size,
                      onTap: () => setState(() => _selected = size),
                    ),
                ],
              ),
              const SizedBox(height: 26),
              PrimaryButton(
                label: _selected == null
                    ? 'Pilih ukuran terlebih dahulu'
                    : 'Tambahkan ke Keranjang',
                icon: _selected == null ? null : Icons.shopping_bag_outlined,
                onPressed: _selected == null ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SizeChip extends StatelessWidget {
  const SizeChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        constraints: const BoxConstraints(minWidth: 58),
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.primary,
          ),
        ),
      ),
    );
  }
}
