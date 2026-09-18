import 'package:tugas3_test/infrastructure/inmemory_product_repository.dart';
import 'package:tugas3_test/pages/daftar_pesanan/entity/product.dart';
import 'package:tugas3_test/pages/daftar_pesanan/entity/product_status.dart';
import 'package:tugas3_test/pages/daftar_pesanan/value_object/shoppinglist_card_data.dart';
import 'package:uuid/uuid.dart';

class ShoppingListViewmodel {
  var isLoading = true;
  var error = "";

  InmemoryProductRepository repo;

  ShoppingListViewmodel(this.repo);

  ShoppinglistCardData toCardData(Product product) {
    return ShoppinglistCardData(
      product.name,
      product.status.getDisplayString(),
    );
  }

  Future<List<Product>> displayCardDataAsync() async {
    final productList = await repo.getAllAsync();
    isLoading = false;

    if (productList.any((product) => product.name == "")) {
      error = "a certain product has no name provided";
    }

    if (productList.any((product) => product.status == ProductStatus.unset)) {
      error = "a certain product has no status specified";
    }

    return productList;
  }
}
