/// Model domain: bebas dari Flutter, HTTP, dan database.
class Province {
  const Province({required this.id, required this.name});

  final String id;
  final String name;

  factory Province.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString().trim() ?? '';
    final name = json['name']?.toString().trim() ?? '';
    if (id.isEmpty || name.isEmpty) {
      throw const FormatException('Data provinsi tidak lengkap.');
    }
    return Province(id: id, name: name);
  }
}

class ProvinceResult {
  const ProvinceResult({required this.items, required this.fromCache});

  final List<Province> items;
  final bool fromCache;
}
