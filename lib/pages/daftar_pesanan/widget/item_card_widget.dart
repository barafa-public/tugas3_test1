import 'package:flutter/material.dart';
import 'package:tugas3_test/pages/daftar_pesanan/entity/product.dart';
import 'package:tugas3_test/pages/daftar_pesanan/entity/product_status.dart';
import 'package:tugas3_test/pages/daftar_pesanan/widget/status_chip_widget.dart';
import 'package:uuid/uuid.dart';

class ItemCardWidget extends StatelessWidget {
  void Function(Uuid productId) onTap = (Uuid productId) {};

  Product product;

  ItemCardWidget(this.product, this.onTap, {super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(product.id),
      child: Container(
        margin: EdgeInsetsGeometry.all(10),
        child: Card(
          child: Container(
            padding: EdgeInsetsGeometry.all(20),
            child: Row(
              spacing: 12,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [StatusChipWidget(product.status), Text(product.name)],
            ),
          ),
        ),
      ),
    );
  }
}
