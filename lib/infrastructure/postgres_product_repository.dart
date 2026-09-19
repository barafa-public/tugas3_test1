import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tugas3_test/infrastructure/product_repository_interface.dart';
import 'package:tugas3_test/pages/daftar_pesanan/entity/product.dart';
import 'package:tugas3_test/pages/daftar_pesanan/entity/product_status.dart';

class PostgresProductRepository implements ProductRepositoryInterface {
  @override
  Future<List<Order>> getAllAsync() async {
    final session = await Supabase.instance.client.auth.getSession();

    final rows = await Supabase.instance.client
        .from("orders")
        .select()
        .eq("user_id", session!.user.id);

    final orders = rows
        .map(
          (row) => Order(
            id: row["id"] as String,
            name: row["name"],
            quantity: row["quantity"],
            status: ProductStatusfromString(row["status"]),
            price: row["price"],
            createdAt: DateTime.parse(row["created_at"]),
            updatedAt: DateTime.parse(row["updated_at"]),
            completedAt:
                row["completed_at"] == "" || row["completed_at"] == null
                ? null
                : DateTime.parse(row["completed_at"]),
          ),
        )
        .toList();

    return orders;
  }

  @override
  Future<Order?> getbyIdAsync(String productId) async {
    final session = await Supabase.instance.client.auth.getSession();

    final rows = await Supabase.instance.client
        .from("orders")
        .select()
        .eq("user_id", session!.user.id)
        .eq("id", productId);

    final orders = rows
        .map(
          (row) => Order(
            id: row["id"] as String,
            name: row["name"],
            quantity: row["quantity"],
            status: ProductStatusfromString(row["status"]),
            price: row["price"],
            createdAt: DateTime.parse(row["created_at"]),
            updatedAt: DateTime.parse(row["updated_at"]),
            completedAt:
                row["completed_at"] == "" || row["completed_at"] == null
                ? null
                : DateTime.parse(row["completed_at"]),
          ),
        )
        .toList();

    if (orders.isEmpty) {
      return null;
    }

    return orders.first;
  }

  @override
  void insert(Order product) {
    // TODO: implement insert
    throw UnimplementedError();
  }

  @override
  Future<void> update(Order updatedOrder) async {
    await Supabase.instance.client
        .from("orders")
        .update({
          "name": updatedOrder.name,
          "quantity": updatedOrder.quantity,
          "price": updatedOrder.price,
          "status": updatedOrder.status.getDisplayString(),
          "updated_at": updatedOrder.updatedAt?.toIso8601String(),
          "completed_at": updatedOrder.completedAt?.toIso8601String(),
        })
        .eq("id", updatedOrder.id);
  }
}
