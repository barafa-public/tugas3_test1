import 'package:flutter/material.dart';

import 'package:tugas3_test/models/order_model.dart';
import 'package:tugas3_test/services/order_service.dart';
import 'package:tugas3_test/utils/currency_formatter.dart';

import 'widgets/order_card.dart';

/// Menu Daftar Pesanan.
///
/// Menampilkan pesanan yang masih berstatus `cart` (belum dibayar).
/// User bisa langsung "Bayar" di sini -> status pesanan berubah jadi
/// `completed`, item otomatis hilang dari daftar ini dan pindah ke
/// Menu History Pesanan.
class DaftarPesananPage extends StatefulWidget {
  const DaftarPesananPage({super.key});

  @override
  State<DaftarPesananPage> createState() => _DaftarPesananPageState();
}

class _DaftarPesananPageState extends State<DaftarPesananPage> {
  final _orderService = OrderService();
  late Future<List<OrderModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<OrderModel>> _load() {
    return _orderService.getOrders(status: OrderStatus.cart);
  }

  Future<void> _refresh() async {
    if (!mounted) return;
    final next = _load();
    setState(() {
      _future = next;
    });
    await next;
  }

  Future<void> _confirmPay(OrderModel order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bayar Pesanan'),
        content: Text(
          'Bayar "${order.name}" sebesar ${formatRupiah(order.subtotal)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Bayar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _orderService.markCompleted(order.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"${order.name}" berhasil dibayar')),
      );
      _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membayar "${order.name}": ${_friendlyError(e)}'),
        ),
      );
    }
  }

  Future<void> _confirmDelete(OrderModel order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Item'),
        content: Text('Hapus "${order.name}" dari daftar pesanan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade600),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _orderService.deleteOrder(order.id);
      if (!mounted) return;
      _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal menghapus "${order.name}": ${_friendlyError(e)}',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Pesanan')),
      body: FutureBuilder<List<OrderModel>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            final isSessionExpired = snapshot.error is StateError;
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSessionExpired ? Icons.lock_outline : Icons.wifi_off,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isSessionExpired
                          ? 'Sesi login kamu sudah berakhir. Silakan login ulang.'
                          : 'Gagal memuat daftar pesanan: ${_friendlyError(snapshot.error)}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _refresh,
                      child: Text(
                        isSessionExpired ? 'Muat Ulang' : 'Coba Lagi',
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final orders = snapshot.data ?? [];
          final total = orders.fold<double>(0, (sum, o) => sum + o.subtotal);

          return RefreshIndicator(
            onRefresh: _refresh,
            child: Column(
              children: [
                if (orders.isNotEmpty)
                  _TotalCard(total: total, itemCount: orders.length),
                Expanded(
                  child: orders.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.only(top: 8, bottom: 16),
                          itemCount: orders.length,
                          itemBuilder: (context, index) {
                            final order = orders[index];
                            return OrderCard(
                              order: order,
                              onToggleStatus: () => _confirmPay(order),
                              onDelete: () => _confirmDelete(order),
                              completeTooltip: 'Bayar',
                              completeIcon: Icons.payment_outlined,
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: constraints.maxHeight,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.list_alt_outlined,
                      size: 56,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Belum ada pesanan yang menunggu pembayaran',
                      style: TextStyle(color: Colors.grey.shade600),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tambahkan barang lewat Menu Pesanan terlebih dahulu',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

String _friendlyError(Object? error) {
  final text = error.toString().toLowerCase();
  if (text.contains('socketexception') ||
      text.contains('network') ||
      text.contains('failed host lookup')) {
    return 'periksa koneksi internet kamu.';
  }
  if (text.contains('timeout')) {
    return 'koneksi terlalu lama, coba lagi.';
  }
  final raw = error.toString();
  return raw.length > 120 ? '${raw.substring(0, 120)}...' : raw;
}

class _TotalCard extends StatelessWidget {
  final double total;
  final int itemCount;

  const _TotalCard({required this.total, required this.itemCount});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Belum Dibayar',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatRupiah(total),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '$itemCount item',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
