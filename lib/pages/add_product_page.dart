import 'package:flutter/material.dart';

import '../models/product.dart';
import '../services/product_firestore_service.dart';
import '../widgets/common_widgets.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key, this.product});

  /// null = tambah baru, tidak null = edit produk.
  final Product? product;

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _originalPriceController;
  late final TextEditingController _stockController;
  late final TextEditingController _sizesController;
  late final TextEditingController _imageController;

  late ProductCategory _category;
  bool _isNew = false;
  bool _saving = false;
  String? _error;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameController = TextEditingController(text: p?.name ?? '');
    _priceController =
        TextEditingController(text: p?.price.toString() ?? '');
    _originalPriceController =
        TextEditingController(text: p?.originalPrice?.toString() ?? '');
    _stockController =
        TextEditingController(text: p?.stock.toString() ?? '20');
    _sizesController =
        TextEditingController(text: p?.sizes.join(', ') ?? 'S, M, L, XL');
    _imageController = TextEditingController(text: p?.image ?? '');
    _category = p?.category ?? ProductCategory.kaos;
    _isNew = p?.isNew ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _originalPriceController.dispose();
    _stockController.dispose();
    _sizesController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final sizes = _sizesController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      if (sizes.isEmpty) {
        setState(() {
          _saving = false;
          _error = 'Minimal satu ukuran harus diisi.';
        });
        return;
      }

      final service = ProductFirestoreService();
      final price = int.tryParse(_priceController.text.trim()) ?? 0;
      final originalPrice =
      int.tryParse(_originalPriceController.text.trim());
      final stock = int.tryParse(_stockController.text.trim()) ?? 0;

      if (_isEditing) {
        final updated = Product(
          id: widget.product!.id,
          name: _nameController.text.trim(),
          category: _category,
          price: price,
          originalPrice: originalPrice,
          sold: widget.product!.sold,
          stock: stock,
          isNew: _isNew,
          sizes: sizes,
          color: widget.product!.color,
          image: _imageController.text.trim(),
        );
        await service.updateProduct(updated);
      } else {
        // PERBAIKAN: Buat objek Product terlebih dahulu sebelum dikirim ke addProduct
        final newProduct = Product(
          id: '',
          name: _nameController.text.trim(),
          category: _category,
          price: price,
          originalPrice: originalPrice,
          sold: 0,
          stock: stock,
          isNew: _isNew,
          sizes: sizes,
          color: const Color(0xFFE0E0E0),
          image: _imageController.text.trim(),
        );
        await service.addProduct(newProduct);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing
              ? 'Produk berhasil diperbarui.'
              : 'Produk berhasil ditambahkan.'),
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = 'Gagal menyimpan: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Produk' : 'Tambah Produk'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            AppTextField(
              controller: _nameController,
              hint: 'Nama Produk',
              icon: Icons.label_outline,
              textInputAction: TextInputAction.next,
              validator: (v) => Validators.notEmpty(v, 'Nama produk'),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<ProductCategory>(
              value: _category,
              decoration: InputDecoration(
                labelText: 'Kategori',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide:
                  const BorderSide(color: AppColors.gold, width: 1.6),
                ),
              ),
              items: ProductCategory.values
                  .map((c) => DropdownMenuItem(
                value: c,
                child: Text(c.label),
              ))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _category = v);
              },
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: _priceController,
              hint: 'Harga',
              icon: Icons.attach_money,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              validator: (v) {
                final n = int.tryParse((v ?? '').trim());
                if (n == null || n <= 0) return 'Harga harus angka > 0';
                return null;
              },
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: _originalPriceController,
              hint: 'Harga sebelum diskon (opsional)',
              icon: Icons.price_change_outlined,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: _stockController,
              hint: 'Stok',
              icon: Icons.inventory_outlined,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              validator: (v) {
                final n = int.tryParse((v ?? '').trim());
                if (n == null || n < 0) return 'Stok harus angka >= 0';
                return null;
              },
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: _sizesController,
              hint: 'Ukuran (pisahkan dengan koma)',
              icon: Icons.straighten,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: _imageController,
              hint: 'URL gambar (opsional)',
              icon: Icons.image_outlined,
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Tandai sebagai produk baru'),
              value: _isNew,
              onChanged: (v) => setState(() => _isNew = v),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  _error!,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            PrimaryButton(
              label: _isEditing ? 'Simpan Perubahan' : 'Tambahkan Produk',
              icon: Icons.save_outlined,
              isLoading: _saving,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}