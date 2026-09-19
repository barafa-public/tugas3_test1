import 'package:flutter/material.dart';

import 'package:tugas3_test/models/order_model.dart';
import 'package:tugas3_test/services/order_service.dart';

import 'widgets/order_card.dart';

/// Menu History Pesanan.
///
/// Menampilkan pesanan yang statusnya sudah `completed` (sudah dibayar).
/// Bersifat read-only — pesanan yang sudah dibayar tidak bisa
/// dikembalikan lagi ke keranjang.
class HistoryPesananPage extends StatefulWidget {
  const HistoryPesananPage({super.key});

  @override
  State<HistoryPesananPage> createState() => _HistoryPesananPageState();
}

class _HistoryPesananPageState extends State<HistoryPesananPage> {
  final _orderService = OrderService();
  late Future<List<OrderModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<OrderModel>> _load() {
    return _orderService.getOrders(status: OrderStatus.completed);
  }

  Future<void> _refresh() async {
    if (!mounted) return;
    final next = _load();
    setState(() => _future = next);
    await next;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History Pesanan')),
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
                          : 'Gagal memuat history: ${_friendlyError(snapshot.error)}',
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

          return RefreshIndicator(
            onRefresh: _refresh,
            child: orders.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 16, bottom: 16),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      // Read-only: tidak ada onTap, onDelete, atau
                      // onToggleStatus — pesanan yang sudah dibayar tidak
                      // bisa diubah/dikembalikan.
                      return OrderCard(order: order);
                    },
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
                    Icon(Icons.history, size: 56, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    Text(
                      'Belum ada history pesanan',
                      style: TextStyle(color: Colors.grey.shade600),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Pesanan yang sudah dibayar akan muncul di sini',
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
