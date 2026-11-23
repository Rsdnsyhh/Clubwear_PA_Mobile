# Clubwear — Aplikasi Mobile Katalog dan Pemesanan Pakaian

**Proyek Akhir Pemrograman Piranti Bergerak | Flutter & Dart | Android Studio**

[Repository proyek](https://github.com/Rsdnsyhh/Clubwear_PA_Mobile) · [Materi kuliah pertemuan 9–13](https://github.com/antonprafanto/mobile2026)

> **Status implementasi:** README ini menyatukan dokumentasi fitur Clubwear yang telah ada dengan rancangan integrasi materi pertemuan 9–13. Fitur baru di folder `lib/features/shipping/` tersedia dalam **paket perubahan terpisah** dan baru menjadi bagian proyek setelah paket dipasang. Pemasangan, kompilasi, dan seluruh pengujian pada Android Studio **belum dinyatakan berhasil** sampai dijalankan pada proyek dan perangkat pengembang. Jangan menyamakan kode yang disiapkan dengan fitur yang sudah dipublikasikan di GitHub.

## 1. Deskripsi proyek

**Clubwear** adalah aplikasi mobile katalog dan pemesanan pakaian pria yang dikembangkan menggunakan **Flutter** dengan bahasa pemrograman utama **Dart**. Aplikasi menyediakan pengalaman belanja bagi **pembeli** dan pengelolaan produk/pesanan bagi **admin**. Firebase Authentication digunakan untuk autentikasi, Cloud Firestore untuk data yang memerlukan penyimpanan cloud, serta penyimpanan lokal untuk sejumlah data di perangkat.

Pengembangan lanjutan menyesuaikan materi **pertemuan 09–13**: state management dan MVVM, proses asinkron dan REST API, penyimpanan lokal, Clean Architecture, serta fitur perangkat dan izin. Implementasi baru dipusatkan pada **halaman alamat pengiriman** supaya tidak perlu mengganti alur login, keranjang, checkout, atau dashboard admin yang sudah ada.

### Tujuan

- Menampilkan produk dan informasi belanja melalui antarmuka mobile.
- Mendukung proses pemilihan produk, favorit, keranjang, alamat, checkout, dan riwayat pesanan.
- Menyediakan fungsi pengelolaan produk, stok, dan pesanan untuk admin.
- Menerapkan konsep Flutter/Dart secara bertahap pada fitur nyata.
- Mendokumentasikan materi yang diterapkan, belum diterapkan, dan alasan teknisnya.

## 2. Teknologi yang digunakan

| Komponen | Teknologi | Kegunaan |
| --- | --- | --- |
| Bahasa utama | **Dart** | Logika aplikasi, model, state, integrasi API, dan fitur perangkat |
| Framework | **Flutter** | UI, widget, navigasi, dan build aplikasi Android |
| IDE | **Android Studio** | Menulis kode, menjalankan emulator, debugging, dan build |
| State management yang sudah ada | `provider`, `ChangeNotifier` | Mengelola state aplikasi melalui `ClubwearProvider` |
| State fitur alamat baru | `AddressViewModel` (`ChangeNotifier`) | Memisahkan tampilan dari loading, error, provinsi, dan GPS |
| Autentikasi | Firebase Authentication | Daftar, login, dan sesi pengguna |
| Basis data cloud | Cloud Firestore | Data katalog, keranjang, dan pesanan menurut implementasi proyek |
| Penyimpanan lokal | `sqflite`, `shared_preferences` | Favorit, alamat, salinan riwayat lokal, dan fallback tertentu |
| REST API baru | `http` | Mengambil daftar provinsi dari API publik |
| Cache API baru | `SharedPreferencesAsync` | Menyimpan hasil API provinsi untuk fallback offline |
| GPS baru | `geolocator` | Membaca koordinat setelah pengguna meminta izin |

**Catatan:** Firebase tidak diganti dengan REST API; keduanya memiliki tujuan berbeda.

## 3. Fitur aplikasi

### 3.1 Pembeli

- Registrasi dan login pengguna.
- Melihat katalog, kategori, serta detail produk.
- Memilih variasi/ukuran produk sesuai data yang tersedia.
- Menyimpan produk favorit.
- Menambahkan dan mengelola produk dalam keranjang.
- Mengisi alamat pengiriman.
- Melakukan checkout dan melihat riwayat pesanan.
- **Tambahan setelah patch:** pilihan provinsi dari REST API, cache provinsi, validasi alamat, dan tombol untuk membaca lokasi GPS.

### 3.2 Admin

- Mengakses tampilan admin sesuai mekanisme akun/role yang telah disediakan aplikasi.
- Melihat dan mengelola katalog serta ketersediaan stok.
- Memantau atau mengelola pesanan sesuai fitur admin pada kode proyek.
- Mengisi data produk awal (*seeding*) apabila alurnya tersedia dan dikonfigurasi.

> **Catatan keamanan:** tampilan admin saja bukan mekanisme otorisasi yang memadai. Akses tulis/baca di Firestore tetap harus dibatasi dengan **Firestore Security Rules** dan peran tepercaya dari backend.

### 3.3 Ketentuan belanja pada implementasi yang ditinjau

- Biaya pengiriman tetap: **Rp20.000**.
- Gratis pengiriman saat subtotal mencapai **Rp500.000**.
- Pemilihan provinsi dari API **tidak otomatis menghitung ongkir** atau menentukan jangkauan ekspedisi.

Nilai dan aturan ongkir di atas mengikuti kode yang ditinjau pada tahap sebelumnya; apabila aturan bisnis diubah, perbarui kode beserta bagian README ini.

## 4. Alur pengguna

**Pembeli:** buka aplikasi → login/daftar → lihat katalog → pilih produk/ukuran → tambahkan ke keranjang → isi alamat pengiriman → checkout → lihat riwayat pesanan.

**Admin:** login → masuk ke halaman administrasi → kelola produk/stok → tinjau pesanan.

**Fitur alamat baru:** buka Profil atau Keranjang → buka Alamat Pengiriman → masukkan alamat lengkap → pilih provinsi bila tersedia → opsional cek koordinat GPS → simpan alamat melalui `ClubwearProvider`.

Alamat lengkap tetap harus diketik: **koordinat GPS bukan pengganti nama jalan, nomor rumah, RT/RW, atau keterangan pengiriman**.

## 5. Integrasi materi pertemuan 09–13

| Pertemuan | Materi utama | Lokasi implementasi | Status |
| --- | --- | --- | --- |
| **09 — State Management & MVVM** | `Provider`, `ChangeNotifier`, `notifyListeners`, pemisahan View–ViewModel, status loading/error | `lib/providers/clubwear_provider.dart` (sudah ada); `lib/features/shipping/presentation/address_view_model.dart` (baru) | **Ada + perluasan setelah patch** |
| **10 — Async & REST API** | `Future`, `async`/`await`, `http.get`, JSON parsing, HTTP error, timeout | `lib/features/shipping/data/http_province_repository.dart` (baru) | **Setelah patch** |
| **11 — Penyimpanan Lokal** | SQLite/CRUD, SharedPreferences, cache offline | `lib/services/local_db_service.dart` (sudah ada); `SharedPrefsProvinceCache` (baru) | **Ada + perluasan setelah patch** |
| **12 — Clean Architecture** | Pemisahan `domain`, `data`, `presentation`, repository interface | `lib/features/shipping/` (baru) | **Diterapkan bertahap setelah patch** |
| **13 — Fitur Perangkat & Izin** | GPS, pemeriksaan layanan lokasi, izin *when-in-use*, penanganan penolakan | `geolocator_location_gateway.dart`, UI alamat, manifest Android (baru) | **Setelah patch** |

### 5.1 Pertemuan 09 — State Management dan MVVM

State aplikasi yang telah ada dikelola oleh `ClubwearProvider`. Pada fitur alamat baru, digunakan `AddressViewModel extends ChangeNotifier` untuk menyimpan:

- `isLoading` dan `error` saat mengambil daftar provinsi;
- `provinces`, `selectedProvinceId`, dan `fromCache`;
- `isLocating`, `coordinates`, dan `locationError` ketika meminta lokasi.

**View** (`shipping_address_page.dart`) menangani widget, input, tombol, dan navigasi. **ViewModel** menangani perubahan state asinkron. **Repository/Gateway** menangani akses HTTP atau lokasi. Pemisahan ini mempermudah pengujian tanpa harus membuka UI.

### 5.2 Pertemuan 10 — Async dan REST API

Digunakan **API Wilayah Indonesia v2 (emsifa)** untuk daftar provinsi:

```http
GET https://www.emsifa.com/api-wilayah-indonesia/v2/provinces.json
Accept: application/json
```

Contoh struktur respons (dipersingkat):

```json
{
  "data": [
    { "id": "11", "name": "Aceh" },
    { "id": "12", "name": "Sumatera Utara" }
  ],
  "meta": { "level": 1 }
}
```

Alur: `ShippingAddressPage` memanggil ViewModel → ViewModel memanggil `ProvinceRepository` → `HttpProvinceRepository` mengirim HTTP GET → respons diparsing menjadi `Province` → `notifyListeners()` memperbarui UI. Permintaan dibatasi **12 detik**; respons gagal atau format JSON salah ditangani dengan fallback cache. Jika cache juga tidak ada, pengguna tetap dapat mengisi alamat manual.

Sumber API: https://www.emsifa.com/api-wilayah-indonesia/ dan https://github.com/emsifa/api-wilayah-indonesia. API ini hanya dipakai sebagai **referensi nama provinsi**; bukan sistem ongkir atau validasi alamat.

### 5.3 Pertemuan 11 — Penyimpanan lokal

Penyimpanan lokal lama melalui `LocalDbService` tetap dipertahankan. Pada fitur tambahan, hasil sukses REST API disimpan sebagai JSON dengan `SharedPreferencesAsync` memakai key `shipping_provinces_v2_json`. Saat API gagal, aplikasi mencoba membaca cache tersebut.

Cache bersifat **best effort**: tidak menjamin data selalu paling mutakhir dan baru tersedia setelah permintaan sukses setidaknya sekali. Tidak dibuat tabel SQLite tambahan untuk provinsi karena daftar referensinya relatif kecil.

### 5.4 Pertemuan 12 — Clean Architecture

Penerapan dimulai dari **fitur alamat**, bukan refaktor total proyek:

```text
lib/features/shipping/
├── domain/
│   ├── province.dart                  # Entity/model Province, ProvinceResult
│   ├── address_rules.dart             # Aturan validasi dan komposisi alamat
│   └── shipping_gateways.dart         # Kontrak ProvinceRepository & LocationGateway
├── data/
│   ├── http_province_repository.dart  # HTTP, parsing JSON, cache
│   └── geolocator_location_gateway.dart # Akses GPS dan izin lokasi
└── presentation/
    ├── address_view_model.dart        # State dan logika fitur alamat
    └── shipping_address_page.dart     # Widget, form, navigasi
```

**Domain** tidak bergantung pada Flutter atau plugin perangkat. **Data** mengimplementasikan kontrak dari domain. **Presentation** menggunakan ViewModel dan komponen UI. Penyimpanan akhir alamat masih memanfaatkan `ClubwearProvider.setAddress()` yang sudah ada, sehingga integrasi ini merupakan **Clean Architecture parsial**, bukan klaim bahwa seluruh proyek sudah direfaktor.

### 5.5 Pertemuan 13 — Fitur perangkat dan izin

Saat tombol **Ambil lokasi saat ini** ditekan, aplikasi:

1. Memeriksa apakah layanan lokasi perangkat aktif.
2. Memeriksa status izin dan meminta izin bila diperlukan.
3. Membaca koordinat menggunakan `Geolocator.getCurrentPosition` jika diizinkan.
4. Menampilkan latitude/longitude dan opsi menyalin koordinat.
5. Menampilkan pesan jika izin ditolak, lokasi tidak aktif, atau pengambilan data gagal.

GPS **tidak dibaca saat aplikasi baru dibuka**. Koordinat **tidak otomatis disimpan** ke database atau digabungkan ke alamat; pengguna dapat menyalinnya jika diperlukan. Android menggunakan `ACCESS_COARSE_LOCATION` dan `ACCESS_FINE_LOCATION`; iOS, bila digunakan, membutuhkan `NSLocationWhenInUseUsageDescription`.

## 6. Materi yang tidak diterapkan dan alasannya

| Materi/contoh | Keputusan dan alasan |
| --- | --- |
| REST `POST`, `PUT`, `DELETE` untuk produk dan pesanan | **Tidak ditambah.** Produk/pesanan telah memakai Firestore SDK; menambah backend CRUD kedua tanpa kebutuhan jelas berpotensi menyebabkan data ganda dan konflik stok. |
| Mengganti login Firebase dengan REST eksternal | **Tidak dilakukan.** API provinsi hanya menyajikan data referensi, bukan layanan autentikasi. |
| Refaktor Clean Architecture seluruh aplikasi sekaligus | **Belum dilakukan.** Risiko perubahan terlalu luas pada login, katalog, checkout, dan admin. Fitur alamat dijadikan implementasi bertahap. |
| Menambah tabel SQLite khusus daftar provinsi | **Tidak diperlukan.** JSON cache di `SharedPreferencesAsync` cukup untuk daftar referensi ini dan menghindari migrasi database. |
| Kamera/galeri untuk unggah produk | **Belum diterapkan.** Alur unggah gambar persisten ke storage, URL produk, dan pengamanan unggahan belum disiapkan dalam paket integrasi. Izin kamera tidak diminta tanpa fitur yang membutuhkannya. |
| Mikrofon, kontak, dan notifikasi | **Tidak diterapkan.** Belum ada kebutuhan aplikasi yang menggunakan data/perangkat tersebut. |
| GPS latar belakang, pelacakan kontinu, geofencing | **Tidak diterapkan.** Aplikasi belanja hanya memerlukan pembacaan lokasi satu kali atas permintaan pengguna, sehingga izin background location tidak relevan. |
| Konversi koordinat GPS otomatis menjadi alamat jalan | **Belum diterapkan.** Fitur yang disediakan hanya membaca koordinat, bukan geocoding/reverse-geocoding; alamat tekstual tetap diisi manual. |

**Prinsip:** materi dipilih berdasarkan kebutuhan nyata proyek. Tidak semua contoh perkuliahan harus ditambahkan apabila menciptakan izin berlebihan, fungsi tanpa manfaat, atau sumber data yang saling bertentangan.

## 7. Arsitektur aplikasi dan alur data

```text
Aplikasi Flutter (Dart)
│
├── UI lama: pages / widgets
│   └── ClubwearProvider (Provider / ChangeNotifier)
│       ├── Firebase Authentication
│       ├── Cloud Firestore
│       └── LocalDbService → SQLite / SharedPreferences
│
└── UI baru: ShippingAddressPage
    └── AddressViewModel (ChangeNotifier)
        ├── ProvinceRepository (interface/domain)
        │   └── HttpProvinceRepository → REST API emsifa
        │                              → SharedPreferencesAsync (cache)
        └── LocationGateway (interface/domain)
            └── GeolocatorLocationGateway → Location Services / GPS

Simpan alamat → ClubwearProvider.setAddress() → penyimpanan lokal existing
```

### Struktur proyek yang relevan

```text
Clubwear_PA_Mobile/
├── android/
│   └── app/src/main/AndroidManifest.xml
├── ios/Runner/Info.plist
├── lib/
│   ├── main.dart
│   ├── models/                       # Model existing
│   ├── pages/
│   │   └── profile_page.dart         # Titik navigasi ke halaman alamat baru
│   ├── providers/
│   │   └── clubwear_provider.dart    # Provider existing
│   ├── services/
│   │   └── local_db_service.dart     # Penyimpanan lokal existing
│   ├── widgets/
│   │   └── common_widgets.dart
│   └── features/shipping/            # BARU, ditambahkan melalui patch
│       ├── domain/
│       ├── data/
│       └── presentation/
├── test/
│   └── features/shipping/            # BARU, pengujian unit
├── pubspec.yaml
├── README.md
├── PERUBAHAN_DAN_PENGUJIAN.md        # BARU dari paket perubahan
└── PANDUAN_ANDROID_STUDIO.md         # BARU dari paket perubahan
```

Struktur di atas **ringkasan direktori yang relevan**, bukan daftar seluruh file aplikasi.

## 8. Lokasi dan karakter penyimpanan data

| Data | Penyimpanan | Keterangan |
| --- | --- | --- |
| Akun/sesi pengguna | Firebase Authentication | Bergantung pada konfigurasi Firebase |
| Produk dan stok | Cloud Firestore | Data online utama aplikasi |
| Keranjang | Firestore, termasuk subkoleksi `users/{uid}/cartItems` pada implementasi yang ditinjau | Tidak disamakan dengan cache lokal |
| Pesanan | Firestore, dengan pencatatan riwayat lokal pada alur yang telah ada | Konsistensi perlu diuji ketika jaringan gagal |
| Favorit | SQLite untuk target yang didukung, fallback SharedPreferences pada platform tertentu | Bersifat lokal perangkat dan dipisahkan menurut UID |
| Alamat pengguna | SQLite untuk target yang didukung, fallback SharedPreferences pada platform tertentu | Tidak otomatis tersinkron antargawai |
| Daftar provinsi dari API | `SharedPreferencesAsync` | Cache untuk mode offline setelah respons sukses |
| Koordinat GPS | Memori ViewModel/UI | Tidak tersimpan permanen secara otomatis |

**Privasi:** jangan menyimpan token Firebase, password, atau informasi sensitif pengguna ke README, repositori publik, ataupun log debugging. Hindari menyimpan koordinat tanpa persetujuan dan kebutuhan yang jelas.

## 9. Persiapan Android Studio

### 9.1 Prasyarat

- **Android Studio** beserta plugin **Flutter** dan **Dart**.
- **Flutter SDK** dan Dart SDK dari instalasi Flutter (sesuai batas versi SDK pada `pubspec.yaml`, yang ditinjau menggunakan Dart `^3.5.0`).
- Android SDK, Android Emulator atau HP Android dengan **USB debugging** aktif.
- Akses jaringan internet untuk `flutter pub get`, Firebase, serta API provinsi.
- Proyek Firebase dengan **Email/Password Authentication** dan **Cloud Firestore** yang dikonfigurasi sesuai aplikasi.
- Git (disarankan untuk menyimpan perubahan ke repository).

### 9.2 Buka proyek

1. Unduh/klon repository Clubwear:

   ```powershell
   git clone https://github.com/Rsdnsyhh/Clubwear_PA_Mobile.git
   ```

2. Buka **Android Studio → Open**, pilih **folder root `Clubwear_PA_Mobile` yang berisi `pubspec.yaml`**, bukan folder `android` saja.
3. Buka **View → Tool Windows → Terminal** (atau tab **Terminal** di bawah Android Studio).
4. Pastikan perangkat terdeteksi dan environment siap:

   ```powershell
   flutter doctor
   flutter devices
   ```

5. Jalankan `flutter pub get` bila dependensi belum diunduh.

### 9.3 Konfigurasi Firebase

- Pastikan file konfigurasi Firebase yang diperlukan proyek tersedia dan sesuai **package name/application ID** Android yang digunakan.
- Aktifkan **Authentication → Sign-in method → Email/Password** di Firebase Console.
- Siapkan **Cloud Firestore** dan aturan keamanan akses yang sesuai kebutuhan pembeli/admin.
- Jika beralih ke proyek Firebase baru, konfigurasikan kembali melalui `flutterfire configure` sesuai FlutterFire CLI dan pastikan referensi konfigurasi aplikasi ikut diperbarui.
- **Jangan mengandalkan Firestore Test Mode** untuk distribusi publik dan jangan mengunggah rahasia kredensial servis.

## 10. Memasang kode pertemuan 09–13

> Bagian ini dibutuhkan **hanya jika fitur baru belum ada pada repository lokal**. Jangan menjalankan installer dua kali pada salinan lain tanpa memeriksa `git diff`. Installer melakukan pemeriksaan struktur dan bisa menolak versi proyek yang berbeda untuk mencegah perubahan salah.

### 10.1 Siapkan folder

Ekstrak ZIP integrasi sehingga folder paket dan proyek berdampingan:

```text
D:\Kuliah\
├── Clubwear_PA_Mobile\       ← dibuka di Android Studio
└── clubwear_p9_p13\         ← folder dari ZIP integrasi
```

### 10.2 Buat branch perubahan

Dari terminal Android Studio di root proyek:

```powershell
git status
git switch -c feat/pertemuan-09-13
```

Jika branch dengan nama yang sama sudah ada, gunakan nama lain atau checkout branch tersebut. Pastikan pekerjaan sebelumnya telah disimpan.

### 10.3 Periksa perubahan tanpa memodifikasi file

```powershell
dart ..\clubwear_p9_p13\tools\apply_pertemuan_09_13.dart --project . --dry-run
```

Bila pemeriksaan berhasil dan lokasi folder sudah benar, pasang patch:

```powershell
dart ..\clubwear_p9_p13\tools\apply_pertemuan_09_13.dart --project .
```

Installer melakukan backup file lama yang diganti dalam bentuk `*.bak_p9_13`. **File backup tidak untuk diunggah ke GitHub.** Jika installer menghasilkan `GAGAL`, hentikan pemasangan dan periksa pesan kesalahan; jangan memaksakan penggantian file manual tanpa membandingkan source.

### 10.4 Sinkronkan, analisis, dan jalankan

```powershell
flutter pub get
dart format lib/features/shipping test/features/shipping lib/pages/profile_page.dart
flutter analyze
flutter test
```

Kemudian pada toolbar Android Studio, pilih emulator/HP dan klik **Run ▶**, atau gunakan:

```powershell
flutter run
```

**Status uji:** langkah di atas wajib dijalankan pengguna; paket belum memiliki bukti kelulusan `flutter analyze`, `flutter test`, atau build aktual pada komputer pengguna.

## 11. Apa yang ditambah, diubah, dan dipertahankan?

| Jenis | Berkas/komponen | Perubahan |
| --- | --- | --- |
| **Tambah** | `lib/features/shipping/domain/` | Model provinsi, validasi, dan interface repository/gateway |
| **Tambah** | `lib/features/shipping/data/` | HTTP provinsi + cache lokal serta pembacaan GPS |
| **Tambah** | `lib/features/shipping/presentation/` | `AddressViewModel` dan halaman alamat pengiriman |
| **Tambah** | `test/features/shipping/` | Tes validasi alamat, repository, cache dan state ViewModel |
| **Ubah** | `lib/pages/profile_page.dart` | `showAddressDialog` diarahkan ke halaman alamat baru; dialog alamat lama diganti |
| **Ubah** | `pubspec.yaml` | Dependensi `http` dan `geolocator` ditambahkan; `shared_preferences` lama dipertahankan |
| **Ubah** | `android/app/src/main/AndroidManifest.xml` | Izin lokasi *coarse* dan *fine* |
| **Ubah bila tersedia** | `ios/Runner/Info.plist` | Deskripsi izin lokasi ketika aplikasi digunakan |
| **Ubah** | `README.md` | Gabungan dokumentasi proyek dan materi pertemuan 09–13 |
| **Tambah** | `PERUBAHAN_DAN_PENGUJIAN.md`, `PANDUAN_ANDROID_STUDIO.md` | Catatan perubahan dan instruksi khusus IDE |
| **Dipertahankan** | Firebase Auth, Firestore, `ClubwearProvider`, `LocalDbService`, katalog, keranjang, checkout, admin | Tidak diganti dalam paket perubahan |

Yang **dikurangi/diganti** hanya antarmuka dialog alamat lama agar tidak ada dua tempat mengedit alamat. **Tidak ada instruksi untuk menghapus fitur lama atau mengganti seluruh database.**

## 12. Cara menggunakan fitur alamat baru

1. Jalankan aplikasi dan login sebagai pembeli.
2. Buka **Profil → Alamat Pengiriman** atau akses alamat dari **Keranjang** jika tombolnya tersedia.
3. Isi alamat lengkap minimal **10** dan maksimal **500** karakter.
4. Pilih provinsi dari daftar yang dimuat API (opsional). Jika nama provinsi telah ada di alamat, fungsi komposisi tidak menambahkannya lagi.
5. Bila diperlukan, tekan **Ambil lokasi saat ini** dan izinkan akses lokasi; koordinat muncul agar dapat disalin.
6. Klik **Simpan Alamat**. Penyimpanan ditangani provider/local storage yang sudah digunakan proyek.
7. Tutup dan buka kembali aplikasi untuk memastikan alamat tersimpan bagi akun yang sama.

Jika API tidak tersedia dan cache masih kosong, form **tetap dapat digunakan** karena provinsi bukan field wajib. Izin GPS yang ditolak juga tidak menghalangi pengguna menyimpan alamat manual.

## 13. Pengujian dan kriteria keberhasilan

### 13.1 Pemeriksaan kode

```powershell
flutter doctor
flutter pub get
flutter analyze
flutter test
```

File pengujian baru:

```text
test/features/shipping/
├── address_rules_test.dart
├── province_repository_test.dart
└── address_view_model_test.dart
```

### 13.2 Pengujian manual

| Pengujian | Hasil yang diharapkan |
| --- | --- |
| Login/register pembeli | Berfungsi seperti sebelum pembaruan |
| Katalog, pencarian/kategori dan detail produk | Produk tetap tampil sesuai data yang tersedia |
| Favorit dan keranjang | Data dan navigasi tidak terganggu |
| Buka halaman alamat dengan internet | Daftar provinsi tersedia dari API |
| Buka ulang halaman setelah sukses, lalu putus internet | Provinsi diambil dari cache bila tersedia |
| Offline sejak pertama kali tanpa cache | Pesan gagal muncul, tetapi input manual tetap aktif |
| Alamat kurang dari 10 karakter atau lebih dari 500 | Form menolak penyimpanan |
| Nama provinsi sudah tercantum di alamat | Tidak diduplikasi oleh fungsi komposisi |
| Lokasi perangkat aktif + izin diberikan | Koordinat tampil dan dapat disalin |
| GPS dimatikan / izin ditolak | Tampil pesan kesalahan; input alamat manual tetap aktif |
| Alamat disimpan dan aplikasi dibuka ulang | Alamat tersedia sesuai mekanisme penyimpanan existing |
| Checkout dan riwayat pesanan | Perilaku lama harus tetap berfungsi, termasuk saat koneksi bermasalah |
| Admin mengelola stok dan pesanan | Fitur lama tidak rusak akibat patch |

**Jangan menulis semua tes “lulus” di laporan sebelum benar-benar dijalankan di Android Studio/perangkat.** Simpan screenshot hasil build, tampilan aplikasi, console test, dan bukti fitur untuk pelaporan PA.

## 14. Membangun APK Android

Setelah analisis dan pengujian selesai, jalankan:

```powershell
flutter build apk --debug
```

Untuk APK release lokal:

```powershell
flutter build apk --release
```

Flutter biasanya menghasilkan file APK di folder `build/app/outputs/flutter-apk/`. **APK release untuk distribusi** masih memerlukan pemeriksaan konfigurasi penandatanganan, keamanan Firebase, izin, dan uji pada perangkat sebenarnya. File APK tidak perlu dimasukkan ke commit source code kecuali diminta oleh ketentuan pengumpulan.

## 15. Kendala umum di Android Studio

| Kendala | Langkah pemeriksaan |
| --- | --- |
| `dart` atau `flutter` tidak dikenali | Periksa Flutter SDK dan PATH; jalankan `flutter doctor` |
| Proyek tidak muncul sebagai Flutter | Buka folder yang memiliki `pubspec.yaml`; pastikan plugin Flutter/Dart aktif |
| `flutter pub get` gagal | Periksa koneksi, konflik versi package, dan batas SDK dalam `pubspec.yaml` |
| Installer menampilkan `GAGAL` | Bandingkan struktur/source proyek; jangan paksa bila signature atau marker kode berubah |
| `Target of URI doesn't exist` | Pastikan installer menyalin semua `lib/features/shipping/` dan jalankan `flutter pub get` |
| Daftar provinsi tidak tampil | Periksa internet, akses endpoint API, dan apakah cache sudah pernah terisi |
| GPS gagal | Nyalakan Location perangkat, periksa izin aplikasi, atur lokasi simulasi emulator |
| Firebase gagal terhubung | Periksa konfigurasi aplikasi, package name, Auth, Firestore, dan Security Rules |
| Build gagal setelah penambahan plugin | Catat error paling awal dari panel Run/Build dan cek kompatibilitas Android SDK/Gradle |

## 16. Batasan teknis dan catatan keamanan

1. **Checkout belum dipastikan atomik.** Dari pemeriksaan tahap sebelumnya, penyimpanan pesanan dan pembaruan stok melibatkan beberapa operasi Firestore. Jika ada kegagalan di tengah proses, konsistensi stok/pesanan perlu ditinjau. Perbaikan melalui transaksi yang tepat atau backend tepercaya **belum termasuk patch**.
2. **Otorisasi admin perlu diperiksa di server.** Pemeriksaan email/role yang hanya dilakukan pada aplikasi tidak cukup; gunakan Firestore Security Rules dan identitas/peran yang tidak bisa dimanipulasi klien.
3. **Data lokal tidak otomatis sinkron antargawai.** Favorit dan alamat lokal perlu mekanisme sinkronisasi tambahan jika pengguna harus berpindah perangkat.
4. **API eksternal dapat berubah atau gagal.** Cache dan input manual dipakai untuk mengurangi dampaknya; daftar provinsi bukan verifikasi alamat.
5. **Lokasi tidak permanen.** Koordinat dari GPS bersifat perkiraan, tidak otomatis tersimpan, dan tidak menjadi bukti alamat kirim yang valid.
6. **Status integrasi belum final.** Instalasi, tes unit, analisis statis, pengujian regresi, dan build harus diverifikasi pada repository asli.

## 17. Menyimpan perubahan ke GitHub

Setelah kode berhasil berjalan, tinjau perubahan:

```powershell
git status --short
git diff
```

Jangan sertakan file `.bak_p9_13`, data pribadi, kunci rahasia, atau output build lokal. Tambahkan file yang relevan:

```powershell
git add README.md pubspec.yaml pubspec.lock lib/features/shipping lib/pages/profile_page.dart android/app/src/main/AndroidManifest.xml test/features/shipping PERUBAHAN_DAN_PENGUJIAN.md PANDUAN_ANDROID_STUDIO.md
```

Jika `ios/Runner/Info.plist` ikut berubah dan ingin dicatat, tambahkan secara terpisah:

```powershell
git add ios/Runner/Info.plist
```

Kemudian buat commit dan unggah branch pengembangan:

```powershell
git commit -m "feat: integrasi pertemuan 09-13 dan perbarui README Clubwear"
git push -u origin feat/pertemuan-09-13
```

Bila tidak menggunakan branch tersebut, sesuaikan nama branch. Perubahan bisa digabung ke `main` setelah ditinjau dan diuji.

## 18. Referensi pembelajaran

- [Pertemuan 09 — State dan MVVM](https://github.com/antonprafanto/mobile2026/tree/main/pertemuan_09_state_dan_mvvm)
- [Pertemuan 10 — Async dan REST API](https://github.com/antonprafanto/mobile2026/tree/main/pertemuan_10_async_dan_rest_api)
- [Pertemuan 11 — Penyimpanan Lokal](https://github.com/antonprafanto/mobile2026/tree/main/pertemuan_11_penyimpanan_lokal)
- [Pertemuan 12 — Clean Architecture](https://github.com/antonprafanto/mobile2026/tree/main/pertemuan_12_clean_architecture)
- [Pertemuan 13 — Fitur Perangkat dan Izin](https://github.com/antonprafanto/mobile2026/tree/main/pertemuan_13_fitur_perangkat_dan_izin)
- [Dokumentasi Flutter](https://docs.flutter.dev/)
- [Dokumentasi Dart](https://dart.dev/guides)
- [Dokumentasi Firebase untuk Flutter](https://firebase.google.com/docs/flutter/setup)
- [API Wilayah Indonesia](https://www.emsifa.com/api-wilayah-indonesia/)

## 19. Ringkasan perkembangan proyek

| Bagian | Kondisi yang didokumentasikan |
| --- | --- |
| Aplikasi utama Clubwear | Fitur pembeli/admin dan integrasi Firebase sudah ada pada kode yang sebelumnya ditinjau |
| Pertemuan 09 | Provider existing + MVVM fitur alamat dalam patch |
| Pertemuan 10 | REST GET provinsi + error/timeout dalam patch |
| Pertemuan 11 | Penyimpanan lokal existing + cache provinsi dalam patch |
| Pertemuan 12 | Clean Architecture secara bertahap khusus modul alamat dalam patch |
| Pertemuan 13 | GPS dengan izin sesuai kebutuhan dalam patch |
| Materi yang tidak dipakai | Dicatat dengan alasan di bagian 6 |
| Android Studio | Panduan pemasangan, Run, tes, dan build tersedia |
| Verifikasi akhir | **Menunggu pengujian pada proyek asli dan perangkat target** |

---

**Clubwear PA Mobile** — Dokumentasi proyek Flutter/Dart untuk pengembangan dan evaluasi materi pertemuan 09–13. README ini perlu diperbarui lagi berdasarkan hasil pengujian sebenarnya dan perubahan source code berikutnya.
