import 'package:flutter/material.dart';
import 'package:tugas3_test/infrastructure/inmemory_product_repository.dart';
import 'package:tugas3_test/pages/daftar_pesanan/entity/product.dart';
import 'package:tugas3_test/pages/daftar_pesanan/entity/status_enum.dart';
import 'package:tugas3_test/pages/daftar_pesanan/widget/item_card_widget.dart';
import 'package:uuid/uuid.dart';

class ShoppingListPageWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ShoppingListPageWidgetState();
}

void showProductDetail(BuildContext context, Product product) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    enableDrag: true,
    isDismissible: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (BuildContext sheetContext) => DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.25,
      maxChildSize: 0.9,
      expand: false,
      snap: true,
      snapSizes: const [0.25, 0.5, 0.9],
      builder: (BuildContext context, ScrollController scrollController) =>
          SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [Text(product.name)],
              ),
            ),
          ),
    ),
  );
}

class _ShoppingListPageWidgetState extends State<ShoppingListPageWidget> {
  // final repository = InmemoryProductRepository();
  final product = Product(name: "Flores bajawa", status: ProductStatus.unset);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ItemCardWidget(product, (id) => showProductDetail(context, product)),
      ],
    );
  }
}
