// Installer fitur pertemuan 09–13 untuk Clubwear.
//
// Menggunakan Dart bawaan Flutter/Android Studio; tidak memerlukan Python.
// Contoh dari terminal Android Studio (root repo):
// dart ../clubwear_p9_p13/tools/apply_pertemuan_09_13.dart --project . --dry-run
// dart ../clubwear_p9_p13/tools/apply_pertemuan_09_13.dart --project .
//
// File lama dibuatkan backup .bak_p9_13 saat diganti.
import 'dart:io';

String join(String a, String b) => '$a${Platform.pathSeparator}$b';

void ensure(bool condition, String message) {
  if (!condition) throw StateError(message);
}

String read(String path) =>
    File(path).readAsStringSync().replaceAll('\r\n', '\n');

void save(String path, String content, {required bool dryRun}) {
  final file = File(path);
  if (file.existsSync() && file.readAsStringSync() == content) {
    stdout.writeln('SAMA   $path');
    return;
  }
  stdout.writeln('UBAH   $path');
  if (dryRun) return;
  file.parent.createSync(recursive: true);
  if (file.existsSync()) {
    final backup = File('$path.bak_p9_13');
    if (!backup.existsSync()) file.copySync(backup.path);
  }
  file.writeAsStringSync(content);
}

String requireFile(String root, String relativePath) {
  final file = File(join(root, relativePath.replaceAll('/', Platform.pathSeparator)));
  ensure(file.existsSync(), 'File proyek tidak ditemukan: $relativePath');
  return file.path;
}

