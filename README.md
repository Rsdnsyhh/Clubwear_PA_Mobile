# 🛍️ Clubwear

Aplikasi *e-commerce* toko pakaian pria berbasis **Flutter** dengan backend **Firebase**.
Dibuat sebagai Proyek Akhir mata kuliah **Pemrograman Piranti Bergerak**.

README ini berisi tiga bagian:

1. [Tentang Aplikasi](#1--tentang-aplikasi)
2. [Cara Kerja Aplikasi](#2--cara-kerja-aplikasi)
3. [Cara Menghubungkan dengan Database](#3--cara-menghubungkan-dengan-database)

---

## 1. 📖 Tentang Aplikasi

**Clubwear** adalah aplikasi belanja pakaian pria untuk perangkat mobile. Produk yang dijual meliputi kaos, kemeja, celana, jaket, sweater, sepatu, dan aksesoris. Aplikasi ini memfasilitasi transaksi jual-beli secara digital dengan dua peran pengguna.

| Peran | Kemampuan |
|-------|-----------|
| **User (pembeli)** | Melihat katalog, membuka detail produk, memilih ukuran, menyimpan favorit, mengelola keranjang, mengatur alamat pengiriman, checkout, dan melihat riwayat pesanan. |
| **Admin** | Login lewat halaman khusus admin (`admin@clubwear.id`), mengelola produk (tambah, ubah, hapus), memantau stok, dan melihat semua pesanan dari seluruh pengguna secara *real-time*. |

### Fitur Pengguna
- **Autentikasi** Email & Password (Firebase Auth). Setelah daftar, pengguna kembali ke halaman login dengan email terisi otomatis.
- **Katalog produk** per kategori dengan label *Sold Out*, *New*, dan diskon.
- **Urutkan produk** di beranda: harga terendah/tertinggi, terlaris, dan rating.
- **Detail produk**: pilih ukuran, jumlah, lihat deskripsi, dan peringatan stok menipis.
- **Pop up pilih ukuran** langsung dari tombol "+" pada kartu produk.
- **Keranjang** per ukuran, tersimpan di Firestore sehingga tidak hilang saat aplikasi ditutup.
- **Batas stok**: jumlah beli tidak bisa melebihi stok (contoh: Contrast Printed T-Shirt stok 3).
- **Ongkir** Rp20.000, **gratis untuk belanja ≥ Rp500.000**, dilengkapi progress bar di keranjang.
- **Favorit (wishlist)** dengan notifikasi saat ditambah atau dihapus.
- **Profil**: riwayat pesanan, alamat pengiriman, dan Pusat Bantuan.
- Tombol *back* Android di tab lain kembali ke Beranda terlebih dahulu.

### Fitur Admin
- **Dashboard admin** untuk manajemen toko.
- **CRUD produk**: tambah, ubah (harga, stok, nama, dll.), dan hapus produk. Gambar produk baru diisi lewat URL (opsional).
- **Pesanan masuk** dari semua pengguna, tampil *real-time*.
- **Upload produk awal**: tombol di menu dashboard untuk mengirim data produk bawaan aplikasi ke Firestore dengan satu klik.

### Teknologi yang Digunakan

| Kebutuhan | Paket / Layanan |
|-----------|-----------------|
| Framework | Flutter (Dart SDK `^3.5.0`) |
| State management | [`provider`](https://pub.dev/packages/provider) `^6.1.5+1` |
| Autentikasi | [`firebase_auth`](https://pub.dev/packages/firebase_auth) `^7.0.0` |
| Database | [`cloud_firestore`](https://pub.dev/packages/cloud_firestore) `^7.0.0` |
| Inisialisasi Firebase | [`firebase_core`](https://pub.dev/packages/firebase_core) `^5.0.0` |

Aplikasi ditargetkan untuk **Android** (`applicationId`: `com.example.clubwear`). Folder platform lain (iOS, web, Windows, macOS, Linux) ikut dibuat oleh Flutter dan sudah dikonfigurasi di `firebase.json`.

---

## 2. ⚙️ Cara Kerja Aplikasi

Aplikasi memakai arsitektur **Provider + service layer**:

```
UI (pages & widgets)  ⇄  ClubwearProvider  ⇄  Service  ⇄  Firebase (Auth & Firestore)
```

- **UI** menampilkan data dan meneruskan aksi pengguna ke provider.
- **`ClubwearProvider`** menyimpan semua state dan logika bisnis: keranjang, favorit, profil, tab aktif, perhitungan ongkir, dan status admin.
- **Service** (`lib/services/`) hanya berurusan dengan Cloud Firestore.

### Alur Utama

1. **Login & peran.** Provider mendengarkan `authStateChanges()` dari Firebase Auth. Jika email yang masuk sama dengan `ClubwearProvider.adminEmail` (`admin@clubwear.id`), pengguna dikenali sebagai admin.
2. **Sinkronisasi real-time.** Produk, keranjang, dan pesanan dibaca lewat `Stream` (`snapshots()`). Jika admin mengubah harga atau stok, tampilan pembeli ikut berubah tanpa *refresh*.
3. **Keranjang.** Item disimpan di sub-koleksi `users/{uid}/cartItems`, sehingga keranjang tiap pengguna terpisah dan tetap ada setelah aplikasi ditutup. Jumlah beli dibatasi oleh stok.
4. **Checkout.** Saat tombol "Checkout" ditekan, sistem menjalankan `Firestore Transaction` yang menyimpan pesanan sekaligus **mengurangi stok** dan **menambah jumlah terjual (sold)** pada dokumen produk, sehingga datanya selalu konsisten. Status awal pesanan: *Menunggu pembayaran*.
5. **Ongkir.** Biaya kirim Rp20.000, gratis jika subtotal ≥ Rp500.000.
6. **Admin.** Dashboard membaca semua pesanan dari semua pengguna memakai `collectionGroup('orders')`, dan mengelola produk lewat `ProductFirestoreService`.

### Struktur Data Firestore

```
products/{productId}                 # katalog produk (dibaca semua pengguna)
users/{uid}/cartItems/{itemKey}      # keranjang milik masing-masing pengguna
users/{uid}/orders/{orderId}         # pesanan milik pengguna
```

### Struktur Folder

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

## 3. 🔗 Cara Menghubungkan dengan Database

Aplikasi terhubung ke **Firebase** (Authentication + Cloud Firestore). Repositori ini sudah memuat `firebase_options.dart` untuk proyek Firebase pengembang. Ikuti langkah berikut jika ingin memakai database milik sendiri.

### Prasyarat
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart `>= 3.5.0`)
- Android Studio dan emulator atau perangkat fisik
- Akun Google
- [Node.js](https://nodejs.org/) (untuk Firebase CLI)

### Langkah 1 — Ambil dependensi

```bash
cd Clubwear_PA_Mobile
flutter pub get
```

### Langkah 2 — Buat project Firebase

1. Buka [Firebase Console](https://console.firebase.google.com/) dan buat **project baru**.
2. Masuk ke **Build → Authentication → Get started**, lalu aktifkan provider **Email/Password**.
3. Masuk ke **Build → Firestore Database → Create database**.
4. Untuk pengembangan, atur *Security Rules* ke **Test mode** agar *read/write* tidak terkena `permission-denied`.

   > ⚠️ Test mode otomatis berakhir setelah 30 hari dan tidak aman untuk produksi. Ganti dengan *Security Rules* yang sesuai sebelum aplikasi dipakai nyata.

### Langkah 3 — Hubungkan aplikasi dengan FlutterFire CLI

File `firebase_options.dart` dibuat otomatis oleh FlutterFire CLI.

```bash
npm install -g firebase-tools
firebase login
dart pub global activate flutterfire_cli
flutterfire configure
```

Pilih project Firebase yang baru dibuat dan platform yang dipakai (minimal Android). Perintah ini membuat ulang:

- `lib/firebase_options.dart`
- `firebase.json`
- `android/app/google-services.json`

### Langkah 4 — Buat akun admin

1. Di Firebase Console buka **Authentication → Users → Add user**.
2. Isi email `admin@clubwear.id` dan password pilihanmu.
3. Untuk memakai email admin lain, ubah `adminEmail` di `lib/providers/clubwear_provider.dart`.

### Langkah 5 — Jalankan aplikasi dan isi data produk

```bash
flutter run
```

1. Login lewat halaman **Login Admin**.
2. Dari menu dashboard, pilih **Upload produk awal** untuk mengirim data produk ke Firestore.
3. Keluar, lalu daftar sebagai user biasa lewat halaman **Register** untuk mencoba alur belanja.

### Troubleshooting

| Masalah | Solusi |
|---------|--------|
| Pesanan di dashboard admin tidak muncul, log berisi `FAILED_PRECONDITION: requires an index` | Query `collectionGroup('orders')` butuh indeks. Buka link yang muncul di log error untuk membuatnya otomatis, lalu tunggu beberapa menit. |
| `permission-denied` | Periksa *Security Rules* Firestore (Test mode mungkin sudah kedaluwarsa). |
| `invalid-credential` saat login admin | Pastikan akun `admin@clubwear.id` sudah dibuat di Authentication pada project yang sama dengan `firebase_options.dart`. |
| Gambar produk tidak tampil | Jalankan `flutter pub get` dan pastikan folder `assets/images/<kategori>/` terdaftar di `pubspec.yaml`. |
