import 'province.dart';

abstract class ProvinceRepository {
  Future<ProvinceResult> fetchProvinces();
  void close();
}

class GeoPoint {
  const GeoPoint({required this.latitude, required this.longitude});
  final double latitude;
  final double longitude;
}

abstract class LocationGateway {
  Future<GeoPoint> currentPosition();
}
