import 'package:tugas3_test/pages/daftar_pesanan/entity/product_status.dart';
import 'package:uuid/uuid.dart';

class Order {
  Uuid id = Uuid();
  String name = "";
  int quantity = 0;
  double price = 0;
  ProductStatus status = ProductStatus.unset;
  DateTime? createdAt = DateTime.now();
  DateTime? updatedAt = DateTime.now();
  DateTime? completedAt = DateTime.now();

  Order({
    this.id = const Uuid(),
    this.name = "",
    this.quantity = 0,
    this.price = 0,
    this.status = ProductStatus.unset,
    this.createdAt,
    this.updatedAt,
    this.completedAt,
  });
}
