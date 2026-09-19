import 'package:tugas3_test/pages/daftar_pesanan/entity/product.dart';
import 'package:uuid/uuid.dart';

abstract interface class ProductRepositoryInterface {
  void insert(Product product);

  Future<Product?> getbyIdAsync(Uuid productId);

  Future<List<Product>> getAllAsync();
}
