/// Aturan bisnis tidak bergantung pada widget atau layanan perangkat.
String? validateShippingAddress(String? input) {
  final value = (input ?? '').trim();
  if (value.isEmpty) return 'Alamat wajib diisi.';
  if (value.length < 10) return 'Alamat minimal 10 karakter.';
  if (value.length > 500) return 'Alamat maksimal 500 karakter.';
  return null;
}

/// Tambahkan provinsi hanya bila belum disebut di alamat lengkap.
String composeShippingAddress(String fullAddress, {String? provinceName}) {
  final address = fullAddress.trim();
  final province = (provinceName ?? '').trim();
  if (province.isEmpty ||
      address.toLowerCase().contains(province.toLowerCase())) {
    return address;
  }
  return '$address, $province';
}
