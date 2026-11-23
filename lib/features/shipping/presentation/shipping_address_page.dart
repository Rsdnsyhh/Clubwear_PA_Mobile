import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../providers/clubwear_provider.dart';
import '../../../widgets/common_widgets.dart';
import '../data/geolocator_location_gateway.dart';
import '../data/http_province_repository.dart';
import '../domain/address_rules.dart';
import 'address_view_model.dart';

/// UI yang bisa digunakan baik dari tab Profil maupun checkout Keranjang.
class ShippingAddressPage extends StatefulWidget {
  const ShippingAddressPage({super.key, required this.initialAddress});
  final String initialAddress;

  @override
  State<ShippingAddressPage> createState() => _ShippingAddressPageState();
}

class _ShippingAddressPageState extends State<ShippingAddressPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _addressController;
  late final AddressViewModel _vm;

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController(text: widget.initialAddress);
    _vm = AddressViewModel(
      provinceRepository: HttpProvinceRepository(),
      locationGateway: GeolocatorLocationGateway(),
    )..loadProvinces();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _vm.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final value = composeShippingAddress(
      _addressController.text,
      provinceName: _vm.selectedProvince?.name,
    );
    context.read<ClubwearProvider>().setAddress(value);
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AddressViewModel>.value(
      value: _vm,
      child: Consumer<AddressViewModel>(
        builder: (context, model, _) => Scaffold(
          appBar: AppBar(title: const Text('Alamat Pengiriman')),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(18),
                    children: [
                      const Text(
                        'Lengkapi alamat pengiriman',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Alamat tersimpan di perangkat untuk akun yang login. '
                            'Pilih provinsi bila tersedia; pilihan ini tidak mengubah tarif ongkir.',
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: _addressController,
                        minLines: 3,
                        maxLines: 5,
                        maxLength: 500,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Alamat lengkap',
                          hintText: 'Nama jalan, nomor rumah, RT/RW, kelurahan, kecamatan, kota',
                          alignLabelWithHint: true,
                        ),
                        validator: validateShippingAddress,
                      ),
                      const SizedBox(height: 12),
                      if (model.isLoading)
                        const Center(child: CircularProgressIndicator())
                      else if (model.provinces.isNotEmpty) ...[
                        DropdownButtonFormField<String>(
                          initialValue: model.selectedProvinceId,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Provinsi (opsional, dari REST API)',
                          ),
                          items: [
                            const DropdownMenuItem<String>(
                              value: '',
                              child: Text('Tidak dipilih / sudah tertulis di alamat'),
                            ),
                            for (final p in model.provinces)
                              DropdownMenuItem(value: p.id, child: Text(p.name)),
                          ],
                          onChanged: (value) =>
                              model.selectProvince(value == '' ? null : value),
                        ),
                        if (model.fromCache)
                          const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text('Daftar provinsi dimuat dari cache lokal (mode offline).'),
                          ),
                      ] else ...[
                        Text(
                          model.error ?? 'Daftar provinsi belum tersedia.',
                          style: const TextStyle(color: Colors.deepOrange),
                        ),
                        TextButton.icon(
                          onPressed: () => model.loadProvinces(),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Coba muat ulang provinsi'),
                        ),
                      ],
                      const SizedBox(height: 22),
                      const Text(
                        'Bantu cek titik lokasi (opsional)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'GPS hanya dibaca jika tombol ditekan. Koordinat tidak '
                            'disimpan otomatis dan bukan pengganti alamat tertulis.',
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: model.isLocating
                            ? null
                            : () => model.requestLocation(),
                        icon: model.isLocating
                            ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                            : const Icon(Icons.my_location),
                        label: Text(model.isLocating ? 'Memeriksa GPS...' : 'Ambil lokasi saat ini'),
                      ),
                      if (model.locationError != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            model.locationError!,
                            style: const TextStyle(color: Colors.deepOrange),
                          ),
                        ),
                      if (model.coordinates != null)
                        ListTile(
                          leading: const Icon(Icons.place_outlined),
                          title: Text(
                            '${model.coordinates!.latitude.toStringAsFixed(6)}, '
                                '${model.coordinates!.longitude.toStringAsFixed(6)}',
                          ),
                          subtitle: const Text('Salin bila ingin menambah koordinat ke alamat.'),
                          trailing: IconButton(
                            tooltip: 'Salin koordinat',
                            icon: const Icon(Icons.copy),
                            onPressed: () async {
                              final point = model.coordinates!;
                              await Clipboard.setData(ClipboardData(
                                text: '${point.latitude},${point.longitude}',
                              ));
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Koordinat disalin.')),
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 26),
                      FilledButton.icon(
                        onPressed: _save,
                        icon: const Icon(Icons.save_outlined),
                        label: const Text('Simpan Alamat'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
