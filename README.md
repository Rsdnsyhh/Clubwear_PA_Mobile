# 🛍️ Clubwear

Aplikasi *e-commerce* toko pakaian pria berbasis **Flutter** dengan backend **Firebase**.
Dibuat sebagai Proyek Akhir mata kuliah **Pemrograman Piranti Bergerak**.

Produk yang dijual: kaos, kemeja, celana, jaket, sweater, sepatu, dan aksesoris.

---

## 📖 Tentang Aplikasi

Aplikasi memiliki dua peran:

| Peran | Kemampuan |
|-------|-----------|
| **User (pembeli)** | Melihat katalog, membuka detail produk, memilih ukuran, menyimpan favorit, mengelola keranjang, mengatur alamat, checkout, dan melihat riwayat pesanan. |
| **Admin** | Login lewat halaman khusus admin (`admin@clubwear.id`), mengelola produk (tambah, ubah, hapus), memantau stok, dan melihat semua pesanan dari seluruh pengguna secara *real-time*. |

---

## ✨ Fitur

### Pengguna
- **Autentikasi** Email & Password (Firebase Auth). Setelah daftar, pengguna kembali ke halaman login dengan email terisi otomatis.
- **Katalog produk** per kategori dengan label *Sold Out*, *New*, dan diskon.
- **Urutkan produk** di beranda: harga terendah/tertinggi, terlaris, rating.
- **Detail produk**: pilih ukuran, jumlah, deskripsi, dan peringatan stok menipis.
- **Pop up pilih ukuran** langsung dari tombol "+" pada kartu produk.
- **Keranjang** per ukuran, tersimpan di Firestore sehingga tidak hilang saat aplikasi ditutup.
- **Batas stok**: jumlah beli tidak bisa melebihi stok (contoh: Contrast Printed T-Shirt stok 3).
- **Ongkir** Rp20.000, **gratis untuk belanja ≥ Rp500.000**, dilengkapi progress bar di keranjang.
- **Favorit (wishlist)** dengan notifikasi saat ditambah atau dihapus.
- **Profil**: riwayat pesanan, alamat pengiriman, dan Pusat Bantuan.
- Tombol *back* Android di tab lain kembali ke Beranda terlebih dahulu.

### Admin
- **Dashboard admin** untuk manajemen toko.
- **CRUD produk**: tambah, ubah (harga, stok, nama, dll.), dan hapus produk. Gambar produk baru diisi lewat URL (opsional).
- **Pesanan masuk** dari semua pengguna, tampil *real-time*.
- **Upload produk awal**: tombol di menu dashboard untuk mengirim data produk bawaan aplikasi ke Firestore dengan satu klik.

---

## 🧰 Teknologi

