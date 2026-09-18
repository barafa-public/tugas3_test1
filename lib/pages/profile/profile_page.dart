import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/proflie_model.dart';
import '../../services/auth_service.dart';
import '../../services/profile_service.dart';
import '../../utils/currency_formatter.dart';
import '../auth/login_page.dart';

/// Halaman "Profil Saya" — menggantikan menu "Daftar Anggota" sesuai
/// arahan dosen. Menampilkan data user yang login, ditambah ringkasan
/// dashboard (jumlah item di keranjang, pesanan selesai, total
/// pengeluaran, dan sisa budget periode berjalan).
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _profileService = ProfileService();
  final _authService = AuthService();

  late Future<_ProfileData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_ProfileData> _load() async {
    final profile = await _profileService.getMyProfile();
    final summary = await _profileService.getMyDashboardSummary();
    return _ProfileData(profile: profile, summary: summary);
  }

  Future<void> _refresh() async {
    final next = _load();
    setState(() => _future = next);
    await next;
  }

  Future<void> _handleLogout() async {
    await _authService.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: FutureBuilder<_ProfileData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      'Gagal memuat profil.\n${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _refresh,
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          final data = snapshot.data!;
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildHeader(data.profile),
                const SizedBox(height: 16),
                _buildStatsRow(data.summary),
                const SizedBox(height: 16),
                _buildBudgetCard(data.summary),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(ProfileModel profile) {
    final email = Supabase.instance.client.auth.currentUser?.email ?? '-';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 32,
              backgroundColor: Colors.deepPurple,
              child: Icon(Icons.person, color: Colors.white, size: 36),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.fullName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text('@${profile.username}',
                      style: TextStyle(color: Colors.grey.shade600)),
                  Text(email, style: TextStyle(color: Colors.grey.shade600)),
                  const SizedBox(height: 6),
                  Text(
                    'Bergabung sejak ${formatTanggalPendek(profile.createdAt)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(DashboardSummary summary) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.shopping_cart_outlined,
            label: 'Di Keranjang',
            value: '${summary.totalDiKeranjang}',
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.check_circle_outline,
            label: 'Pesanan Selesai',
            value: '${summary.totalPesananSelesai}',
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.payments_outlined,
            label: 'Total Belanja',
            value: formatRupiah(summary.totalPengeluaran),
            color: Colors.deepPurple,
            small: true,
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetCard(DashboardSummary summary) {
    if (!summary.hasBudget) {
      return Card(
        color: Colors.grey.shade100,
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.grey),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Belum ada budget yang aktif untuk periode saat ini.',
                ),
              ),
            ],
          ),
        ),
      );
    }

    final budget = summary.budgetAmount!;
    final sisa = summary.sisaBudget ?? budget;
    final terpakai = (budget - sisa).clamp(0, budget);
    final progress = budget == 0 ? 0.0 : (terpakai / budget).clamp(0.0, 1.0);
    final overBudget = sisa < 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.savings_outlined, color: Colors.deepPurple),
                const SizedBox(width: 8),
                const Text(
                  'Budget Periode Berjalan',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 4),
            if (summary.periodStart != null && summary.periodEnd != null)
              Text(
                '${formatTanggalPendek(summary.periodStart!)} - '
                '${formatTanggalPendek(summary.periodEnd!)}',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: Colors.grey.shade200,
                color: overBudget ? Colors.red : Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Budget: ${formatRupiah(budget)}'),
                Text(
                  overBudget
                      ? 'Lebih ${formatRupiah(sisa.abs())}'
                      : 'Sisa: ${formatRupiah(sisa)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: overBudget ? Colors.red : Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool small;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 8.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 6),
            Text(
              value,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: small ? 13 : 16,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileData {
  final ProfileModel profile;
  final DashboardSummary summary;

  _ProfileData({required this.profile, required this.summary});
}
