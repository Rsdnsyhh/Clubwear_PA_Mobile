# 🛍️ Clubwear - E-Commerce Fashion App (Mobile)

**Clubwear** adalah aplikasi *e-commerce mobile* berbasis Android dan iOS yang dibangun menggunakan framework **Flutter**[cite: 3]. Aplikasi ini dirancang khusus untuk memenuhi tugas akhir (Projek Akhir Mobile) dan berfokus pada penjualan produk *fashion* (kaos, kemeja, celana, jaket, sweater, sepatu, dan aksesoris) dengan antarmuka pengguna yang modern, interaktif, dan responsif[cite: 10].

---

## 📖 Tentang Aplikasi

Aplikasi Clubwear memfasilitasi transaksi jual-beli pakaian secara digital dengan membagi hak akses menjadi dua peran utama:

1. **User (Pembeli):**
   Dapat menjelajahi katalog produk, melihat detail produk (termasuk diskon dan stok), memilih ukuran[cite: 4], menambahkan barang ke keranjang[cite: 8], mengatur alamat pengiriman, dan melakukan *checkout* pesanan[cite: 10]. Pengguna juga dapat menyimpan produk ke daftar favorit[cite: 6, 10].
2. **Admin:**
   Memiliki akses ke **Admin Dashboard** khusus (login menggunakan email khusus admin, misal: `admin@clubwear.id`). Admin dapat mengelola produk (Tambah, Edit, Hapus), memantau stok, serta melihat seluruh daftar pesanan yang masuk dari pengguna secara *real-time*[cite: 9, 11].

---

## ✨ Fitur Utama

### 🛒 Fitur Pengguna (User)
* **Autentikasi:** Login dan Register menggunakan Email & Password (Firebase Auth)[cite: 8, 9, 10, 11].
* **Katalog Produk:** Menampilkan daftar produk berdasarkan kategori dengan indikator *Sold Out*, *New*, dan *Diskon*[cite: 6, 10].
* **Manajemen Keranjang (Cart):** Menambah, mengurangi kuantitas, atau menghapus produk dari keranjang belanja berdasarkan ukuran (Size)[cite: 8, 10].
* **Favorit (Wishlist):** Menyimpan produk yang disukai[cite: 6, 10].
* **Checkout & Pesanan:** Menghitung total belanja, biaya ongkir (gratis ongkir untuk minimum belanja tertentu), dan riwayat pesanan[cite: 9, 10].

### 🛠️ Fitur Admin
* **Dashboard Admin:** Antarmuka khusus untuk manajemen toko.
* **Manajemen Produk (CRUD):** Mengunggah produk baru, mengedit detail (harga, stok, nama), dan menghapus produk[cite: 7, 11].
* **Manajemen Pesanan:** Melihat riwayat transaksi seluruh pelanggan secara *real-time*[cite: 9, 11].
* **Data Seeding:** Tombol "Upload produk awal" untuk memasukkan data *dummy* ke Firestore dengan 1 klik[cite: 10, 11].

---

## 🛠️ Teknologi yang Digunakan

* **Framework:** [Flutter](https://flutter.dev/)[cite: 3]
* **State Management:** [Provider](https://pub.dev/packages/provider) (`ClubwearProvider`)[cite: 3, 10]
* **Backend / Database:** [Firebase Cloud Firestore](https://firebase.google.com/docs/firestore)[cite: 7, 8, 9]
* **Autentikasi:** [Firebase Authentication](https://firebase.google.com/docs/auth)[cite: 8, 9, 11]

---

## ⚙️ Cara Kerja Aplikasi

Aplikasi menggunakan arsitektur MVVM (Model-View-ViewModel) yang dimodifikasi menggunakan Provider:
1. **State & Logika Bisnis:** Semua state seperti keranjang, daftar favorit, dan profil user dikelola di dalam `ClubwearProvider.dart`[cite: 10].
2. **Sinkronisasi Database (Real-time):**
    - Aplikasi menggunakan `ProductFirestoreService`, `CartFirestoreService`, dan `OrderFirestoreService` untuk berkomunikasi dengan Cloud Firestore[cite: 7, 8, 9, 10].
    - Data produk dan pesanan dimuat menggunakan `Stream` (real-time)[cite: 7, 8, 9]. Jika admin mengubah harga atau stok produk, perubahan langsung muncul di layar pembeli tanpa perlu *refresh*.
3. **Alur Checkout & Transaksi:**
   Saat pengguna menekan tombol "Checkout", sistem menjalankan *Firestore Transaction*. Sistem menyimpan data pesanan (`orders`) sekaligus **mengurangi stok** dan **menambah jumlah terjual (sold)** pada dokumen produk secara otomatis dan konsisten[cite: 7, 9, 10].
4. **Isolasi Data:** Data keranjang (`cartItems`) disimpan pada sub-koleksi (`users/{userId}/cartItems`) sehingga data keranjang milik pengguna satu tidak akan bercampur dengan pengguna lain dan tidak hilang saat aplikasi ditutup[cite: 8].

---

## 🔗 Cara Menghubungkan Aplikasi dengan Database (Firebase)

Untuk menjalankan proyek ini di lokal dengan database Firebase milikmu sendiri, ikuti langkah-langkah berikut:

### 1. Persiapan Project Firebase
1. Buka [Firebase Console](https://console.firebase.google.com/) dan buat **Project Baru**.
2. Masuk ke menu **Build > Authentication**, klik **Get Started**, dan aktifkan *Sign-in provider* **Email/Password**.
3. Masuk ke menu **Build > Firestore Database**, klik **Create Database**.
4. Atur *Security Rules* Firestore sementara ke **Test Mode** (agar bisa melakukan *Read/Write* tanpa error *permission denied*).

### 2. Konfigurasi FlutterFire CLI di Terminal
Aplikasi ini dihubungkan ke Firebase menggunakan file `firebase_options.dart` yang di-generate otomatis.
1. Buka terminal komputer, dan pastikan sudah login ke Firebase:
   ```bash
   firebase login
   