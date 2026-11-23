import 'dart:convert';
import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/province.dart';
import '../domain/shipping_gateways.dart';

/// Cache dipisah agar repository dapat dites tanpa plugin platform.
abstract class ProvinceCache {
  Future<String?> read();
  Future<void> write(String json);
}

class SharedPrefsProvinceCache implements ProvinceCache {
  SharedPrefsProvinceCache({SharedPreferencesAsync? preferences})
      : _preferences = preferences ?? SharedPreferencesAsync();

  static const _key = 'shipping_provinces_v2_json';
  final SharedPreferencesAsync _preferences;

  @override
  Future<String?> read() => _preferences.getString(_key);

  @override
  Future<void> write(String json) => _preferences.setString(_key, json);
}

class HttpProvinceRepository implements ProvinceRepository {
  HttpProvinceRepository({http.Client? client, ProvinceCache? cache})
      : _client = client ?? http.Client(),
        _ownsClient = client == null,
        _cache = cache ?? SharedPrefsProvinceCache();

  static final Uri endpoint = Uri.parse(
    'https://www.emsifa.com/api-wilayah-indonesia/v2/provinces.json',
  );
  final http.Client _client;
  final bool _ownsClient;
  final ProvinceCache _cache;

  List<Province> _parse(String jsonString) {
    final decoded = jsonDecode(jsonString);
    if (decoded is! Map<String, dynamic> || decoded['data'] is! List) {
      throw const FormatException('Format respons API wilayah tidak dikenal.');
    }
    final records = decoded['data'] as List<dynamic>;
    final result = records.map((item) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException('Format entri provinsi tidak dikenal.');
      }
      return Province.fromJson(item);
    }).toList();
    if (result.isEmpty) throw const FormatException('Daftar provinsi kosong.');
    return result;
  }

  @override
  Future<ProvinceResult> fetchProvinces() async {
    try {
      final response = await _client.get(
        endpoint,
        headers: const {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 12));
      if (response.statusCode != 200) {
        throw http.ClientException('HTTP ${response.statusCode}', endpoint);
      }
      final body = utf8.decode(response.bodyBytes);
      final provinces = _parse(body);
      try {
        await _cache.write(body);
      } catch (_) {
        // API tetap dapat dipakai meski perangkat menolak menyimpan cache.
      }
      return ProvinceResult(items: provinces, fromCache: false);
    } catch (_) {
      // Jika offline, coba cache dari keberhasilan API sebelumnya.
      try {
        final cached = await _cache.read();
        if (cached != null) {
          return ProvinceResult(items: _parse(cached), fromCache: true);
        }
      } catch (_) {
        // Cache rusak/tidak dapat diakses: kembali ke input alamat manual.
      }
      throw const ProvinceUnavailableException();
    }
  }

  @override
  void close() {
    if (_ownsClient) _client.close();
  }
}

class ProvinceUnavailableException implements Exception {
  const ProvinceUnavailableException();
  @override
  String toString() => 'Daftar provinsi belum tersedia. Isi alamat manual.';
}
