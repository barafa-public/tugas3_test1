import 'package:flutter/material.dart';
import 'package:tugas3_test/infrastructure/inmemory_product_repository.dart';
import 'package:tugas3_test/infrastructure/postgres_product_repository.dart';
import 'package:tugas3_test/pages/daftar_pesanan/entity/product.dart';
import 'package:tugas3_test/pages/daftar_pesanan/entity/product_status.dart';
import 'package:tugas3_test/pages/daftar_pesanan/shopping_list_viewmodel.dart';
import 'package:tugas3_test/pages/daftar_pesanan/widget/item_card_widget.dart';
import 'package:tugas3_test/pages/daftar_pesanan/widget/status_chip_widget.dart';
import 'package:tugas3_test/utils/currency_formatter.dart';

class ShoppingListPageWidget extends StatefulWidget {
  const ShoppingListPageWidget({super.key});

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
              padding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.deepPurple.shade50,
                        child: const Icon(
                          Icons.shopping_bag_outlined,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      StatusChipWidget(product.status),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                  _DetailRow(
                    icon: Icons.inventory_2_outlined,
                    label: 'Jumlah',
                    value: '${product.quantity}',
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(
                    icon: Icons.payments_outlined,
                    label: 'Harga satuan',
                    value: formatRupiah(product.price),
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(
                    icon: Icons.calendar_month_outlined,
                    label: 'Tanggal pemesanan',
                    value: product.createdAt == null
                        ? '-'
                        : formatTanggalPendek(product.createdAt!),
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(
                    icon: Icons.update_outlined,
                    label: 'Terakhir diupdate',
                    value: product.updatedAt == null
                        ? '-'
                        : formatTanggalPendek(product.updatedAt!),
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(
                    icon: Icons.local_shipping_outlined,
                    label: 'Tanggal dikirim',
                    value: product.completedAt == null
                        ? '-'
                        : formatTanggalPendek(product.completedAt!),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Tutup'),
                  ),
                ],
              ),
            ),
          ),
    ),
  );
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ShoppingListPageWidgetState extends State<ShoppingListPageWidget> {
  late InmemoryProductRepository repository;
  ShoppingListViewmodel? viewModel;

  var cardData = <Product>[];

  Future<void> _loadCardList() async {
    final useInMemory = true;
    repository = useInMemory
        ? InmemoryProductRepository(5)
        // ignore: dead_code
        : PostgresProductRepository() as InmemoryProductRepository;

    viewModel = ShoppingListViewmodel(repository);

    repository.insert(
      Product(name: "flores bajawa", status: ProductStatus.finished),
    );

    cardData = await viewModel!.displayCardDataAsync();

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
    final currentViewModel = viewModel;
    if (currentViewModel == null || currentViewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (cardData.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.list_alt_outlined, size: 56, color: Color(0xFFBDBDBD)),
              SizedBox(height: 16),
              Text(
                'Belum ada pesanan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Daftar pesanan kamu masih kosong.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16.0),
      itemCount: cardData.length + 1,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Daftar Pesanan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                '${cardData.length} item',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          );
        }
        final product = cardData[index - 1];
        return ItemCardWidget(
          product,
          (id) => showProductDetail(context, product),
        );
      },
    );
  }
}
