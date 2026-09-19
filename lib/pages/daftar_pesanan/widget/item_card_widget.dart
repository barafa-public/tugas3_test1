import 'package:flutter/material.dart';
import 'package:tugas3_test/pages/daftar_pesanan/entity/product.dart';
import 'package:tugas3_test/pages/daftar_pesanan/widget/status_chip_widget.dart';
import 'package:tugas3_test/utils/currency_formatter.dart';
import 'package:uuid/uuid.dart';

class ItemCardWidget extends StatelessWidget {
  const ItemCardWidget(this.product, this.onTap, {super.key});

  final Order product;
  final void Function(Uuid productId) onTap;

  // Local-only styling to match _MenuTile in home_page.dart.
  static const _contentPadding = EdgeInsets.symmetric(
    horizontal: 16.0,
    vertical: 8.0,
  );
  static const _titleStyle = TextStyle(fontWeight: FontWeight.w600);
  static const _detailStyle = TextStyle(fontSize: 12, color: Colors.grey);

  String _subtitleText() {
    final datePart = product.createdAt == null
        ? '-'
        : formatTanggalPendek(product.createdAt!);
    return 'Jumlah ${product.quantity} \u2022 ${formatRupiah(product.price)} \u2022 $datePart';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: _contentPadding,
        leading: CircleAvatar(
          backgroundColor: Colors.deepPurple.shade50,
          child: const Icon(
            Icons.shopping_bag_outlined,
            color: Colors.deepPurple,
          ),
        ),
        title: Text(
          product.name,
          style: _titleStyle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 6),
            StatusChipWidget(product.status),
            const SizedBox(height: 6),
            Text(
              _subtitleText(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _detailStyle,
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => onTap(product.id),
      ),
    );
  }
}
