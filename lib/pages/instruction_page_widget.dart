import 'package:flutter/material.dart';

class InstructionPageWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text("""
Instruksi pemakaian perangkat lunak Belanjaku,
1. Stopwatch
1. a. 

2. Menu utama
2. a. Profil saya
  tekan menu profil saya untuk melihat detail profil seperti jumlah item dikeranjang, jumlah pesanan selesai, dan total biaya belanja
2. b. Input Pesanan
2. c. Lihat Pesanan
  tekan menu ini untuk melihat semua pesanan yang sudah anda buat yang belum dianggap selesai

2. d. History Pesanan
  tekan menu ini untuk melihat semua pesanan yang sudah dianggap selesai

2. e. Konversi tanggal
  tekan menu ini untuk melakukan konversi tanggal hijriah, weton, dan saka bali serta menghitung umur berdasarkan tanggal lahir
      """),
    );
  }
}
