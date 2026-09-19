import 'package:flutter/material.dart';

/// Menu Bantuan.
///
/// Berisi panduan singkat cara memakai aplikasi Belanjaku, disusun per
/// menu supaya user baru gampang mengikuti alurnya dari awal (login)
/// sampai riwayat pesanan.
class BantuanPage extends StatelessWidget {
  const BantuanPage({super.key});

  static const List<_HelpSection> _sections = [
    _HelpSection(
      icon: Icons.login,
      title: 'Login & Registrasi',
      steps: [
        'Kalau belum punya akun, ketuk "Daftar" di halaman login lalu isi username, nama lengkap, email, dan password.',
        'Kalau sudah punya akun, masukkan username/email dan password, lalu ketuk "Login".',
      ],
    ),
    _HelpSection(
      icon: Icons.person_outline,
      title: 'Menu Profile',
      steps: [
        'Menampilkan data akun kamu dan ringkasan belanja (total di keranjang, total pesanan selesai, dan sisa budget).',
      ],
    ),
    _HelpSection(
      icon: Icons.shopping_bag_outlined,
      title: 'Menu Pesanan',
      steps: [
        'Ketuk tombol "Pilih Produk" untuk membuka katalog produk sehari-hari.',
        'Ketuk salah satu produk, atur jumlahnya lewat tombol +/- atau ketik langsung, lalu ketuk "Tambah ke Pesanan".',
        'Produk yang sudah ditambahkan akan muncul di daftar pada menu ini dengan status belum dibayar.',
        'Ketuk salah satu item untuk mengedit nama, harga, jumlah, atau kategorinya. Geser item ke kiri untuk menghapusnya.',
      ],
    ),
    _HelpSection(
      icon: Icons.list_alt_outlined,
      title: 'Menu Daftar Pesanan',
      steps: [
        'Menampilkan semua pesanan yang masih menunggu pembayaran.',
        'Ketuk ikon pembayaran pada item untuk membayarnya — pesanan otomatis pindah ke Menu History Pesanan.',
        'Item juga bisa dihapus dari sini kalau jadi tidak ingin dipesan.',
      ],
    ),
    _HelpSection(
      icon: Icons.history,
      title: 'Menu History Pesanan',
      steps: [
        'Menampilkan semua pesanan yang sudah dibayar.',
        'Halaman ini bersifat lihat-saja — pesanan yang sudah dibayar tidak bisa diedit atau dikembalikan ke keranjang.',
      ],
    ),
    _HelpSection(
      icon: Icons.calendar_month_outlined,
      title: 'Menu Konversi Tanggal & Kalender',
      steps: ['Fitur ini masih dalam pengembangan.'],
    ),
    _HelpSection(
      icon: Icons.timer_outlined,
      title: 'Menu Stopwatch',
      steps: [
        'Ketuk "Mulai" untuk menjalankan stopwatch, "Jeda" untuk menghentikannya sementara.',
        'Ketuk "Lap" saat stopwatch berjalan untuk mencatat waktu tempuh saat itu.',
        'Ketuk "Reset" untuk mengembalikan stopwatch ke 00:00 — pastikan sudah dijeda dulu sebelum reset.',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bantuan')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Cara Menggunakan Belanjaku',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Panduan singkat untuk setiap menu di aplikasi ini.',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            for (final section in _sections) _HelpCard(section: section),
          ],
        ),
      ),
    );
  }
}

class _HelpSection {
  final IconData icon;
  final String title;
  final List<String> steps;

  const _HelpSection({
    required this.icon,
    required this.title,
    required this.steps,
  });
}

class _HelpCard extends StatelessWidget {
  final _HelpSection section;

  const _HelpCard({required this.section});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            section.icon,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            size: 20,
          ),
        ),
        title: Text(
          section.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final step in section.steps)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('•  ', style: TextStyle(color: Colors.grey.shade600)),
                  Expanded(child: Text(step)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
