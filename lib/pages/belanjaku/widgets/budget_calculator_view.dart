import 'package:flutter/material.dart';

import 'package:tugas3_test/models/order_model.dart';
import 'package:tugas3_test/services/order_service.dart';
import 'package:tugas3_test/utils/currency_formatter.dart';
import 'order_card.dart';
import '../order_form_page.dart';

/// Isi tab "Kalkulator" (Menu Pesanan) di `BelanjakuPage`.
///
/// Fungsinya: user input barang (nama, harga, jumlah) lewat
/// [OrderFormPage], item otomatis masuk sebagai pesanan berstatus `cart`,
/// dan halaman ini menampilkan daftarnya sekaligus menghitung total
/// belanja secara otomatis (kalkulator).
///
/// Item yang sudah masuk sini akan otomatis muncul juga di tab
/// "Daftar Pesanan" (punya Fariz) selama statusnya masih `cart`.
class BudgetCalculatorView extends StatefulWidget {
  const BudgetCalculatorView({super.key});

  @override
  State<BudgetCalculatorView> createState() => _BudgetCalculatorViewState();
}

class _BudgetCalculatorViewState extends State<BudgetCalculatorView> {
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

  /// Muat ulang daftar item cart.
  ///
  /// Selalu cek [mounted] sebelum `setState` — method ini sering dipanggil
  /// setelah `await` (habis nutup halaman form / dialog), dan di rentang
  /// waktu itu widget-nya bisa saja sudah di-dispose (mis. user keburu
  /// pindah tab/halaman). Manggil `setState` setelah dispose bakal
  /// nge-throw error.
  Future<void> _refresh() async {
    if (!mounted) return;
    final next = _load();
    setState(() => _future = next);
    await next;
  }

  Future<void> _openForm({OrderModel? existing}) async {
    final result = await Navigator.of(context).push<OrderModel>(
      MaterialPageRoute(builder: (_) => OrderFormPage(existingOrder: existing)),
    );
    if (!mounted) return;
    if (result != null) _refresh();
  }

  Future<void> _confirmDelete(OrderModel order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Item'),
        content: Text('Hapus "${order.name}" dari daftar belanja?'),
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
        SnackBar(content: Text('Gagal menghapus "${order.name}": ${_friendlyError(e)}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                          : 'Gagal memuat daftar belanja: ${_friendlyError(snapshot.error)}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _refresh,
                      child: Text(isSessionExpired ? 'Muat Ulang' : 'Coba Lagi'),
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
                _TotalCard(total: total, itemCount: orders.length),
                Expanded(
                  child: orders.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.only(top: 8, bottom: 88),
                          itemCount: orders.length,
                          itemBuilder: (context, index) {
                            final order = orders[index];
                            return Dismissible(
                              key: ValueKey(order.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade400,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.delete, color: Colors.white),
                              ),
                              confirmDismiss: (_) async {
                                await _confirmDelete(order);
                                // Konfirmasi & hapus sudah ditangani manual di
                                // atas, jadi widget cukup rebuild lewat _refresh.
                                return false;
                              },
                              child: OrderCard(
                                order: order,
                                onTap: () => _openForm(existing: order),
                                onDelete: () => _confirmDelete(order),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Item'),
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
                    Icon(Icons.shopping_cart_outlined,
                        size: 56, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    Text(
                      'Belum ada barang di daftar belanja',
                      style: TextStyle(color: Colors.grey.shade600),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ketuk "Tambah Item" untuk mulai menghitung belanjaanmu',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
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

/// Ubah exception teknis (PostgrestException, koneksi, dll) jadi pesan
/// singkat yang cukup dimengerti user, sambil tetap ke-print ke console
/// buat debugging kalau perlu.
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
  // Fallback: tampilkan pesan asli tapi dipotong biar gak kepanjangan.
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
            Icon(Icons.calculate_outlined,
                color: Theme.of(context).colorScheme.onPrimaryContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Estimasi Belanja',
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
