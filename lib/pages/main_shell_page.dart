import 'package:flutter/material.dart';

import 'home/home_page.dart';

/// Titik masuk utama setelah login berhasil.
///
/// Untuk sekarang hanya membungkus [HomePage] (5 menu vertikal).
/// Dipisah jadi file sendiri supaya kalau nanti mau nambah shell
/// tambahan (misalnya bottom navigation bar atau drawer), cukup ubah
/// di sini tanpa mengutak-atik main.dart.
class MainShellPage extends StatelessWidget {
  const MainShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomePage();
  }
}
