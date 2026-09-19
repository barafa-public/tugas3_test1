import 'package:flutter/material.dart';
import 'package:tugas3_test/pages/daftar_pesanan/entity/product_status.dart';

class StatusChipWidget extends StatelessWidget {
  const StatusChipWidget(this.productStatus, {super.key});

  final ProductStatus productStatus;

  // Local tokens only (do not promote to AppTheme per scope).
  static const _borderRadius = BorderRadius.all(Radius.circular(100));
  static const _padding = EdgeInsets.symmetric(horizontal: 10, vertical: 6);
  static const _labelStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  @override
  Widget build(BuildContext context) {
    final Color background = switch (productStatus) {
      ProductStatus.unset => Colors.grey.shade100,
      ProductStatus.processed => Colors.orange.shade100,
      ProductStatus.onDelivery => Colors.blue.shade100,
      ProductStatus.finished => Colors.green.shade100,
    };
    final Color foreground = switch (productStatus) {
      ProductStatus.unset => Colors.grey.shade700,
      ProductStatus.processed => Colors.orange.shade800,
      ProductStatus.onDelivery => Colors.blue.shade800,
      ProductStatus.finished => Colors.green.shade800,
    };

    return Container(
      padding: _padding,
      decoration: BoxDecoration(
        borderRadius: _borderRadius,
        color: background,
      ),
      child: Text(
        productStatus.getDisplayString(),
        style: _labelStyle.copyWith(color: foreground),
      ),
    );
  }
}
