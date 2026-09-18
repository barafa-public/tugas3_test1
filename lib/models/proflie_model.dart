/// Model untuk baris tabel `profiles`.
class ProfileModel {
  final String id;
  final String username;
  final String fullName;
  final DateTime createdAt;

  ProfileModel({
    required this.id,
    required this.username,
    required this.fullName,
    required this.createdAt,
  });

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      id: map['id'] as String,
      username: map['username'] as String,
      fullName: map['full_name'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}

/// Model untuk view `dashboard_summary`.
/// Dipakai di halaman Profil untuk menampilkan ringkasan belanja user:
/// jumlah item di keranjang, pesanan selesai, total pengeluaran, dan
/// sisa budget periode berjalan (kalau ada budget yang aktif).
class DashboardSummary {
  final String userId;
  final String username;
  final String fullName;
  final int totalDiKeranjang;
  final int totalPesananSelesai;
  final double totalPengeluaran;

  /// Null kalau user belum punya budget untuk periode saat ini.
  final double? budgetAmount;
  final DateTime? periodStart;
  final DateTime? periodEnd;
  final double? sisaBudget;

  DashboardSummary({
    required this.userId,
    required this.username,
    required this.fullName,
    required this.totalDiKeranjang,
    required this.totalPesananSelesai,
    required this.totalPengeluaran,
    this.budgetAmount,
    this.periodStart,
    this.periodEnd,
    this.sisaBudget,
  });

  bool get hasBudget => budgetAmount != null;

  factory DashboardSummary.fromMap(Map<String, dynamic> map) {
    num? asNum(dynamic v) => v == null ? null : (v as num);
    DateTime? asDate(dynamic v) => v == null ? null : DateTime.parse(v as String);

    return DashboardSummary(
      userId: map['user_id'] as String,
      username: map['username'] as String,
      fullName: map['full_name'] as String,
      totalDiKeranjang: (map['total_di_keranjang'] as num).toInt(),
      totalPesananSelesai: (map['total_pesanan_selesai'] as num).toInt(),
      totalPengeluaran: (asNum(map['total_pengeluaran']) ?? 0).toDouble(),
      budgetAmount: asNum(map['budget_amount'])?.toDouble(),
      periodStart: asDate(map['period_start']),
      periodEnd: asDate(map['period_end']),
      sisaBudget: asNum(map['sisa_budget'])?.toDouble(),
    );
  }
}
