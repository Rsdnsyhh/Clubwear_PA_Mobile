# Clubwear - Proyek Akhir Pemrograman Piranti Bergerak

Aplikasi toko pakaian pria

## Cara menjalankan

```bash
cd nama_folder
flutter pub get
flutter run
```

## Struktur

```
clubwear_app/
├── pubspec.yaml
├── assets/images/                  # foto produk p01.jpg ... p35.jpg
└── lib/
    ├── main.dart                   # MaterialApp + tema + ChangeNotifierProvider
    ├── models/
    │   ├── product.dart            # Product, ProductCategory, formatRupiah()
    │   ├── cart_item.dart
    │   └── order.dart              # riwayat pesanan
    ├── providers/
    │   └── clubwear_provider.dart  # produk, favorit, keranjang, akun, tab aktif
    ├── pages/
    │   ├── splash_page.dart
    │   ├── login_page.dart
    │   ├── register_page.dart
    │   ├── main_nav_page.dart      # bottom navigation 4 tab
    │   ├── home_page.dart
    │   ├── product_detail_page.dart
    │   ├── favorite_page.dart
    │   ├── cart_page.dart
    │   └── profile_page.dart
    └── widgets/
        ├── product_card.dart       # ProductCard + ProductImage
        ├── size_picker_dialog.dart # pop up pilih ukuran
        └── common_widgets.dart     # AppColors, PrimaryButton, AppTextField, EmptyState, dll
```

## Perbaikan

1. Pop up pilih ukuran: `widgets/size_picker_dialog.dart`, dipanggil dari tombol "+" di `product_card.dart`.
2. Setelah daftar kembali ke login: `register_page.dart` memanggil `Navigator.pop(context, email)`;
   `login_page.dart` (`_goToRegister`) mengisi email otomatis dan menampilkan SnackBar sukses.

## Fitur tambahan

- Halaman detail produk (ketuk kartu): pilih ukuran, jumlah, deskripsi, info stok menipis.
- Urutkan produk di beranda: harga terendah/tertinggi, terlaris, rating.
- Stok membatasi jumlah beli (contoh: Contrast Printed T-Shirt stok 3).
- Ongkir Rp20.000, gratis untuk belanja >= Rp500.000 + progress bar di keranjang.
- Riwayat pesanan, alamat pengiriman, dan Pusat Bantuan di profil sudah berfungsi.
- Tombol back Android di tab lain kembali ke Beranda dulu; notifikasi saat favorit diubah.
