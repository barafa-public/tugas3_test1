import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/auth_service.dart';
import '../auth/login_page.dart';
import '../belanjaku/belanjaku_page.dart';
import '../konversi/konversi_page.dart';
import '../profile/profile_page.dart';

/// Halaman Home: daftar 5 menu utama secara vertikal.
/// 1. Profil Saya (pengganti "Daftar Anggota")
/// 2. Belanjaku - Kalkulator
/// 3. Belanjaku - Daftar Pesanan
/// 4. Konversi Tanggal (default Hijriah)
/// 5. Konversi Kalender (default Weton)
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
              title: 'Profil Saya',
              subtitle: 'Data akun & ringkasan belanja kamu',
              onTap: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => const ProfilePage())),
            ),
            const SizedBox(height: 12),
            _MenuTile(
              icon: Icons.calculate_outlined,
              title: 'Belanjaku - Kalkulator',
              subtitle: 'Hitung estimasi belanja',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      const BelanjakuPage(initialTab: BelanjakuTab.kalkulator),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _MenuTile(
              icon: Icons.list_alt_outlined,
              title: 'Belanjaku - Daftar Pesanan',
              subtitle: 'Kelola daftar & status pesanan',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      const BelanjakuPage(initialTab: BelanjakuTab.daftar),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _MenuTile(
              icon: Icons.calendar_month_outlined,
              title: 'Konversi Tanggal',
              subtitle: 'Konversi Masehi ke Hijriah',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      const KonversiPage(initialType: KonversiType.hijriah),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _MenuTile(
              icon: Icons.event_note_outlined,
              title: 'Konversi Kalender',
              subtitle: 'Hitung Weton',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      const KonversiPage(initialType: KonversiType.weton),
                ),
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
