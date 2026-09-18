/// Format angka jadi string Rupiah, contoh: 1250000 -> "Rp 1.250.000".
/// Dibuat manual (tanpa package intl) supaya tidak nambah dependency baru.
String formatRupiah(num amount) {
  final isNegative = amount < 0;
  final rounded = amount.abs().round();
  final digits = rounded.toString();

  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    final posFromRight = digits.length - i;
    buffer.write(digits[i]);
    if (posFromRight > 1 && posFromRight % 3 == 1) {
      buffer.write('.');
    }
  }

  return '${isNegative ? '-' : ''}Rp $buffer';
}

/// Format tanggal sederhana, contoh: 2026-09-18 -> "18 Sep 2026".
String formatTanggalPendek(DateTime date) {
  const bulan = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];
  return '${date.day} ${bulan[date.month - 1]} ${date.year}';
}
