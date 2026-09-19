import 'package:flutter/material.dart';

/// Menu Konversi Tanggal & Kalender.
///
/// Gabungan dari menu "Konversi Tanggal" (Masehi -> Hijriah) dan
/// "Konversi Kalender" (Weton) yang sebelumnya terpisah. Untuk sekarang
/// isinya sengaja dikosongkan dulu (masih tugas terpisah, fokus utama
/// masih di alur Profil, Pesanan, Daftar Pesanan, dan History Pesanan).
class KonversiPage extends StatelessWidget {
  const KonversiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Konversi Tanggal & Kalender')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.calendar_month_outlined,
                  size: 56, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              const Text(
                'Konversi Tanggal & Kalender',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Fitur konversi Masehi-Hijriah dan Weton belum tersedia.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
