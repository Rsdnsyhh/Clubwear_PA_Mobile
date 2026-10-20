class OrderLine {
  const OrderLine({
    required this.name,
    required this.category,
    required this.size,
    required this.quantity,
    required this.price,
  });

  final String name;
  final String category;
  final String size;
  final int quantity;
  final int price;

  int get subtotal => price * quantity;
}

/// Riwayat pesanan (snapshot saat checkout).
class Order {
  const Order({
    required this.id,
    required this.date,
    required this.lines,
    required this.subtotal,
    required this.shipping,
    required this.address,
  });

  final String id;
  final DateTime date;
  final List<OrderLine> lines;
  final int subtotal;
  final int shipping;
  final String address;

  int get total => subtotal + shipping;

  int get itemCount => lines.fold(0, (sum, line) => sum + line.quantity);

  /// Jumlah barang per jenis, contoh: {Kaos: 2, Sepatu: 1}
  Map<String, int> get categoryCounts {
    final counts = <String, int>{};
    for (final line in lines) {
      counts[line.category] = (counts[line.category] ?? 0) + line.quantity;
    }
    return counts;
  }

  /// Contoh: "2 Kaos, 1 Sepatu"
  String get contentSummary => categoryCounts.entries
      .map((e) => '${e.value} ${e.key}')
      .join(', ');
}

/// Kode pesanan yang bisa dibaca isinya.
/// Contoh: CW001-KAOS2-SEPATU1  (pesanan ke-1: 2 kaos + 1 sepatu)
/// Jika lebih dari 3 jenis: CW002-KAOS2-JAKET1-SEPATU1-LAIN2
String buildOrderCode(int sequence, List<OrderLine> lines) {
  final counts = <String, int>{};
  for (final line in lines) {
    counts[line.category] = (counts[line.category] ?? 0) + line.quantity;
  }

  final parts = counts.entries
      .take(3)
      .map((e) => '${e.key.toUpperCase()}${e.value}')
      .toList();

  final rest = counts.length - 3;
  if (rest > 0) parts.add('LAIN$rest');

  return 'CW${sequence.toString().padLeft(3, '0')}-${parts.join('-')}';
}

const _bulan = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
];

/// Contoh: 21 Okt 2026, 16:45
String formatTanggal(DateTime d) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${d.day} ${_bulan[d.month - 1]} ${d.year}, ${two(d.hour)}:${two(d.minute)}';
}