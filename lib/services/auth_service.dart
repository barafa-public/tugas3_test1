import 'package:supabase_flutter/supabase_flutter.dart';

/// Service untuk semua operasi autentikasi: registrasi, login pakai
/// username, logout, dan cek sesi yang sedang aktif.
class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Registrasi user baru.
  /// `username` dan `fullName` dikirim sebagai metadata ke Supabase Auth,
  /// lalu otomatis disalin ke tabel `profiles` oleh trigger database
  /// `on_auth_user_created` (lihat schema_shopping_list_v2.sql).
  Future<AuthResponse> signUp({
    required String username,
    required String fullName,
    required String email,
    required String password,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: {'username': username, 'full_name': fullName},
    );
  }

  /// Login pakai username (bukan email langsung).
  /// Karena Supabase Auth berbasis email, kita cari dulu email yang
  /// terhubung dengan username lewat RPC `get_email_by_username`
  /// (lihat patch_username_login.sql), baru submit ke signInWithPassword.
  Future<AuthResponse> signInWithUsername({
    required String username,
    required String password,
  }) async {
    final email = await _getEmailByUsername(username);

    if (email == null) {
      throw const AuthException('Username tidak ditemukan');
    }

    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<String?> _getEmailByUsername(String username) async {
    final result = await _client.rpc(
      'get_email_by_username',
      params: {'p_username': username},
    );
    return result as String?;
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Sesi yang sedang aktif, null kalau belum login.
  Session? get currentSession => _client.auth.currentSession;

  User? get currentUser => _client.auth.currentUser;

  /// Stream perubahan status auth, berguna kalau nanti mau dengarkan
  /// perubahan login/logout secara reaktif.
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
}
