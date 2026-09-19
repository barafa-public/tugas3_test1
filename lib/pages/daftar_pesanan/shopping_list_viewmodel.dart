import 'package:tugas3_test/infrastructure/product_repository_interface.dart';
import 'package:tugas3_test/pages/daftar_pesanan/entity/product.dart';
import 'package:tugas3_test/pages/daftar_pesanan/entity/product_status.dart';
import 'package:tugas3_test/pages/daftar_pesanan/value_object/shoppinglist_card_data.dart';

class ShoppingListViewmodel {
  var isLoading = true;
  var error = "";

  ProductRepositoryInterface repo;

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

    return productList
        .where((product) => product.status != ProductStatus.finished)
        .toList();
  }
}
