import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/products_service.dart';
import '../../core/theme/app_theme.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _salePriceController = TextEditingController();
  final _skuController = TextEditingController();
  final _stockController = TextEditingController();
  final _descController = TextEditingController();

  bool _manageStock = false;
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _salePriceController.dispose();
    _skuController.dispose();
    _stockController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final product = await context.read<ProductsService>().createProduct(
          name: _nameController.text.trim(),
          regularPrice: _priceController.text.trim().isEmpty ? null : _priceController.text.trim(),
          salePrice: _salePriceController.text.trim().isEmpty ? null : _salePriceController.text.trim(),
          sku: _skuController.text.trim().isEmpty ? null : _skuController.text.trim(),
          manageStock: _manageStock,
          stockQuantity: _manageStock && _stockController.text.isNotEmpty
              ? int.tryParse(_stockController.text)
              : null,
          description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
        );

    setState(() => _loading = false);

    if (product != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('محصول با موفقیت اضافه شد')),
      );
      Navigator.pop(context, true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('خطا در ایجاد محصول')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('افزودن محصول')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'نام محصول *'),
              validator: (v) => v == null || v.trim().isEmpty ? 'نام محصول الزامی است' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'قیمت عادی (تومان)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _salePriceController,
              decoration: const InputDecoration(labelText: 'قیمت حراج (تومان)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _skuController,
              decoration: const InputDecoration(labelText: 'کد محصول (SKU)'),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('مدیریت موجودی'),
              value: _manageStock,
              activeColor: AppColors.primary,
              onChanged: (v) => setState(() => _manageStock = v),
            ),
            if (_manageStock) ...[
              const SizedBox(height: 8),
              TextFormField(
                controller: _stockController,
                decoration: const InputDecoration(labelText: 'تعداد موجودی'),
                keyboardType: TextInputType.number,
              ),
            ],
            const SizedBox(height: 16),
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'توضیحات'),
              maxLines: 4,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('ذخیره محصول'),
            ),
          ],
        ),
      ),
    );
  }
}
