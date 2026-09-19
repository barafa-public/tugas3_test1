import 'package:flutter/material.dart';
import 'package:tugas3_test/pages/daftar_pesanan/widget/app_bottom_sheet.dart';
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

void displayHelpMessage(
  BuildContext context,
  String header,
  String description,
) {
  showAppBottomSheet(
    context: context,
    child: Column(
      spacing: 12,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(header, style: TextStyle(fontSize: 24)),
        Text(description, style: TextStyle(fontSize: 18)),
      ],
    ),
  );
}

class HelpPageWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        spacing: 12,
        children: [
          MenuTile(
            icon: Icons.timer,
            title: 'Stopwatch',
            subtitle: '',
            onTap: () => {
              displayHelpMessage(
                context,
                "Stopwatch",
                "Menu ini merupakan menu stopwatch. Cara memakainya adalah dengan cara menekan tombol start dan tunggu selama sesuka hati anda kemudian tekan tombol stop",
              ),
            },
          ),
          MenuTile(
            icon: Icons.person_outline,
            title: 'Profil',
            subtitle: '',
            onTap: () => {
              displayHelpMessage(
                context,
                "Profile",
                "Menu ini digunakan untuk melihat profile pengguna yang mengandung username, email, nama lengkap, isi keranjang, pesanan yang dianggap selesai, dan total belanja",
              ),
            },
          ),
          MenuTile(
            icon: Icons.calculate_outlined,
            title: 'Belanjaku - Kalkulator',
            subtitle: '',
            onTap: () => {
              displayHelpMessage(
                context,
                "Kalkulator",
                "Menu ini digunakkan untuk menghitung total harga berdasarkan barang yang ada dikeranjang. Untuk menggunakannya pertama tambahkan item dengan menekan tombol tambah item di bawah dan isi formulir data barang yang ingin ditambahkan. Setelah itu, tekan tombol tambah item untuk memasukkan ke dalam keranjang dan harga dari barang yang ada di keranjang akan di hitung secara otomatis oleh sistem",
              ),
            },
          ),
          MenuTile(
            icon: Icons.list_alt_outlined,
            title: 'Belanjaku - Daftar Pesanan',
            subtitle: '',
            onTap: () => {
              displayHelpMessage(
                context,
                "Daftar pesanan",
                "Menu ini digunakkan untuk melihat status pengiriman barang yang belum dianggap selesai. Di menu ini anda bisa melihat detail pesanan seperti harga, tanggal pemesanan, dan lain-lain dengan cara menekan card di dalam list barang",
              ),
            },
          ),
          MenuTile(
            icon: Icons.calendar_month_outlined,
            title: 'Konversi Tanggal',
            subtitle: '',
            onTap: () => {
              displayHelpMessage(
                context,
                "Konversi Tanggal",
                "Pada menu ini anda dapat melakukan konversi tanggal hijriah, weton, dan saka bali serta menghitung umur berdasarkan tanggal lahir",
              ),
            },
          ),
        ],
      ),
    );
  }
}
