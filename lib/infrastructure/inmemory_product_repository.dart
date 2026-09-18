import 'package:tugas3_test/pages/daftar_pesanan/entity/product.dart';
import 'package:uuid/uuid.dart';

class InmemoryProductRepository {
  List<Product> rows = [];

  void insert(Product product) {
    rows.add(product);
  }

  Future<Product?> getbyIdAsync(Uuid productId) async {
    Future.pause(Duration(seconds: 2));
    return rows.where((product) => product.id == productId).first;
  }

  Future<List<Product>> getAllAsync() async {
    Future.pause(Duration(seconds: 2));

    return rows;
  }
}
