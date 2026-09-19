import 'package:flutter/material.dart';

import 'package:tugas3_test/models/order_model.dart';
import 'package:tugas3_test/utils/currency_formatter.dart';

/// Card untuk menampilkan satu item pesanan.
///
/// Dibuat reusable: dipakai di tab Kalkulator (Menu Pesanan) untuk item
/// `cart`, dan juga bisa dipakai di tab Daftar Pesanan / History (punya
/// Fariz) tinggal atur `onToggleStatus`, `onDelete`, dan `showStatusBadge`
/// sesuai kebutuhan.
class OrderCard extends StatelessWidget {
  final OrderModel order;

  /// Dipanggil saat card di-tap. Biasanya untuk buka form edit.
  final VoidCallback? onTap;

  /// Dipanggil saat tombol hapus ditekan. Kalau null, tombol hapus disembunyikan.
  final VoidCallback? onDelete;

  /// Dipanggil saat tombol ubah status ditekan (cart <-> completed).
  /// Kalau null, tombol status disembunyikan.
  final VoidCallback? onToggleStatus;

  /// Tampilkan badge status (Keranjang / Selesai) di pojok kanan atas card.
  final bool showStatusBadge;

  /// Tooltip & ikon kustom untuk tombol [onToggleStatus] saat item masih
  /// `cart` (misal diubah jadi "Bayar" di Menu Daftar Pesanan). Kalau null,
  /// pakai default ("Tandai selesai" + ikon centang).
  final String? completeTooltip;
  final IconData? completeIcon;

  const OrderCard({
    super.key,
    required this.order,
    this.onTap,
    this.onDelete,
    this.onToggleStatus,
    this.showStatusBadge = false,
    this.completeTooltip,
    this.completeIcon,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = order.status == OrderStatus.completed;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: isCompleted
                    ? Colors.green.shade50
                    : Theme.of(context).colorScheme.primaryContainer,
                child: Icon(
                  isCompleted
                      ? Icons.check_circle_outline
                      : Icons.shopping_bag_outlined,
                  color: isCompleted ? Colors.green.shade700 : null,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            order.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (showStatusBadge)
                          _StatusBadge(isCompleted: isCompleted),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${order.quantity} x ${formatRupiah(order.price)}'
                      '${order.categoryName != null ? ' • ${order.categoryName}' : ''}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      formatRupiah(order.subtotal),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              if (onToggleStatus != null)
                IconButton(
                  tooltip: isCompleted
                      ? 'Kembalikan ke keranjang'
                      : (completeTooltip ?? 'Tandai selesai'),
                  icon: Icon(
                    isCompleted
                        ? Icons.undo
                        : (completeIcon ?? Icons.check_circle_outline),
                    color: isCompleted
                        ? Colors.grey.shade600
                        : Colors.green.shade700,
                  ),
                  onPressed: onToggleStatus,
                ),
              if (onDelete != null)
                IconButton(
                  tooltip: 'Hapus',
                  icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
                  onPressed: onDelete,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isCompleted;

  const _StatusBadge({required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isCompleted ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted ? Colors.green.shade200 : Colors.orange.shade200,
        ),
      ),
      child: Text(
        isCompleted ? 'Selesai' : 'Keranjang',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isCompleted ? Colors.green.shade700 : Colors.orange.shade700,
        ),
      ),
    );
  }
}
