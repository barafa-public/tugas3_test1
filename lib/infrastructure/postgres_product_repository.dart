import 'package:tugas3_test/infrastructure/product_repository_interface.dart';
import 'package:tugas3_test/pages/daftar_pesanan/entity/product.dart';
import 'package:uuid/uuid.dart';

class PostgresProductRepository implements ProductRepositoryInterface {
  @override
  Future<List<Product>> getAllAsync() {
    // TODO: implement getAllAsync
    throw UnimplementedError();
  }

  @override
  Future<Product?> getbyIdAsync(Uuid productId) {
    // TODO: implement getbyIdAsync
    throw UnimplementedError();
  }

  @override
  void insert(Product product) {
    // TODO: implement insert
  }
}
