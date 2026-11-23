import 'package:flutter/foundation.dart';

import '../domain/province.dart';
import '../domain/shipping_gateways.dart';

/// MVVM: state asinkron terisolasi dari widget.
class AddressViewModel extends ChangeNotifier {
  AddressViewModel({
    required ProvinceRepository provinceRepository,
    required LocationGateway locationGateway,
  })  : _provincesRepository = provinceRepository,
        _locationGateway = locationGateway;

  final ProvinceRepository _provincesRepository;
  final LocationGateway _locationGateway;
  bool _disposed = false;

  bool isLoading = false;
  bool isLocating = false;
  String? error;
  String? locationError;
  bool fromCache = false;
  List<Province> provinces = const [];
  String? selectedProvinceId;
  GeoPoint? coordinates;

  Province? get selectedProvince {
    for (final p in provinces) {
      if (p.id == selectedProvinceId) return p;
    }
    return null;
  }

  void selectProvince(String? id) {
    selectedProvinceId = id;
    notifyListeners();
  }

  Future<void> loadProvinces() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final result = await _provincesRepository.fetchProvinces();
      if (_disposed) return;
      provinces = result.items;
      fromCache = result.fromCache;
    } catch (_) {
      if (_disposed) return;
      error = 'Daftar provinsi gagal dimuat. Alamat tetap dapat ditulis manual.';
    } finally {
      if (!_disposed) {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> requestLocation() async {
    isLocating = true;
    locationError = null;
    notifyListeners();
    try {
      final position = await _locationGateway.currentPosition();
      if (_disposed) return;
      coordinates = position;
    } catch (e) {
      if (_disposed) return;
      locationError = e.toString();
    } finally {
      if (!_disposed) {
        isLocating = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _provincesRepository.close();
    super.dispose();
  }
}
