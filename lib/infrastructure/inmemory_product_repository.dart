import 'package:tugas3_test/pages/daftar_pesanan/entity/product.dart';

class InmemoryProductRepository {
  List<Product> rows = [];

  void insert(Product product) {
    rows.add(product);
  }
}
