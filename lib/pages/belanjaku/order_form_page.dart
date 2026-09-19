import 'package:flutter/material.dart';

import 'package:tugas3_test/models/category_model.dart';
import 'package:tugas3_test/models/order_model.dart';
import 'package:tugas3_test/services/category_service.dart';
import 'package:tugas3_test/services/order_service.dart';
import 'package:tugas3_test/utils/currency_formatter.dart';

/// Form untuk menambah item pesanan baru, atau mengedit item yang sudah ada
/// (kalau [existingOrder] diisi).
///
/// Setelah berhasil simpan, halaman ini akan `Navigator.pop` sambil
/// membawa [OrderModel] hasilnya, supaya halaman pemanggil (mis.
/// `BudgetCalculatorView`) tinggal refresh list-nya.
class OrderFormPage extends StatefulWidget {
  final OrderModel? existingOrder;

  const OrderFormPage({super.key, this.existingOrder});

  bool get isEditing => existingOrder != null;

  @override
  State<OrderFormPage> createState() => _OrderFormPageState();
}

class _OrderFormPageState extends State<OrderFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _orderService = OrderService();
  final _categoryService = CategoryService();

  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _qtyController;

  String? _selectedCategoryId;
  late Future<List<CategoryModel>> _categoriesFuture;

  bool _saving = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingOrder;

    _nameController = TextEditingController(text: existing?.name ?? '');
    _priceController = TextEditingController(
      text: existing != null ? existing.price.toStringAsFixed(0) : '',
    );
    _qtyController = TextEditingController(
      text: (existing?.quantity ?? 1).toString(),
    );
    _selectedCategoryId = existing?.categoryId;

    _categoriesFuture = _categoryService.getCategories();

    // Supaya subtotal live ter-update sambil user ngetik.
    _priceController.addListener(() => setState(() {}));
    _qtyController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _qtyController.dispose();
    super.dispose();
  }

  /// Parse input harga jadi angka, toleran terhadap pemisah ribuan yang
  /// suka diketik orang Indonesia (mis. "15.000" atau "15,000").
  ///
  /// Kalau dibiarkan pakai `double.parse` biasa, "15.000" kebaca sebagai
  /// 15.0 (titik dianggap desimal oleh Dart) — bukan 15 ribu. Karena
  /// Rupiah praktiknya selalu bilangan bulat, semua karakter selain
  /// digit dibuang dulu sebelum di-parse.
  double? _parseRupiah(String raw) {
    final digitsOnly = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) return null;
    return double.tryParse(digitsOnly);
  }

  double get _livePrice => _parseRupiah(_priceController.text) ?? 0;
  int get _liveQty => int.tryParse(_qtyController.text.trim()) ?? 0;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
      _errorText = null;
    });

    try {
      final name = _nameController.text.trim();
      final price = _parseRupiah(_priceController.text)!;
      final quantity = int.parse(_qtyController.text.trim());

      final OrderModel result;
      if (widget.isEditing) {
        result = await _orderService.updateOrder(
          id: widget.existingOrder!.id,
          name: name,
          quantity: quantity,
          price: price,
          categoryId: _selectedCategoryId,
        );
      } else {
        result = await _orderService.createOrder(
          name: name,
          quantity: quantity,
          price: price,
          categoryId: _selectedCategoryId,
        );
      }

      if (!mounted) return;
      Navigator.of(context).pop(result);
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorText = 'Gagal menyimpan: ${_friendlyError(e)}');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _showAddCategoryDialog() async {
    final controller = TextEditingController();

    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kategori Baru'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Contoh: Sembako'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (newName == null || newName.isEmpty) return;

    try {
      final created = await _categoryService.createCategory(newName);
      if (!mounted) return;
      setState(() {
        _categoriesFuture = _categoryService.getCategories();
        _selectedCategoryId = created.id;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuat kategori: ${_friendlyError(e)}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final subtotal = _livePrice * _liveQty;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Item' : 'Tambah Item'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (_errorText != null) ...[
                Text(_errorText!, style: TextStyle(color: Colors.red.shade700)),
                const SizedBox(height: 12),
              ],
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Barang',
                  hintText: 'Contoh: Minyak Goreng 2L',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama barang wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Harga Satuan',
                        hintText: 'Contoh: 15000',
                        prefixText: 'Rp ',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        final parsed = _parseRupiah(value ?? '');
                        if (parsed == null) return 'Harga tidak valid';
                        if (parsed < 0) return 'Harga tidak boleh negatif';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _qtyController,
                      decoration: const InputDecoration(
                        labelText: 'Jumlah',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        final parsed = int.tryParse((value ?? '').trim());
                        if (parsed == null) return 'Jumlah tidak valid';
                        if (parsed <= 0) return 'Minimal 1';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Subtotal: ${formatRupiah(subtotal)}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 16),
              FutureBuilder<List<CategoryModel>>(
                future: _categoriesFuture,
                builder: (context, snapshot) {
                  final isLoading =
                      snapshot.connectionState == ConnectionState.waiting;

                  // Kalau gagal load kategori, jangan diem-diem jadi list
                  // kosong — user perlu tau supaya gak salah kira memang
                  // belum ada kategori, dan bisa coba muat ulang.
                  if (snapshot.hasError) {
                    return Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Gagal memuat kategori: ${_friendlyError(snapshot.error)}',
                            style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                          ),
                        ),
                        TextButton(
                          onPressed: () => setState(
                            () => _categoriesFuture = _categoryService.getCategories(),
                          ),
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    );
                  }

                  final categories = snapshot.data ?? [];

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String?>(
                          initialValue: _selectedCategoryId,
                          decoration: InputDecoration(
                            labelText: 'Kategori (opsional)',
                            border: const OutlineInputBorder(),
                            suffixIcon: isLoading
                                ? const Padding(
                                    padding: EdgeInsets.all(12),
                                    child: SizedBox(
                                      height: 16,
                                      width: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                  )
                                : null,
                          ),
                          items: [
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text('Tanpa kategori'),
                            ),
                            ...categories.map(
                              (c) => DropdownMenuItem<String?>(
                                value: c.id,
                                child: Text(c.name, overflow: TextOverflow.ellipsis),
                              ),
                            ),
                          ],
                          onChanged: isLoading
                              ? null
                              : (value) => setState(() => _selectedCategoryId = value),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filledTonal(
                        tooltip: 'Kategori baru',
                        onPressed: _showAddCategoryDialog,
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(widget.isEditing ? 'Simpan Perubahan' : 'Tambah Item'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Ubah exception teknis (PostgrestException, koneksi, dll) jadi pesan
/// singkat yang cukup dimengerti user.
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
