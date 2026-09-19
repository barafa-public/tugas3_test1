import 'package:flutter/material.dart';

import 'package:tugas3_test/models/product_catalog_item.dart';
import 'package:tugas3_test/services/order_service.dart';
import 'package:tugas3_test/utils/currency_formatter.dart';

/// Halaman katalog "Produk Sehari-hari".
///
/// User pilih satu produk dari daftar, lalu diminta memasukkan jumlah
/// lewat dialog. Setelah dikonfirmasi, produk otomatis ditambahkan
/// sebagai pesanan baru berstatus `cart`. Halaman tetap terbuka setelah
/// menambah satu produk supaya user bisa lanjut memilih produk lain
/// tanpa harus bolak-balik membuka katalog.
class ProductCatalogPage extends StatefulWidget {
  const ProductCatalogPage({super.key});

  @override
  State<ProductCatalogPage> createState() => _ProductCatalogPageState();
}

class _ProductCatalogPageState extends State<ProductCatalogPage> {
  final _orderService = OrderService();
  final _searchController = TextEditingController();

  /// true kalau minimal 1 produk berhasil ditambahkan — dipakai untuk
  /// memberi tahu halaman Pesanan supaya me-refresh daftar cart-nya.
  bool _hasAdded = false;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ProductCatalogItem> get _filteredCatalog {
    if (_query.trim().isEmpty) return kProductCatalog;
    final q = _query.trim().toLowerCase();
    return kProductCatalog
        .where((p) => p.name.toLowerCase().contains(q))
        .toList();
  }

  Map<String, List<ProductCatalogItem>> get _groupedByCategory {
    final map = <String, List<ProductCatalogItem>>{};
    for (final product in _filteredCatalog) {
      map.putIfAbsent(product.category, () => []).add(product);
    }
    return map;
  }

  Future<void> _pickQuantityAndAdd(ProductCatalogItem product) async {
    final qty = await showDialog<int>(
      context: context,
      builder: (context) => _QuantityDialog(product: product),
    );

    if (qty == null || qty <= 0) return;

    try {
      await _orderService.createOrder(
        name: product.name,
        quantity: qty,
        price: product.price,
      );
      _hasAdded = true;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} x$qty ditambahkan ke pesanan'),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menambahkan: ${_friendlyError(e)}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Kirim balik `true` kalau ada produk yang berhasil ditambahkan,
      // supaya PesananPage tahu perlu refresh daftar cart-nya.
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.of(context).pop(_hasAdded);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pilih Produk'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(_hasAdded),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari produk...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    isDense: true,
                  ),
                  onChanged: (value) => setState(() => _query = value),
                ),
              ),
              Expanded(
                child: _groupedByCategory.isEmpty
                    ? Center(
                        child: Text(
                          'Produk tidak ditemukan',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.only(bottom: 24, top: 4),
                        children: [
                          for (final entry in _groupedByCategory.entries) ...[
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                              child: Text(
                                entry.key,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            for (final product in entry.value)
                              _ProductTile(
                                product: product,
                                onTap: () => _pickQuantityAndAdd(product),
                              ),
                          ],
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  final ProductCatalogItem product;
  final VoidCallback onTap;

  const _ProductTile({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(
                  product.icon,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${formatRupiah(product.price)} / ${product.unit}',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.add_circle_outline),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dialog input jumlah untuk satu produk, dengan stepper +/- dan input
/// angka manual. Mengembalikan jumlah yang dipilih lewat `Navigator.pop`,
/// atau `null` kalau dibatalkan.
class _QuantityDialog extends StatefulWidget {
  final ProductCatalogItem product;

  const _QuantityDialog({required this.product});

  @override
  State<_QuantityDialog> createState() => _QuantityDialogState();
}

class _QuantityDialogState extends State<_QuantityDialog> {
  late final TextEditingController _qtyController;
  int _qty = 1;

  @override
  void initState() {
    super.initState();
    _qtyController = TextEditingController(text: '1');
  }

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  void _setQty(int value) {
    final clamped = value < 1 ? 1 : value;
    setState(() {
      _qty = clamped;
      _qtyController.text = clamped.toString();
      _qtyController.selection = TextSelection.collapsed(
        offset: _qtyController.text.length,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final subtotal = widget.product.price * _qty;

    return AlertDialog(
      title: Text(widget.product.name),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${formatRupiah(widget.product.price)} / ${widget.product.unit}',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          const Text('Jumlah', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton.filledTonal(
                onPressed: () => _setQty(_qty - 1),
                icon: const Icon(Icons.remove),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _qtyController,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (value) {
                    final parsed = int.tryParse(value.trim());
                    if (parsed != null && parsed >= 1) {
                      setState(() => _qty = parsed);
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                onPressed: () => _setQty(_qty + 1),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Subtotal: ${formatRupiah(subtotal)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () {
            final parsed = int.tryParse(_qtyController.text.trim()) ?? _qty;
            Navigator.of(context).pop(parsed < 1 ? 1 : parsed);
          },
          child: const Text('Tambah ke Pesanan'),
        ),
      ],
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
