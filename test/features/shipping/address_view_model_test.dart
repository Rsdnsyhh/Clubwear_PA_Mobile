import 'package:flutter_test/flutter_test.dart';
import 'package:clubwear_app/features/shipping/domain/province.dart';
import 'package:clubwear_app/features/shipping/domain/shipping_gateways.dart';
import 'package:clubwear_app/features/shipping/presentation/address_view_model.dart';

class FakeProvinceRepository implements ProvinceRepository {
  @override
  Future<ProvinceResult> fetchProvinces() async => const ProvinceResult(
        items: [Province(id: '64', name: 'Kalimantan Timur')],
        fromCache: false,
      );
  @override
  void close() {}
}

class FakeLocationGateway implements LocationGateway {
  @override
  Future<GeoPoint> currentPosition() async => const GeoPoint(
        latitude: -1.265,
        longitude: 116.831,
      );
}

void main() {
  test('ViewModel memuat provinsi dan memilih berdasarkan ID', () async {
    final vm = AddressViewModel(
      provinceRepository: FakeProvinceRepository(),
      locationGateway: FakeLocationGateway(),
    );
    await vm.loadProvinces();
    expect(vm.isLoading, false);
    expect(vm.provinces.length, 1);
    vm.selectProvince('64');
    expect(vm.selectedProvince?.name, 'Kalimantan Timur');
    vm.dispose();
  });

  test('ViewModel membaca lokasi hanya ketika diminta', () async {
    final vm = AddressViewModel(
      provinceRepository: FakeProvinceRepository(),
      locationGateway: FakeLocationGateway(),
    );
    expect(vm.coordinates, null);
    await vm.requestLocation();
    expect(vm.coordinates?.latitude, -1.265);
    vm.dispose();
  });
}
