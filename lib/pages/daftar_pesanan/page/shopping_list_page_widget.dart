import 'package:flutter/material.dart';
import 'package:tugas3_test/infrastructure/inmemory_product_repository.dart';
import 'package:tugas3_test/infrastructure/postgres_product_repository.dart';
import 'package:tugas3_test/infrastructure/product_repository_interface.dart';
import 'package:tugas3_test/pages/daftar_pesanan/entity/product.dart';
import 'package:tugas3_test/pages/daftar_pesanan/entity/product_status.dart';
import 'package:tugas3_test/pages/daftar_pesanan/shopping_list_viewmodel.dart';
import 'package:tugas3_test/pages/daftar_pesanan/widget/app_bottom_sheet.dart';
import 'package:tugas3_test/pages/daftar_pesanan/widget/item_card_widget.dart';
import 'package:tugas3_test/pages/daftar_pesanan/widget/status_chip_widget.dart';
import 'package:tugas3_test/utils/currency_formatter.dart';

class ShoppingListPageWidget extends StatefulWidget {
  const ShoppingListPageWidget({super.key});

  @override
  State<StatefulWidget> createState() => _ShoppingListPageWidgetState();
}

void showProductDetail(
  BuildContext context,
  Order order,
  ShoppingListViewmodel viewModel, {
  required Future<void> Function() onFinished,
}) {
  showAppBottomSheet<void>(
    context: context,
    child: Builder(
      builder: (BuildContext innerContext) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
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
                  order.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              StatusChipWidget(order.status),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),
          _DetailRow(
            icon: Icons.inventory_2_outlined,
            label: 'Jumlah',
            value: '${order.quantity}',
          ),
          const SizedBox(height: 12),
          _DetailRow(
            icon: Icons.payments_outlined,
            label: 'Harga satuan',
            value: formatRupiah(order.price),
          ),
          const SizedBox(height: 12),
          _DetailRow(
            icon: Icons.calendar_month_outlined,
            label: 'Tanggal pemesanan',
            value: order.createdAt == null
                ? '-'
                : formatTanggalPendek(order.createdAt!),
          ),
          const SizedBox(height: 12),
          _DetailRow(
            icon: Icons.update_outlined,
            label: 'Terakhir diupdate',
            value: order.updatedAt == null
                ? '-'
                : formatTanggalPendek(order.updatedAt!),
          ),
          const SizedBox(height: 12),
          _DetailRow(
            icon: Icons.local_shipping_outlined,
            label: 'Tanggal dikirim',
            value: order.completedAt == null
                ? '-'
                : formatTanggalPendek(order.completedAt!),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(innerContext).pop(),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Tutup'),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    await viewModel.markAsFinished(order);
                    if (innerContext.mounted) {
                      Navigator.of(innerContext).pop();
                    }
                    await onFinished();
                  },
                  child: const Text("selesai"),
                ),
              ),
            ],
          ),
        ],
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
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
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
  late ProductRepositoryInterface repository;
  ShoppingListViewmodel? viewModel;

  var cardData = <Order>[];

  Future<void> _loadCardList() async {
    final useInMemory = false;
    repository = useInMemory
        // ignore: dead_code
        ? InmemoryProductRepository(5000)
        // ignore: dead_code
        : PostgresProductRepository();

    viewModel = ShoppingListViewmodel(repository);

    await _refreshCardList();
  }

  Future<void> _refreshCardList() async {
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
          (id) => showProductDetail(
            context,
            product,
            viewModel!,
            onFinished: _refreshCardList,
          ),
        );
      },
    );
  }
}
