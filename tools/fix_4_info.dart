// Perbaikan 4 pesan info flutter analyze pada proyek Clubwear.
// Jalankan dari root proyek di Android Studio:
// dart path/ke/fix_4_info.dart --dry-run
// dart path/ke/fix_4_info.dart
// File asli dicadangkan dengan ekstensi .bak_fix_4_info.
import 'dart:io';

String norm(String s) => s.replaceAll('\r\n', '\n');

class Target {
  final String path;
  final int line;
  const Target(this.path, this.line);
}

String fixDropdown(String original, String path, int targetLine) {
  final lines = norm(original).split('\n');
  final matches = <int>[];
  for (var i = 0; i < lines.length; i++) {
    if (!RegExp(r'^\s*value\s*:').hasMatch(lines[i])) continue;
    if ((i + 1 - targetLine).abs() > 12) continue;
    final start = i - 25 < 0 ? 0 : i - 25;
    final prefix = lines.sublist(start, i).join('\n');
    if (prefix.contains('DropdownButtonFormField')) matches.add(i);
  }
  if (matches.length != 1) {
    throw StateError(
      '$path: baris DropdownButtonFormField(value:) tidak unik/dekat '
      'baris $targetLine. Tidak mengubah file.',
    );
  }
  final i = matches.single;
  lines[i] = lines[i].replaceFirst(RegExp(r'\bvalue\s*:'), 'initialValue:');
  stdout.writeln('  value -> initialValue pada baris ${i + 1}');
  return lines.join('\n');
}

String fixInstaller(String original) {
  final lines = norm(original).split('\n');
  var changed = false;
  for (var i = 0; i < lines.length; i++) {
    if (lines[i].startsWith('import ')) break;
    if (lines[i].startsWith('///')) {
      lines[i] = lines[i].replaceFirst('///', '//');
      changed = true;
    }
  }
  if (!changed) {
    if (!lines.take(12).any((line) => line.startsWith('//'))) {
      throw StateError('tools/apply_pertemuan_09_13.dart: header tidak dikenali');
    }
    stdout.writeln('  Komentar installer sudah diperbaiki');
  } else {
    stdout.writeln('  /// -> // pada komentar awal installer');
  }
  return lines.join('\n');
}

String fixAdmin(String original) {
  final lines = norm(original).split('\n');
  // Informasi lint menyebut context pada baris 62. Cari sempit agar tidak
  // menambah guard ke fungsi lain secara tidak sengaja.
  final start = 62 - 1 - 8 < 0 ? 0 : 62 - 1 - 8;
  final end = 62 + 8 > lines.length ? lines.length : 62 + 8;
  final candidates = <int>[];
  for (var i = start; i < end; i++) {
    if (RegExp(r'\bcontext\b').hasMatch(lines[i]) &&
        !lines[i].trimLeft().startsWith('//')) {
      candidates.add(i);
    }
  }
  if (candidates.isEmpty) {
    throw StateError('admin_dashboard_page.dart: tidak ditemukan context dekat baris 62');
  }
  candidates.sort((a, b) => (a - 61).abs().compareTo((b - 61).abs()));
  final contextLine = candidates.first;
  // Temukan pemanggilan fungsi UI yang menggunakan context. Untuk context
  // yang berada di baris argumen (mis. Navigator.push(context, ...)),
  // sisipkan guard sebelum seluruh pemanggilan, bukan di tengah argumen.
  var statementStart = -1;
  for (var i = contextLine; i >= 0 && i >= contextLine - 7; i--) {
    if (RegExp(r'\b(Navigator|ScaffoldMessenger|showDialog|showModalBottomSheet)\b')
        .hasMatch(lines[i])) {
      statementStart = i;
      break;
    }
  }
  if (statementStart == -1) {
    // Jika context dipakai dalam ekspresi lengkap pada satu baris, guard
    // bisa ditempatkan langsung di atasnya.
    final trimmed = lines[contextLine].trimLeft();
    if (RegExp(r'^(if\s*\(|return\b|context\.|await\b)')
        .hasMatch(trimmed)) {
      statementStart = contextLine;
    }
  }
  if (statementStart < 0) {
    throw StateError(
      'admin_dashboard_page.dart: bentuk pemakaian context belum dikenali. '
      'Tidak mengubah file; buka baris 50–65 untuk perbaikan manual.',
    );
  }
  // Verifikasi ada await di area terdekat dan belum ada guard.
  final before = lines.sublist(
    statementStart - 35 < 0 ? 0 : statementStart - 35,
    statementStart,
  ).join('\n');
  if (!RegExp(r'\bawait\b').hasMatch(before)) {
    throw StateError('admin_dashboard_page.dart: await di sekitar context tidak ditemukan');
  }
  if (RegExp(r'if\s*\(\s*!\s*(context\.)?mounted\s*\)')
      .hasMatch(lines.sublist(
        statementStart - 8 < 0 ? 0 : statementStart - 8,
        statementStart,
      ).join('\n'))) {
    stdout.writeln('  Guard mounted sudah ada');
    return lines.join('\n');
  }
  // Sisipan aman hanya bila pemanggilan berada pada baris yang bisa memulai
  // sebuah statement; jangan menyisipkan guard di tengah expression.
  final anchor = lines[statementStart].trimLeft();
  if (!RegExp(r'^(Navigator|ScaffoldMessenger|showDialog|showModalBottomSheet|if\s*\(|return\b|context\.|await\b)')
      .hasMatch(anchor)) {
    throw StateError(
      'admin_dashboard_page.dart: pemanggilan context tidak pada batas statement. '
      'Tidak mengubah file; cek baris 50–65.',
    );
  }
  final indent = RegExp(r'^\s*').firstMatch(lines[statementStart])!.group(0)!;
  lines.insert(statementStart, '$indent' 'if (!context.mounted) return;');
  stdout.writeln('  Tambah guard context.mounted sebelum baris ${statementStart + 1}');
  return lines.join('\n');
}

