import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/auth_service.dart';
import '../auth/login_page.dart';
import '../belanjaku/pesanan_page.dart';
import '../belanjaku/daftar_pesanan_page.dart';
import '../belanjaku/history_pesanan_page.dart';
import '../konversi/konversi_page.dart';
import '../profile/profile_page.dart';

/// Halaman Home: daftar 5 menu utama secara vertikal.
/// 1. Menu Profile
/// 2. Menu Pesanan (pilih barang & jumlah, masuk ke keranjang / status cart)
/// 3. Menu Daftar Pesanan (item cart yang belum dibayar, bisa dibayar)
/// 4. Menu History Pesanan (item yang sudah selesai/dibayar)
/// 5. Menu Konversi Tanggal & Kalender (gabungan, isi masih dikosongkan)
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    await AuthService().signOut();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final fullName =
        Supabase.instance.client.auth.currentUser?.userMetadata?['full_name']
            as String? ??
        Supabase.instance.client.auth.currentUser?.email ??
        '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Belanjaku'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            if (fullName.isNotEmpty) ...[
              Text(
                'Halo, $fullName 👋',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Mau ngapain hari ini?',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 20),
            ],
            _MenuTile(
              icon: Icons.person_outline,
              title: 'Menu Profile',
              subtitle: 'Data akun & ringkasan belanja kamu',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              ),
            ),
            const SizedBox(height: 12),
            _MenuTile(
              icon: Icons.shopping_bag_outlined,
              title: 'Menu Pesanan',
              subtitle: 'Pilih barang & jumlahnya, masuk ke keranjang',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PesananPage()),
              ),
            ),
            const SizedBox(height: 12),
            _MenuTile(
              icon: Icons.list_alt_outlined,
              title: 'Menu Daftar Pesanan',
              subtitle: 'Pesanan yang belum dibayar, bisa dibayar di sini',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DaftarPesananPage()),
              ),
            ),
            const SizedBox(height: 12),
            _MenuTile(
              icon: Icons.history,
              title: 'Menu History Pesanan',
              subtitle: 'Pesanan yang sudah selesai / dibayar',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const HistoryPesananPage()),
              ),
            ),
            const SizedBox(height: 12),
            _MenuTile(
              icon: Icons.calendar_month_outlined,
              title: 'Menu Konversi Tanggal & Kalender',
              subtitle: 'Belum tersedia (masih dikosongkan)',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const KonversiPage()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        leading: CircleAvatar(
          backgroundColor: Colors.deepPurple.shade50,
          child: Icon(icon, color: Colors.deepPurple),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
