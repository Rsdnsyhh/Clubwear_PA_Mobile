import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:clubwear_app/features/shipping/data/http_province_repository.dart';

class MemoryProvinceCache implements ProvinceCache {
  String? value;
  @override
  Future<String?> read() async => value;
  @override
  Future<void> write(String json) async {
    value = json;
  }
}

void main() {
  final payload = jsonEncode({
    'data': [
      {'id': '64', 'name': 'Kalimantan Timur'},
      {'id': '51', 'name': 'Bali'},
    ],
    'meta': {'level': 1},
  });

  test('GET sukses dan menyimpan JSON di cache', () async {
    final cache = MemoryProvinceCache();
    final client = MockClient((request) async {
      expect(request.method, 'GET');
      expect(request.url.path, endsWith('/provinces.json'));
      return http.Response(payload, 200);
    });
    final repo = HttpProvinceRepository(client: client, cache: cache);
    final result = await repo.fetchProvinces();
    expect(result.fromCache, isFalse);
    expect(result.items.map((p) => p.name), ['Kalimantan Timur', 'Bali']);
    expect(cache.value, payload);
    repo.close();
    client.close();
  });

  test('offline memakai cache sebelumnya', () async {
    final cache = MemoryProvinceCache()..value = payload;
    final client = MockClient((_) async => http.Response('offline', 503));
    final repo = HttpProvinceRepository(client: client, cache: cache);
    final result = await repo.fetchProvinces();
    expect(result.fromCache, isTrue);
    expect(result.items.length, 2);
    repo.close();
    client.close();
  });

  test('tanpa internet dan cache: error terkontrol', () async {
    final client = MockClient((_) async => http.Response('offline', 503));
    final repo = HttpProvinceRepository(
      client: client,
      cache: MemoryProvinceCache(),
    );
    await expectLater(repo.fetchProvinces(),
        throwsA(isA<ProvinceUnavailableException>()));
    repo.close();
    client.close();
  });
}
