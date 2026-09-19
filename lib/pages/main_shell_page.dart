import 'package:flutter/material.dart';

import 'bantuan/bantuan_page.dart';
import 'home/home_page.dart';
import 'stopwatch/stopwatch_page.dart';

/// Titik masuk utama setelah login berhasil.
///
/// Menyediakan 3 menu di footer (bottom navigation):
/// 1. Homepage — berisi 5 menu vertikal (Profile, Pesanan, Daftar
///    Pesanan, History Pesanan, Konversi).
/// 2. Stopwatch — fitur stopwatch untuk tugas.
/// 3. Bantuan — panduan cara memakai aplikasi.
///
/// Pakai [IndexedStack] (bukan langsung ganti widget sesuai index) supaya
/// state tiap halaman tetap terjaga saat pindah tab — penting terutama
/// untuk Stopwatch, karena kalau widget-nya dibuang lalu dibuat ulang
/// setiap pindah tab, hitungan waktunya akan ikut ke-reset.
class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  int _currentIndex = 0;

  static const _pages = [HomePage(), StopwatchPage(), BantuanPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Homepage',
          ),
          NavigationDestination(
            icon: Icon(Icons.timer_outlined),
            selectedIcon: Icon(Icons.timer),
            label: 'Stopwatch',
          ),
          NavigationDestination(
            icon: Icon(Icons.help_outline),
            selectedIcon: Icon(Icons.help),
            label: 'Bantuan',
          ),
        ],
      ),
    );
  }
}
