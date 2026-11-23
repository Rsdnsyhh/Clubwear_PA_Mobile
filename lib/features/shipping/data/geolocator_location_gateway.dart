import 'package:geolocator/geolocator.dart';

import '../domain/shipping_gateways.dart';

class LocationAccessException implements Exception {
  const LocationAccessException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Izin diminta hanya setelah pengguna menekan tombol lokasi.
class GeolocatorLocationGateway implements LocationGateway {
  @override
  Future<GeoPoint> currentPosition() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        throw const LocationAccessException(
          'Layanan lokasi perangkat tidak aktif. Aktifkan GPS atau isi alamat manual.',
        );
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        throw const LocationAccessException(
          'Izin lokasi ditolak. Kamu tetap dapat mengetik alamat manual.',
        );
      }
      if (permission == LocationPermission.deniedForever) {
        throw const LocationAccessException(
          'Izin lokasi ditolak permanen. Ubah melalui Pengaturan perangkat jika diperlukan.',
        );
      }
      if (permission == LocationPermission.unableToDetermine) {
        throw const LocationAccessException('Status izin lokasi tidak dapat diperiksa.');
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 15),
        ),
      );
      return GeoPoint(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } on LocationAccessException {
      rethrow;
    } catch (_) {
      throw const LocationAccessException(
        'Gagal mendapatkan lokasi. Periksa sinyal GPS dan izin aplikasi.',
      );
    }
  }
}
