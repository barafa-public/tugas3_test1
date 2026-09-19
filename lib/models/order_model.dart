/// Status pesanan di tabel `orders`.
/// Dibatasi database lewat check constraint `orders_status_check`:
/// hanya boleh `'cart'` atau `'completed'`.
///
/// - [cart]: item masih di "keranjang" / belum selesai diterima
///   (dipakai di tab Kalkulator & Daftar Pesanan).
/// - [completed]: pesanan sudah selesai diterima (masuk History).
enum OrderStatus { cart, completed }

extension OrderStatusValue on OrderStatus {
  /// Nilai persis yang tersimpan di kolom `status` pada database.
  String get value {
    switch (this) {
      case OrderStatus.cart:
        return 'cart';
      case OrderStatus.completed:
        return 'completed';
    }
  }

  static OrderStatus fromValue(String value) {
    switch (value) {
      case 'completed':
        return OrderStatus.completed;
      case 'cart':
      default:
        return OrderStatus.cart;
    }
  }
}

/// Model untuk baris tabel `orders`.
class OrderModel {
  final String id;
  final String userId;
  final String? categoryId;

  /// Nama kategori, diisi kalau query-nya join ke tabel `categories`
  /// (lihat `OrderService`). Null kalau tidak di-join atau `categoryId`
  /// memang kosong.
  final String? categoryName;

  final String name;
  final int quantity;
  final double price;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;

  OrderModel({
    required this.id,
    required this.userId,
    this.categoryId,
    this.categoryName,
    required this.name,
    required this.quantity,
    required this.price,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
  });

  /// Subtotal item ini = harga satuan x jumlah.
  double get subtotal => price * quantity;

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    // Kalau query pakai `.select('*, categories(id, name)')`, Supabase
    // mengembalikan relasi ini sebagai nested map di key 'categories'.
    final categoryMap = map['categories'] as Map<String, dynamic>?;

    return OrderModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      categoryId: map['category_id'] as String?,
      categoryName: categoryMap?['name'] as String?,
      name: map['name'] as String,
      quantity: (map['quantity'] as num).toInt(),
      price: (map['price'] as num).toDouble(),
      status: OrderStatusValue.fromValue(map['status'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      completedAt: map['completed_at'] != null
          ? DateTime.parse(map['completed_at'] as String)
          : null,
    );
  }

  OrderModel copyWith({
    String? categoryId,
    String? categoryName,
    String? name,
    int? quantity,
    double? price,
    OrderStatus? status,
  }) {
    return OrderModel(
      id: id,
      userId: userId,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt,
      completedAt: completedAt,
    );
  }
}
