import 'package:tugas3_test/infrastructure/product_repository_interface.dart';
import 'package:tugas3_test/pages/daftar_pesanan/entity/product.dart';

class InmemoryProductRepository implements ProductRepositoryInterface {
  InmemoryProductRepository(this.loadingTimeInMiliseconds);
  List<Order> rows = [];
  int loadingTimeInMiliseconds;

  @override
  void insert(Order product) {
    rows.add(product);
  }

  @override
  Future<Order?> getbyIdAsync(String productId) async {
    await Future.pause(Duration(milliseconds: loadingTimeInMiliseconds));
    return rows.where((product) => product.id == productId).first;
  }

  @override
  Future<List<Order>> getAllAsync() async {
    await Future.pause(Duration(milliseconds: loadingTimeInMiliseconds));

    return rows;
  }

  @override
  Future<void> update(Order updatedOrder) async {
    rows.map((order) {
      if (order.id != updatedOrder.id) {
        return;
      }

      order = updatedOrder;
    });
  }
}
