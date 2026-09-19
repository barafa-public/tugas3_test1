import 'package:flutter/material.dart';
import 'package:tugas3_test/pages/home/widgets/menu_tile.dart';

// Instruksi pemakaian perangkat lunak Belanjaku,
// 1. Stopwatch
// 1. a.
//
// 2. Menu utama
// 2. a. Profil saya
//   tekan menu profil saya untuk melihat detail profil seperti jumlah item dikeranjang, jumlah pesanan selesai, dan total biaya belanja
// 2. b. Input Pesanan
// 2. c. Lihat Pesanan
//   tekan menu ini untuk melihat semua pesanan yang sudah anda buat yang belum dianggap selesai
//
// 2. d. History Pesanan
//   tekan menu ini untuk melihat semua pesanan yang sudah dianggap selesai
//
// 2. e. Konversi tanggal
//   tekan menu ini untuk melakukan konversi tanggal hijriah, weton, dan saka bali serta menghitung umur berdasarkan tanggal lahir
class HelpPageWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        spacing: 12,
        children: [
          MenuTile(
            icon: Icons.person_outline,
            title: 'Profil Saya',
            subtitle: 'Data akun & ringkasan belanja kamu',
            onTap: () => {},
          ),
          MenuTile(
            icon: Icons.calculate_outlined,
            title: 'Belanjaku - Kalkulator',
            subtitle: 'Hitung estimasi belanja',
            onTap: () => {},
          ),
          MenuTile(
            icon: Icons.list_alt_outlined,
            title: 'Belanjaku - Daftar Pesanan',
            subtitle: 'Kelola daftar & status pesanan',
            onTap: () => {},
          ),
          MenuTile(
            icon: Icons.calendar_month_outlined,
            title: 'Konversi Tanggal',
            subtitle: 'Konversi Masehi ke Hijriah',
            onTap: () => {},
          ),
          MenuTile(
            icon: Icons.event_note_outlined,
            title: 'Konversi Kalender',
            subtitle: 'Hitung Weton',
            onTap: () => {},
          ),
        ],
      ),
    );
  }
}
