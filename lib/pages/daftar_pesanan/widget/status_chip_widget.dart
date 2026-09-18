import 'package:flutter/material.dart';
import 'package:tugas3_test/pages/daftar_pesanan/entity/product_status.dart';

class StatusChipWidget extends StatelessWidget {
  StatusChipWidget(this.productStatus, {super.key});

  ProductStatus productStatus;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsetsGeometry.all(50),
      child: Text(productStatus.toString()),
    );
  }
}
