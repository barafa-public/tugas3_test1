import 'package:flutter/material.dart';

import 'widgets/budget_calculator_view.dart';

/// Tab default yang dibuka saat masuk ke [BelanjakuPage].
enum BelanjakuTab { kalkulator, daftar }

/// Halaman Belanjaku, berisi 2 tab: Kalkulator dan Daftar Pesanan.
///
/// Tab Kalkulator (Menu Pesanan) sudah pakai [BudgetCalculatorView].
///
/// TODO (Fariz): implementasikan tab Daftar Pesanan (CRUD status
/// cart/completed ke tabel `orders`). Masih placeholder untuk sekarang.
class BelanjakuPage extends StatefulWidget {
  final BelanjakuTab initialTab;

  const BelanjakuPage({super.key, this.initialTab = BelanjakuTab.kalkulator});

  @override
  State<BelanjakuPage> createState() => _BelanjakuPageState();
}

class _BelanjakuPageState extends State<BelanjakuPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab == BelanjakuTab.kalkulator ? 0 : 1,
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
        title: const Text('Belanjaku'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.calculate_outlined), text: 'Kalkulator'),
            Tab(icon: Icon(Icons.list_alt_outlined), text: 'Daftar Pesanan'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          BudgetCalculatorView(),
          _ComingSoon(
            icon: Icons.list_alt_outlined,
            title: 'Daftar Pesanan',
            message: 'Fitur CRUD daftar pesanan belum tersedia, segera hadir.',
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
