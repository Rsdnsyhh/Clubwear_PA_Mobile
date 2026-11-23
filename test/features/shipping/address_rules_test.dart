import 'package:flutter_test/flutter_test.dart';
import 'package:clubwear_app/features/shipping/domain/address_rules.dart';

void main() {
  group('Shipping address domain', () {
    test('menolak alamat kosong dan terlalu pendek', () {
      expect(validateShippingAddress('  '), isNotNull);
      expect(validateShippingAddress('jalan'), isNotNull);
    });
    test('menerima alamat normal', () {
      expect(validateShippingAddress('Jl. Merdeka No. 10, Balikpapan'), isNull);
    });
    test('provinsi tidak digandakan jika sudah disebut', () {
      expect(
        composeShippingAddress('Jl. Merdeka, Kalimantan Timur',
            provinceName: 'Kalimantan Timur'),
        'Jl. Merdeka, Kalimantan Timur',
      );
    });
    test('menambahkan provinsi untuk alamat yang belum menyebutnya', () {
      expect(
        composeShippingAddress('Jl. Merdeka No. 10, Balikpapan',
            provinceName: 'Kalimantan Timur'),
        'Jl. Merdeka No. 10, Balikpapan, Kalimantan Timur',
      );
    });
  });
}
