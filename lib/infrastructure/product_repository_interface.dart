import 'package:tugas3_test/pages/daftar_pesanan/entity/product.dart';

abstract interface class ProductRepositoryInterface {
  void insert(Order product);

  Future<Order?> getbyIdAsync(String productId);

  Future<List<Order>> getAllAsync();

  Future<void> update(Order updatedOrder);
}
