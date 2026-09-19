import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:tugas3_test/models/category_model.dart';

/// Service untuk operasi CRUD ke tabel `categories`.
/// Kategori dipakai buat mengelompokkan item pesanan (mis. "Sembako").
class CategoryService {
  final SupabaseClient _client = Supabase.instance.client;

  String get _uid {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) {
      throw StateError('User belum login, tidak bisa akses kategori.');
    }
    return uid;
  }

  /// Ambil semua kategori milik user yang sedang login, urut abjad.
  Future<List<CategoryModel>> getCategories() async {
    final data = await _client
        .from('categories')
        .select()
        .eq('user_id', _uid)
        .order('name', ascending: true);

    return (data as List)
        .map((e) => CategoryModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Bikin kategori baru dengan [name].
  Future<CategoryModel> createCategory(String name) async {
    final data = await _client
        .from('categories')
        .insert({'user_id': _uid, 'name': name.trim()})
        .select()
        .single();

    return CategoryModel.fromMap(data);
  }

  /// Ubah nama kategori [id] menjadi [name].
  Future<CategoryModel> updateCategory({
    required String id,
    required String name,
  }) async {
    final data = await _client
        .from('categories')
        .update({'name': name.trim()})
        .eq('id', id)
        .eq('user_id', _uid)
        .select()
        .single();

    return CategoryModel.fromMap(data);
  }

  /// Hapus kategori [id].
  ///
  /// Catatan: kolom `orders.category_id` pakai `ON DELETE SET NULL`,
  /// jadi item pesanan yang masih pakai kategori ini TIDAK ikut kehapus,
  /// hanya kategorinya jadi kosong (null).
  Future<void> deleteCategory(String id) async {
    await _client.from('categories').delete().eq('id', id).eq('user_id', _uid);
  }
}
