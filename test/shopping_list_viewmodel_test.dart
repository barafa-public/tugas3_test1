import 'package:flutter_test/flutter_test.dart';
import 'package:tugas3_test/infrastructure/inmemory_product_repository.dart';
import 'package:tugas3_test/pages/daftar_pesanan/entity/product.dart';
import 'package:tugas3_test/pages/daftar_pesanan/entity/product_status.dart';
import 'package:tugas3_test/pages/daftar_pesanan/shopping_list_viewmodel.dart';

InmemoryProductRepository repo = InmemoryProductRepository(1);
ShoppingListViewmodel viewModel = ShoppingListViewmodel(repo);

void main() {
  setUp(() {
    repo = InmemoryProductRepository(1);
    viewModel = ShoppingListViewmodel(repo);
  });

  test("when repository is still fetching, should be in loading state", () {
    repo.insert(Product(name: "flores bajawa", status: ProductStatus.finished));

    final _ = viewModel.displayCardDataAsync();

    expect(viewModel.isLoading, true);
  });

  test(
    "when repository finishes fetching, should not be in loading state",
    () async {
      repo.insert(
        Product(name: "flores bajawa", status: ProductStatus.finished),
      );

      final _ = await viewModel.displayCardDataAsync();

      expect(viewModel.isLoading, false);
    },
  );

  test("when displaying card data, should show status and name", () async {
    repo.insert(
      Product(name: "flores bajawa", status: ProductStatus.processed),
    );

    final cardData = await viewModel.displayCardDataAsync();

    expect(cardData.first.name, "flores bajawa");
    expect(cardData.first.status, ProductStatus.processed);
  });

  test("error should exists when trying to display card data to an item that has no name", () async {
    repo.insert(Product(status: ProductStatus.finished));

    final _ = await viewModel.displayCardDataAsync();

    assert(viewModel.error != null);
    assert(viewModel.error != "");
  });

  test("error should exists when trying to display card data to an item that has no status", () async {
    repo.insert(Product(name: "flores bajawa"));

    final _ = await viewModel.displayCardDataAsync();

    assert(viewModel.error != null);
    assert(viewModel.error != "");
  });

  test("when orders list is empty, should not display error message", () async {
    final _ = await viewModel.displayCardDataAsync();

    assert(viewModel.error == "" || viewModel.error == null);
  });

  test("any orders that are finished, should not be in the list", () async {
    repo.insert(Product(name: "flores bajawa", status: ProductStatus.finished));
    final cardData = await viewModel.displayCardDataAsync();

    assert(
      cardData.any((product) => product.status == ProductStatus.finished) ==
          false,
    );
  });
}
