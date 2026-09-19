import 'package:tugas3_test/infrastructure/product_repository_interface.dart';
import 'package:tugas3_test/pages/daftar_pesanan/entity/product.dart';
import 'package:uuid/uuid.dart';

class InmemoryProductRepository implements ProductRepositoryInterface {
  InmemoryProductRepository(this.loadingTimeInSecond);
  List<Product> rows = [];
  int loadingTimeInSecond;

  @override
  void insert(Product product) {
    rows.add(product);
  }

  @override
  Future<Product?> getbyIdAsync(Uuid productId) async {
    await Future.pause(Duration(seconds: loadingTimeInSecond));
    return rows.where((product) => product.id == productId).first;
  }

  @override
  Future<List<Product>> getAllAsync() async {
    await Future.pause(Duration(seconds: loadingTimeInSecond));

    return rows;
  }
}