void writeWithBackup(File file, String updated, bool dryRun) {
  final previous = norm(file.readAsStringSync());
  if (updated == previous) {
    stdout.writeln('SUDAH  ${file.path}');
    return;
  }
  stdout.writeln('${dryRun ? 'CEK   ' : 'UBAH  '} ${file.path}');
  if (dryRun) return;
  final backup = File('${file.path}.bak_fix_4_info');
  if (!backup.existsSync()) backup.writeAsStringSync(previous);
  file.writeAsStringSync(updated);
}

void main(List<String> args) {
  final dryRun = args.contains('--dry-run');
  final projectIndex = args.indexOf('--project');
  if (projectIndex >= 0 && projectIndex + 1 >= args.length) {
    stderr.writeln('Gunakan --project <folder>');
    exitCode = 1;
    return;
  }
  final root = projectIndex == -1 ? Directory.current.path : args[projectIndex + 1];
  final changes = <File, String Function(String)>{
    File('$root/lib/features/shipping/presentation/shipping_address_page.dart'):
        (s) => fixDropdown(s, 'shipping_address_page.dart', 97),
    File('$root/lib/pages/add_product_page.dart'):
        (s) => fixDropdown(s, 'add_product_page.dart', 163),
    File('$root/lib/pages/admin_dashboard_page.dart'): fixAdmin,
    File('$root/tools/apply_pertemuan_09_13.dart'): fixInstaller,
  };
  try {
    // Semua file harus ada; gagal tanpa mengubah apa pun.
    for (final file in changes.keys) {
      if (!file.existsSync()) throw StateError('File tidak ditemukan: ${file.path}');
    }
    final staged = <File, String>{};
    final errors = <String>[];
    for (final entry in changes.entries) {
      final file = entry.key;
      try {
        staged[file] = entry.value(file.readAsStringSync());
      } catch (e) {
        errors.add('${file.path}: $e');
      }
    }
    if (errors.isNotEmpty) {
      stderr.writeln('Patch dibatalkan (tidak ada file diubah):');
      for (final error in errors) {
        stderr.writeln('- $error');
      }
      exitCode = 1;
      return;
    }
    for (final entry in staged.entries) {
      writeWithBackup(entry.key, entry.value, dryRun);
    }
    stdout.writeln(dryRun
        ? '\nDry run selesai. Belum mengubah file apa pun.'
        : '\nSelesai. Jalankan dart format lib/pages lib/features/shipping tools/fix_4_info.dart, flutter analyze dan flutter test.');
  } catch (e) {
    stderr.writeln('GAGAL: $e');
    exitCode = 1;
  }
}