| Kebutuhan | Paket / Layanan |
|-----------|-----------------|
| Framework | Flutter (Dart SDK `^3.5.0`) |
| State management | [`provider`](https://pub.dev/packages/provider) `^6.1.5+1` |
| Autentikasi | [`firebase_auth`](https://pub.dev/packages/firebase_auth) `^7.0.0` |
| Database | [`cloud_firestore`](https://pub.dev/packages/cloud_firestore) `^7.0.0` |
| Inisialisasi Firebase | [`firebase_core`](https://pub.dev/packages/firebase_core) `^5.0.0` |

---

## 📁 Struktur Folder

```
Clubwear_PA_Mobile/
├── android/ ios/ web/ windows/ linux/ macos/   # folder platform (dibuat otomatis oleh Flutter)
├── assets/
│   └── images/                                 # foto produk p01.jpg ... p35.jpg
│       ├── kaos/        (p01 - p05)
│       ├── kemeja/      (p06 - p10)
│       ├── celana/      (p11 - p15)
│       ├── jaket/       (p16 - p20)
│       ├── sweater/     (p21 - p25)
│       ├── sepatu/      (p26 - p30)
│       └── aksesoris/   (p31 - p35)
├── lib/
│   ├── main.dart                       # inisialisasi Firebase, MaterialApp, tema, ChangeNotifierProvider
│   ├── firebase_options.dart           # konfigurasi Firebase (hasil flutterfire configure)
│   ├── models/
│   │   ├── product.dart                # Product, ProductCategory, formatRupiah()
│   │   ├── cart_item.dart              # item keranjang
│   │   └── order.dart                  # Order & OrderLine (riwayat pesanan)
│   ├── providers/
│   │   └── clubwear_provider.dart      # state: produk, favorit, keranjang, akun, tab aktif, status admin
│   ├── services/                       # akses Cloud Firestore
│   │   ├── product_firestore_service.dart
│   │   ├── cart_firestore_service.dart
│   │   └── order_firestore_service.dart
│   ├── pages/
│   │   ├── splash_page.dart
│   │   ├── login_page.dart
│   │   ├── register_page.dart
│   │   ├── main_nav_page.dart          # bottom navigation 4 tab
│   │   ├── home_page.dart
│   │   ├── product_detail_page.dart
│   │   ├── favorite_page.dart
│   │   ├── cart_page.dart
│   │   ├── profile_page.dart
│   │   ├── admin_login_page.dart       # login khusus admin
│   │   ├── admin_dashboard_page.dart   # daftar produk & pesanan
│   │   ├── admin_profile_page.dart
│   │   └── add_product_page.dart       # form tambah / ubah produk
│   └── widgets/
│       ├── product_card.dart           # ProductCard + ProductImage
│       ├── size_picker_dialog.dart     # pop up pilih ukuran
│       └── common_widgets.dart         # AppColors, PrimaryButton, AppTextField, EmptyState, dll.
├── test/
│   └── widget_test.dart
├── firebase.json                       # konfigurasi FlutterFire
├── pubspec.yaml
└── README.md
```

---

## ⚙️ Cara Kerja

Arsitektur: **Provider + service layer**.

1. **State & logika bisnis** (keranjang, favorit, profil, tab aktif, perhitungan ongkir, status admin) ada di `ClubwearProvider`.
2. **Service** (`lib/services/`) hanya berurusan dengan Firestore. Provider memanggil service, lalu UI mendengarkan provider.
3. **Real-time**: produk, keranjang, dan pesanan dibaca lewat `Stream` (`snapshots()`). Jika admin mengubah harga atau stok, tampilan pembeli ikut berubah tanpa *refresh*.
4. **Checkout**: memakai `Firestore Transaction` agar penyimpanan pesanan, pengurangan **stok**, dan penambahan jumlah **terjual** berjalan konsisten.
5. **Admin** dikenali dari email `admin@clubwear.id` (konstanta `ClubwearProvider.adminEmail`).

### Struktur data Firestore

```
products/{productId}                 # katalog produk (dibaca semua pengguna)
users/{uid}/cartItems/{itemKey}      # keranjang milik masing-masing pengguna
users/{uid}/orders/{orderId}         # pesanan milik pengguna
```

Dashboard admin membaca semua pesanan memakai `collectionGroup('orders')`.

---

## 🚀 Cara Menjalankan

### Prasyarat
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart `>= 3.5.0`)
- Android Studio / emulator atau perangkat fisik
- Akun Google untuk Firebase

### 1. Ambil dependensi

```bash
cd Clubwear_PA_Mobile
flutter pub get
```

### 2. Siapkan Firebase milik sendiri

> Repositori ini sudah memuat `firebase_options.dart` untuk proyek Firebase pengembang. Agar memakai database sendiri, ikuti langkah berikut.

1. Buka [Firebase Console](https://console.firebase.google.com/) dan buat **project baru**.
2. **Build → Authentication → Get started**, aktifkan provider **Email/Password**.
3. **Build → Firestore Database → Create database**.
4. Untuk pengembangan, gunakan **Test mode** agar tidak terkena *permission denied*.
   > ⚠️ Test mode otomatis berakhir setelah 30 hari dan tidak aman untuk produksi. Ganti dengan *Security Rules* sebelum aplikasi dipakai nyata.
5. Hubungkan aplikasi dengan FlutterFire CLI:

   ```bash
   npm install -g firebase-tools
   firebase login
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

   Perintah terakhir membuat ulang `lib/firebase_options.dart`, `firebase.json`, dan `android/app/google-services.json`.

### 3. Buat akun admin

1. Di Firebase Console buka **Authentication → Users → Add user**.
2. Isi email `admin@clubwear.id` dan password pilihanmu.
3. Login lewat halaman **Login Admin** di aplikasi.
4. Dari menu dashboard, pilih **Upload produk awal** untuk mengisi katalog.

Untuk memakai email admin yang lain, ubah `adminEmail` di `lib/providers/clubwear_provider.dart`.

### 4. Jalankan

```bash
flutter run
```

### Troubleshooting

| Masalah | Solusi |
|---------|--------|
| Pesanan admin tidak muncul, ada error `FAILED_PRECONDITION: requires an index` | Query `collectionGroup('orders')` butuh indeks. Buka link yang muncul di log error untuk membuatnya otomatis, lalu tunggu beberapa menit. |
| `permission-denied` | Cek *Security Rules* Firestore (lihat langkah 2.4). |
| Gambar produk tidak tampil | Pastikan `flutter pub get` sudah dijalankan dan folder `assets/images/<kategori>/` terdaftar di `pubspec.yaml`. |

---

## 👤 Akun Demo

| Peran | Email | Password |
|-------|-------|----------|
| Admin | `admin@clubwear.id` | *(sesuai yang kamu buat di Firebase)* |
| User | daftar sendiri lewat halaman Register | |

---

## 📝 Catatan Pengembangan

- Aplikasi ditargetkan untuk **Android** (`applicationId`: `com.example.clubwear`). Folder platform lain ikut dibuat Flutter dan sudah dikonfigurasi di `firebase.json`.
- `.dart_tool/`, `build/`, dan `.git/` jangan ikut dikirim saat mengumpulkan proyek dalam bentuk ZIP. Cukup `lib/`, `assets/`, `android/`, `ios/`, `web/`, `test/`, `pubspec.yaml`, `firebase.json`, dan `README.md`.
