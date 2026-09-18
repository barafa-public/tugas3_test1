import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/proflie_model.dart';

/// Service untuk mengambil data profil user yang login dan ringkasan
/// dashboard belanjanya (dari view `dashboard_summary`).
class ProfileService {
  final SupabaseClient _client = Supabase.instance.client;

  String get _uid {
    final id = _client.auth.currentUser?.id;
    if (id == null) {
      throw StateError('Tidak ada user yang sedang login');
    }
    return id;
  }

  /// Ambil data dasar profil (username, nama lengkap, tanggal daftar).
  Future<ProfileModel> getMyProfile() async {
    final data = await _client
        .from('profiles')
        .select()
        .eq('id', _uid)
        .single();
    return ProfileModel.fromMap(data);
  }

  /// Ambil ringkasan dashboard: jumlah item di keranjang, pesanan selesai,
  /// total pengeluaran, dan sisa budget periode berjalan (kalau ada).
  Future<DashboardSummary> getMyDashboardSummary() async {
    final data = await _client
        .from('dashboard_summary')
        .select()
        .eq('user_id', _uid)
        .single();
    return DashboardSummary.fromMap(data);
  }
}
