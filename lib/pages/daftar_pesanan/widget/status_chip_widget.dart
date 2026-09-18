import 'package:flutter/material.dart';
import 'package:tugas3_test/pages/daftar_pesanan/entity/product_status.dart';

class StatusChipWidget extends StatelessWidget {
  StatusChipWidget(this.productStatus, {super.key});

  ProductStatus productStatus;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsetsGeometry.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(100)),
        color: switch (productStatus) {
          ProductStatus.unset => Colors.grey,
          ProductStatus.processed => Colors.amber,
          ProductStatus.onDelivery => Colors.blue,
          ProductStatus.finished => Colors.green,
        },
      ),
      child: Text(productStatus.getDisplayString()),
    );
  }
}
