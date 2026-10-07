import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/product.dart';
import '../../core/services/products_service.dart';
import '../../core/theme/app_theme.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Product? _product;
  bool _loading = true;
  bool _saving = false;

  final _priceController = TextEditingController();
  final _saleController = TextEditingController();
  final _stockController = TextEditingController();
  bool _manageStock = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final product = await context.read<ProductsService>().getProduct(widget.productId);
    if (product != null) {
      _priceController.text = product.regularPrice > 0 ? product.regularPrice.toStringAsFixed(0) : '';
      _saleController.text = product.salePrice != null ? product.salePrice!.toStringAsFixed(0) : '';
      _stockController.text = product.stockQuantity?.toString() ?? '';
      _manageStock = product.manageStock;
    }
    setState(() {
      _product = product;
      _loading = false;
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);

    final data = {
      'regular_price': _priceController.text.trim(),
      'sale_price': _saleController.text.trim(),
      'manage_stock': _manageStock,
      if (_manageStock) 'stock_quantity': int.tryParse(_stockController.text) ?? 0,
    };

    final ok = await context.read<ProductsService>().updateProduct(widget.productId, data);
    setState(() => _saving = false);

    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('محصول به‌روزرسانی شد')));
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('جزئیات محصول')),
        body: const Center(child: Text('محصول یافت نشد')),
      );
    }

    final p = _product!;

    return Scaffold(
      appBar: AppBar(title: Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (p.image != null && p.image!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(p.image!, height: 200, width: double.infinity, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox(height: 200, child: Icon(Icons.image, size: 64))),
            ),
          const SizedBox(height: 16),
          Text(p.name, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(p.formattedPrice, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
          const SizedBox(height: 24),

          // ویرایش سریع
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ویرایش سریع', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _priceController,
                    decoration: const InputDecoration(labelText: 'قیمت عادی'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _saleController,
                    decoration: const InputDecoration(labelText: 'قیمت حراج'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('مدیریت موجودی'),
                    value: _manageStock,
                    onChanged: (v) => setState(() => _manageStock = v),
                  ),
                  if (_manageStock)
                    TextField(
                      controller: _stockController,
                      decoration: const InputDecoration(labelText: 'موجودی'),
                      keyboardType: TextInputType.number,
                    ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      child: _saving
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('ذخیره تغییرات'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
