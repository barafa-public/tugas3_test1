import 'package:flutter/material.dart';

/// Model produk pada katalog "produk sehari-hari" yang ditampilkan di
/// Menu Pesanan.
///
/// Ini BUKAN tabel di database — katalog ini murni data statis di sisi
/// aplikasi (harga cuma perkiraan/default), supaya user bisa "memilih"
/// produk seperti di aplikasi belanja pada umumnya, alih-alih mengetik
/// manual nama & harga barang setiap kali mau memesan. Saat user memilih
/// produk + jumlah, baru dibuatkan baris baru di tabel `orders` (status
/// `cart`) lewat [OrderService.createOrder].
class ProductCatalogItem {
  final String id;
  final String name;
  final double price;
  final String unit;
  final String category;
  final IconData icon;

  const ProductCatalogItem({
    required this.id,
    required this.name,
    required this.price,
    required this.unit,
    required this.category,
    required this.icon,
  });
}

/// Daftar produk sehari-hari, dikelompokkan per kategori.
///
/// Harga adalah perkiraan default dan bisa diedit user nanti lewat form
/// edit item di Menu Pesanan / Daftar Pesanan kalau memang tidak sesuai.
const List<ProductCatalogItem> kProductCatalog = [
  // --- Sembako ---
  ProductCatalogItem(
    id: 'beras-5kg',
    name: 'Beras 5kg',
    price: 65000,
    unit: 'karung',
    category: 'Sembako',
    icon: Icons.rice_bowl_outlined,
  ),
  ProductCatalogItem(
    id: 'minyak-goreng-2l',
    name: 'Minyak Goreng 2L',
    price: 34000,
    unit: 'botol',
    category: 'Sembako',
    icon: Icons.local_drink_outlined,
  ),
  ProductCatalogItem(
    id: 'gula-pasir-1kg',
    name: 'Gula Pasir 1kg',
    price: 16000,
    unit: 'bungkus',
    category: 'Sembako',
    icon: Icons.icecream_outlined,
  ),
  ProductCatalogItem(
    id: 'telur-ayam-1kg',
    name: 'Telur Ayam 1kg',
    price: 29000,
    unit: 'kg',
    category: 'Sembako',
    icon: Icons.egg_outlined,
  ),
  ProductCatalogItem(
    id: 'garam-dapur',
    name: 'Garam Dapur',
    price: 5000,
    unit: 'bungkus',
    category: 'Sembako',
    icon: Icons.grain_outlined,
  ),
  ProductCatalogItem(
    id: 'tepung-terigu-1kg',
    name: 'Tepung Terigu 1kg',
    price: 13000,
    unit: 'bungkus',
    category: 'Sembako',
    icon: Icons.bakery_dining_outlined,
  ),

  // --- Makanan & Minuman ---
  ProductCatalogItem(
    id: 'mie-instan',
    name: 'Mie Instan',
    price: 3500,
    unit: 'bungkus',
    category: 'Makanan & Minuman',
    icon: Icons.ramen_dining_outlined,
  ),
  ProductCatalogItem(
    id: 'roti-tawar',
    name: 'Roti Tawar',
    price: 15000,
    unit: 'bungkus',
    category: 'Makanan & Minuman',
    icon: Icons.breakfast_dining_outlined,
  ),
  ProductCatalogItem(
    id: 'susu-uht-1l',
    name: 'Susu UHT 1L',
    price: 18000,
    unit: 'kotak',
    category: 'Makanan & Minuman',
    icon: Icons.local_cafe_outlined,
  ),
  ProductCatalogItem(
    id: 'kopi-sachet',
    name: 'Kopi Sachet',
    price: 2000,
    unit: 'pcs',
    category: 'Makanan & Minuman',
    icon: Icons.coffee_outlined,
  ),
  ProductCatalogItem(
    id: 'teh-celup',
    name: 'Teh Celup (1 kotak)',
    price: 12000,
    unit: 'kotak',
    category: 'Makanan & Minuman',
    icon: Icons.emoji_food_beverage_outlined,
  ),
  ProductCatalogItem(
    id: 'air-mineral-600ml',
    name: 'Air Mineral 600ml',
    price: 4000,
    unit: 'botol',
    category: 'Makanan & Minuman',
    icon: Icons.water_drop_outlined,
  ),
  ProductCatalogItem(
    id: 'kecap-manis',
    name: 'Kecap Manis',
    price: 14000,
    unit: 'botol',
    category: 'Makanan & Minuman',
    icon: Icons.soup_kitchen_outlined,
  ),

  // --- Kebutuhan Rumah Tangga ---
  ProductCatalogItem(
    id: 'sabun-mandi',
    name: 'Sabun Mandi',
    price: 6000,
    unit: 'batang',
    category: 'Kebutuhan Rumah Tangga',
    icon: Icons.soap_outlined,
  ),
  ProductCatalogItem(
    id: 'shampoo-sachet',
    name: 'Shampoo Sachet',
    price: 1000,
    unit: 'pcs',
    category: 'Kebutuhan Rumah Tangga',
    icon: Icons.bathtub_outlined,
  ),
  ProductCatalogItem(
    id: 'pasta-gigi',
    name: 'Pasta Gigi',
    price: 11000,
    unit: 'tube',
    category: 'Kebutuhan Rumah Tangga',
    icon: Icons.clean_hands_outlined,
  ),
  ProductCatalogItem(
    id: 'sabun-cuci-piring',
    name: 'Sabun Cuci Piring',
    price: 9000,
    unit: 'botol',
    category: 'Kebutuhan Rumah Tangga',
    icon: Icons.wash_outlined,
  ),
  ProductCatalogItem(
    id: 'deterjen-1kg',
    name: 'Deterjen 1kg',
    price: 22000,
    unit: 'bungkus',
    category: 'Kebutuhan Rumah Tangga',
    icon: Icons.local_laundry_service_outlined,
  ),
  ProductCatalogItem(
    id: 'tisu',
    name: 'Tisu',
    price: 12000,
    unit: 'bungkus',
    category: 'Kebutuhan Rumah Tangga',
    icon: Icons.inventory_2_outlined,
  ),
];
