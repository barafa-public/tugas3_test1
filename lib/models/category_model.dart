/// Model untuk baris tabel `categories`.
/// Kategori dipakai untuk mengelompokkan item di `orders`
/// (mis. "Sembako", "Perawatan", "Elektronik", dll).
class CategoryModel {
  final String id;
  final String userId;
  final String name;
  final DateTime createdAt;

  CategoryModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.createdAt,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      name: map['name'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
