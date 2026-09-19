import 'package:flutter/material.dart';

import '../../utils/date_convert.dart';
import 'widgets/konversi_result_card.dart';

/// Menu Konversi Tanggal & Kalender.
///
/// Sengaja TIDAK terhubung ke fitur shopping list ataupun database
/// (Supabase) sama sekali -- semua perhitungan murni lokal, memakai
/// fungsi-fungsi pure di `utils/date_convert.dart`.
///
/// Pilihan tipe konversi ada di bagian atas (lewat [SegmentedButton]):
/// - "Konversi Tanggal": konversi ke Hijriah + konversi tanggal lahir
///   ke umur (tahun, bulan, hari, jam, menit, detik).
/// - "Konversi Kalender": konversi ke Weton (Kalender Jawa) + Kalender
///   Saka Bali.
/// Kedua mode berbagi 1 date picker yang sama di bawah pemilih mode.
enum _KonversiMode { tanggal, kalender }

class KonversiPage extends StatefulWidget {
  const KonversiPage({super.key});

  @override
  State<KonversiPage> createState() => _KonversiPageState();
}

class _KonversiPageState extends State<KonversiPage> {
  _KonversiMode _mode = _KonversiMode.tanggal;
  DateTime _selectedDate = DateTime.now();

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      helpText: 'Pilih tanggal',
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Konversi Tanggal & Kalender')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Pilihan tipe konversi di bagian atas.
            SegmentedButton<_KonversiMode>(
              segments: const [
                ButtonSegment(
                  value: _KonversiMode.tanggal,
                  label: Text('Konversi Tanggal'),
                  icon: Icon(Icons.calendar_today_outlined),
                ),
                ButtonSegment(
                  value: _KonversiMode.kalender,
                  label: Text('Konversi Kalender'),
                  icon: Icon(Icons.brightness_5_outlined),
                ),
              ],
              selected: {_mode},
              onSelectionChanged: (selection) {
                setState(() => _mode = selection.first);
              },
            ),
            const SizedBox(height: 20),

            _buildDatePicker(),
            const SizedBox(height: 20),

            if (_mode == _KonversiMode.tanggal)
              _buildTanggalResults()
            else
              _buildKalenderResults(),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.event_outlined),
        title: const Text('Tanggal yang dipilih'),
        subtitle: Text(_formatTanggalLengkap(_selectedDate)),
        trailing: FilledButton.tonal(
          onPressed: _pickDate,
          child: const Text('Pilih'),
        ),
      ),
    );
  }

  /// Tab "Konversi Tanggal": Hijriah + konversi umur.
  /// Sesuai kriteria: "memiliki menu konversi tanggal hijriah, konversi
  /// tanggal lahir ke umur, tahun, bulan, hari jam, menit dan detik".
  Widget _buildTanggalResults() {
    final hijri = convertToHijri(_selectedDate);
    final age = calculateAge(_selectedDate);

    return Column(
      children: [
        KonversiResultCard(
          icon: Icons.mosque_outlined,
          title: 'Konversi ke Tanggal Hijriah',
          rows: [KonversiResultRow('Tanggal Hijriah', hijri.toString())],
        ),
        KonversiResultCard(
          icon: Icons.cake_outlined,
          title: 'Konversi Umur (anggap tanggal ini tanggal lahir)',
          rows: [
            KonversiResultRow(
              'Umur',
              '${age.years} tahun ${age.months} bulan ${age.days} hari',
            ),
            KonversiResultRow('Total Bulan', '${age.totalMonths} bulan'),
            KonversiResultRow('Total Hari', '${age.totalDays} hari'),
            KonversiResultRow('Total Jam', '${age.totalHours} jam'),
            KonversiResultRow('Total Menit', '${age.totalMinutes} menit'),
            KonversiResultRow('Total Detik', '${age.totalSeconds} detik'),
          ],
        ),
        const _DisclaimerText(
          'Hasil konversi Hijriah dihitung secara aritmetik (algoritma '
          'Kuwaiti) dan bisa berbeda 1 hari dari kalender Hijriah resmi '
          'yang berdasarkan pengamatan hilal.',
        ),
      ],
    );
  }

  /// Tab "Konversi Kalender": Weton + Tahun Saka Bali.
  /// Sesuai kriteria: "memiliki menu konversi Kalender weton dan
  /// Kalender saka bali".
  Widget _buildKalenderResults() {
    final weton = calculateWeton(_selectedDate);
    final tahunSaka = calculateTahunSaka(_selectedDate);

    return Column(
      children: [
        KonversiResultCard(
          icon: Icons.brightness_5_outlined,
          title: 'Konversi ke Weton (Kalender Jawa)',
          rows: [KonversiResultRow('Weton', weton.label)],
        ),
        KonversiResultCard(
          icon: Icons.temple_hindu_outlined,
          title: 'Konversi ke Kalender Saka Bali',
          rows: [KonversiResultRow('Tahun Saka', '$tahunSaka')],
        ),
        const _DisclaimerText(
          'Tahun Saka dihitung dengan rumus umum (Tahun Masehi - 78, '
          'disesuaikan sebelum/sesudah perkiraan Nyepi). Perhitungan '
          'bulan & wuku Saka secara penuh memerlukan tabel pawukon yang '
          'lebih kompleks dan belum tercakup di sini.',
        ),
      ],
    );
  }

  String _formatTanggalLengkap(DateTime date) {
    const bulan = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${date.day} ${bulan[date.month - 1]} ${date.year}';
  }
}

class _DisclaimerText extends StatelessWidget {
  final String text;

  const _DisclaimerText(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }
}
