import 'package:flutter/material.dart';

/// Satu baris hasil konversi: label di kiri, nilai di kanan.
class KonversiResultRow {
  final String label;
  final String value;

  const KonversiResultRow(this.label, this.value);
}

/// Kartu untuk menampilkan sekelompok hasil konversi (judul + beberapa
/// baris label-value). Dipakai berulang di [KonversiPage], baik untuk
/// tab "Konversi Tanggal" maupun tab "Konversi Kalender".
class KonversiResultCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<KonversiResultRow> rows;

  const KonversiResultCard({
    super.key,
    required this.icon,
    required this.title,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.deepPurple),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            for (final row in rows)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      row.label,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        row.value,
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