void main(List<String> args) {
  try {
    final dryRun = args.contains('--dry-run');
    var project = '.';
    final projectArg = args.indexOf('--project');
    if (projectArg >= 0) {
      ensure(projectArg + 1 < args.length,
          'Gunakan --project <folder>, contoh --project .');
      project = args[projectArg + 1];
    }
    final root = Directory(project).absolute.path;
    final packageRoot = File.fromUri(Platform.script).parent.parent.path;

    // Preflight: hindari pemasangan pada proyek atau versi file yang berbeda.
    requireFile(root, 'lib/providers/clubwear_provider.dart');
    final profilePath = requireFile(root, 'lib/pages/profile_page.dart');
    final pubspecPath = requireFile(root, 'pubspec.yaml');
    final manifestPath = requireFile(root, 'android/app/src/main/AndroidManifest.xml');
    final pubspec = read(pubspecPath);
    final profile = read(profilePath);
    final manifest = read(manifestPath);
    ensure(pubspec.contains('name: clubwear_app'),
        'Bukan paket clubwear_app; pemasangan dibatalkan.');
    ensure(pubspec.contains('  shared_preferences:'),
        'Dependency shared_preferences tidak ditemukan.');
    ensure(profile.contains('Future<void> showAddressDialog(BuildContext context)'),
        'Signature showAddressDialog berubah. Jangan menimpa otomatis.');
    ensure(profile.contains('//  DIALOG EDIT PROFIL'),
        'Penanda DIALOG EDIT PROFIL tidak ditemukan.');
    ensure(manifest.contains('    <application'),
        'AndroidManifest.xml tidak memiliki penanda <application.');
    ensure(profile.contains("import '../models/order.dart';") ||
        profile.contains("import '../features/shipping/presentation/shipping_address_page.dart';"),
        'Lokasi penyisipan import pada profile_page.dart berbeda.');
    ensure(pubspec.contains('  shared_preferences: ^2.3.2') ||
        (pubspec.contains('  http:') && pubspec.contains('  geolocator:')),
        'Versi shared_preferences berbeda; sesuaikan dependency secara manual.');

    // Persiapkan modifikasi terlebih dahulu agar kegagalan validasi tidak
    // menyebabkan perubahan sebagian file.
    final staged = <String, String>{};
    for (final folder in ['lib/features/shipping', 'test/features/shipping']) {
      final sourceRoot = Directory(join(packageRoot, folder.replaceAll('/', Platform.pathSeparator)));
      ensure(sourceRoot.existsSync(), 'Folder patch hilang: $folder');
      for (final entity in sourceRoot.listSync(recursive: true)) {
        if (entity is File) {
          final relative = entity.path.substring(packageRoot.length + 1);
          staged[join(root, relative)] = read(entity.path);
        }
      }
    }

    var newPubspec = pubspec;
    for (final entry in {'http': '^1.4.0', 'geolocator': '^13.0.4'}.entries) {
      if (!newPubspec.contains('  ${entry.key}:')) {
        const dependencyLine = '  shared_preferences: ^2.3.2';
        ensure(newPubspec.contains(dependencyLine),
            'Titik penyisipan dependency ${entry.key} tidak ditemukan.');
        newPubspec = newPubspec.replaceFirst(
            dependencyLine, '$dependencyLine\n  ${entry.key}: ${entry.value}');
      }
    }
    staged[pubspecPath] = newPubspec;

    var newProfile = profile;
    const importLine = "import '../features/shipping/presentation/shipping_address_page.dart';\n";
    if (!newProfile.contains(importLine)) {
      newProfile = newProfile.replaceFirst(
          "import '../models/order.dart';\n",
          "${importLine}import '../models/order.dart';\n");
    }
    const addressStart = 'Future<void> showAddressDialog(BuildContext context)';
    const nextSection = '// =====================================================================\n//  DIALOG EDIT PROFIL';
    final begin = newProfile.indexOf(addressStart);
    final end = newProfile.indexOf(nextSection, begin);
    ensure(begin >= 0 && end > begin,
        'Batas fungsi dialog alamat tidak cocok; tidak memasang patch.');
    const replacement = '''Future<void> showAddressDialog(BuildContext context) async {
  final initial = context.read<ClubwearProvider>().address;
  final saved = await Navigator.of(context).push<bool>(
    MaterialPageRoute<bool>(
      builder: (_) => ShippingAddressPage(initialAddress: initial),
    ),
  );
  if (saved == true && context.mounted) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Alamat pengiriman diperbarui.')));
  }
}

''';
    newProfile = newProfile.substring(0, begin) + replacement + newProfile.substring(end);
    newProfile = newProfile.replaceFirst(
        '//  DIALOG ALAMAT (dipakai juga oleh halaman keranjang)',
        '//  HALAMAN ALAMAT BARU (dipakai Profil dan Keranjang)');
    staged[profilePath] = newProfile;

    var newManifest = manifest;
    for (final permission in [
      '    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>',
      '    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>',
    ]) {
      if (!newManifest.contains(permission)) {
        newManifest = newManifest.replaceFirst('    <application', '$permission\n    <application');
      }
    }
    staged[manifestPath] = newManifest;

    final iosInfo = File(join(root, 'ios${Platform.pathSeparator}Runner${Platform.pathSeparator}Info.plist'));
    if (iosInfo.existsSync()) {
      var plist = read(iosInfo.path);
      if (!plist.contains('NSLocationWhenInUseUsageDescription')) {
        ensure(plist.contains('</dict>'), 'iOS Info.plist tidak memiliki </dict>.');
        plist = plist.replaceFirst('</dict>',
            '    <key>NSLocationWhenInUseUsageDescription</key>\n'
                '    <string>Lokasi digunakan hanya saat Anda memilih cek koordinat alamat pengiriman.</string>\n'
                '</dict>');
      }
      staged[iosInfo.path] = plist;
    }
    for (final file in ['README.md', 'PERUBAHAN_DAN_PENGUJIAN.md', 'PANDUAN_ANDROID_STUDIO.md']) {
      final source = File(join(packageRoot, file));
      ensure(source.existsSync(), 'File patch tidak tersedia: $file');
      staged[join(root, file)] = read(source.path);
    }

    for (final entry in staged.entries) {
      save(entry.key, entry.value, dryRun: dryRun);
    }
    stdout.writeln(dryRun
        ? '\nDRY RUN selesai: belum ada file proyek yang diubah.'
        : '\nPatch berhasil disalin. Jalankan flutter pub get, flutter analyze, flutter test.');
    stdout.writeln('Setelah itu jalankan aplikasi melalui tombol Run di Android Studio.');
  } catch (e) {
    stderr.writeln('GAGAL: $e');
    exitCode = 1;
  }
}
