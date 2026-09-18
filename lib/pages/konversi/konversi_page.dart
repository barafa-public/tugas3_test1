import 'package:flutter/material.dart';

/// Tipe konversi default yang dibuka saat masuk ke [KonversiPage].
enum KonversiType { hijriah, weton }

/// Halaman Konversi, berisi 2 tab: Konversi Tanggal (Hijriah) dan
/// Konversi Kalender (Weton).
///
/// TODO: implementasikan logika konversi tanggal Masehi <-> Hijriah dan
/// perhitungan Weton. Untuk sekarang kedua tab masih placeholder,
/// sesuai arahan: bagian Profil dulu yang jadi, menu lain dikosongkan
/// dulu.
class KonversiPage extends StatefulWidget {
  final KonversiType initialType;

  const KonversiPage({super.key, this.initialType = KonversiType.hijriah});

  @override
  State<KonversiPage> createState() => _KonversiPageState();
}

class _KonversiPageState extends State<KonversiPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialType == KonversiType.hijriah ? 0 : 1,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Konversi'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.calendar_month_outlined), text: 'Hijriah'),
            Tab(icon: Icon(Icons.event_note_outlined), text: 'Weton'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _ComingSoon(
            icon: Icons.calendar_month_outlined,
            title: 'Konversi Tanggal Hijriah',
            message: 'Fitur konversi Masehi ke Hijriah belum tersedia.',
          ),
          _ComingSoon(
            icon: Icons.event_note_outlined,
            title: 'Konversi Kalender Weton',
            message: 'Fitur konversi Weton belum tersedia.',
          ),
        ],
      ),
    );
  }
}

class _ComingSoon extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _ComingSoon({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
