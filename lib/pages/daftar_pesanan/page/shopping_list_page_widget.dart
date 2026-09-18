import 'package:flutter/material.dart';
import 'package:tugas3_test/infrastructure/inmemory_product_repository.dart';
import 'package:tugas3_test/pages/daftar_pesanan/entity/product.dart';
import 'package:tugas3_test/pages/daftar_pesanan/entity/product_status.dart';
import 'package:tugas3_test/pages/daftar_pesanan/shopping_list_viewmodel.dart';
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
                children: [
                  Text(product.name, style: TextStyle(fontSize: 25)),
                  Text("unset", style: TextStyle(fontSize: 12)),
                  Text(
                    "tanggal pemesanan ${product.createdAt ?? DateTime.now()}",
                    style: TextStyle(fontSize: 12),
                  ),
                  Text(
                    "terakhir di update pada tanggal ${product.updatedAt ?? DateTime.now()}",
                    style: TextStyle(fontSize: 12),
                  ),

                  Text(
                    "tanggal dikirim ${product.completedAt ?? DateTime.now()}",
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
    ),
  );
}

class _ShoppingListPageWidgetState extends State<ShoppingListPageWidget> {
  late InmemoryProductRepository repository;
  late ShoppingListViewmodel viewModel;

  var cardData = [];

  Future<void> _loadCardList() async {
    repository = InmemoryProductRepository();

    repository.insert(
      Product(name: "flores bajawa", status: ProductStatus.finished),
    );

    viewModel = ShoppingListViewmodel(repository);

    cardData = await viewModel.displayCardDataAsync();

    if (!mounted) return;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _loadCardList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ItemCardWidget(product, (id) => showProductDetail(context, product)),
        ...cardData.map(
          (product) => ItemCardWidget(
            product,
            (id) => showProductDetail(context, product),
          ),
        ),
      ],
    );
  }
}
