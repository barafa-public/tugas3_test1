import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:tugas3_test/models/order_model.dart';

/// Service untuk operasi CRUD ke tabel `orders`.
///
/// Dipakai bareng-bareng oleh:
/// - Tab Kalkulator (Menu Pesanan): input item baru -> status `cart`.
/// - Tab Daftar Pesanan (punya Fariz): lihat & selesaikan item `cart`.
class OrderService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Select dengan join ke categories, biar `OrderModel.categoryName`
  /// otomatis terisi tanpa query tambahan.
  static const String _selectWithCategory = '*, categories(id, name)';

  String get _uid {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) {
      throw StateError('User belum login, tidak bisa akses pesanan.');
    }
    return uid;
  }

  /// Ambil daftar pesanan milik user yang sedang login.
  /// Kalau [status] diisi, hasil difilter sesuai status itu saja.
  Future<List<OrderModel>> getOrders({OrderStatus? status}) async {
    PostgrestFilterBuilder query = _client
        .from('orders')
        .select(_selectWithCategory)
        .eq('user_id', _uid);

    if (status != null) {
      query = query.eq('status', status.value);
    }

    final data = await query.order('created_at', ascending: false);

    return (data as List)
        .map((e) => OrderModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Total belanja (harga x qty) untuk semua item dengan status `cart`.
  /// Dipakai buat "kalkulator" di tab Menu Pesanan.
  Future<double> getCartTotal() async {
    final items = await getOrders(status: OrderStatus.cart);
    return items.fold<double>(0, (sum, item) => sum + item.subtotal);
  }

  /// Tambah item pesanan baru. Status otomatis `cart` (default di database).
  Future<OrderModel> createOrder({
    required String name,
    required int quantity,
    required double price,
    String? categoryId,
  }) async {
    final data = await _client
        .from('orders')
        .insert({
          'user_id': _uid,
          'name': name.trim(),
          'quantity': quantity,
          'price': price,
          'category_id': categoryId,
        })
        .select(_selectWithCategory)
        .single();

    return OrderModel.fromMap(data);
  }

  /// Ubah data item pesanan [id] (nama, jumlah, harga, kategori).
  /// Tidak mengubah status — pakai [markCompleted]/[markAsCart] untuk itu.
  Future<OrderModel> updateOrder({
    required String id,
    required String name,
    required int quantity,
    required double price,
    String? categoryId,
  }) async {
    final data = await _client
        .from('orders')
        .update({
          'name': name.trim(),
          'quantity': quantity,
          'price': price,
          'category_id': categoryId,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id)
        .eq('user_id', _uid)
        .select(_selectWithCategory)
        .single();

    return OrderModel.fromMap(data);
  }

  /// Tandai pesanan [id] sudah selesai diterima -> pindah ke History.
  Future<OrderModel> markCompleted(String id) async {
    final data = await _client
        .from('orders')
        .update({
          'status': OrderStatus.completed.value,
          'completed_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id)
        .eq('user_id', _uid)
        .select(_selectWithCategory)
        .single();

    return OrderModel.fromMap(data);
  }

  /// Kembalikan pesanan [id] yang sudah selesai ke keranjang (`cart`)
  /// — buat kasus salah pencet / batal terima.
  Future<OrderModel> markAsCart(String id) async {
    final data = await _client
        .from('orders')
        .update({
          'status': OrderStatus.cart.value,
          'completed_at': null,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id)
        .eq('user_id', _uid)
        .select(_selectWithCategory)
        .single();

    return OrderModel.fromMap(data);
  }

  /// Hapus item pesanan [id].
  Future<void> deleteOrder(String id) async {
    await _client.from('orders').delete().eq('id', id).eq('user_id', _uid);
  }
}
