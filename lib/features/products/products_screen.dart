import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/product.dart';
import '../../core/services/products_service.dart';
import '../../core/theme/app_theme.dart';
import 'add_product_screen.dart';
import 'product_detail_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductsService>().fetchProducts(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<ProductsService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('محصولات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: _ProductSearchDelegate(service));
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddProductScreen()),
          );
          if (result == true) {
            service.fetchProducts(refresh: true);
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('افزودن محصول'),
      ),
      body: service.isLoading && service.products.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : service.error != null && service.products.isEmpty
              ? Center(child: Text(service.error!))
              : RefreshIndicator(
                  onRefresh: () => service.fetchProducts(refresh: true),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: service.products.length + (service.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= service.products.length) {
                        service.fetchProducts();
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final product = service.products[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProductDetailScreen(productId: product.id),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: product.image != null && product.image!.isNotEmpty
                                      ? Image.network(
                                          product.image!,
                                          width: 64,
                                          height: 64,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => _placeholder(),
                                        )
                                      : _placeholder(),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        product.formattedPrice,
                                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: product.isLowStock
                                                  ? AppColors.warning.withOpacity(0.15)
                                                  : (product.stockStatus == 'instock'
                                                      ? AppColors.success.withOpacity(0.15)
                                                      : AppColors.error.withOpacity(0.15)),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              product.stockLabel,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: product.isLowStock
                                                    ? AppColors.warning
                                                    : (product.stockStatus == 'instock' ? AppColors.success : AppColors.error),
                                              ),
                                            ),
                                          ),
                                          if (product.onSale) ...[
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: AppColors.error.withOpacity(0.15),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: const Text('حراج', style: TextStyle(fontSize: 11, color: AppColors.error)),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_left, color: AppColors.textSecondary),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 64,
      height: 64,
      color: AppColors.border,
      child: const Icon(Icons.image, color: AppColors.textSecondary),
    );
  }
}

class _ProductSearchDelegate extends SearchDelegate {
  final ProductsService service;

  _ProductSearchDelegate(this.service);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [IconButton(icon: const Icon(Icons.clear), onPressed: () => query = '')];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => close(context, null));
  }

  @override
  Widget buildResults(BuildContext context) {
    service.setSearch(query);
    close(context, null);
    return const SizedBox();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return const Center(child: Text('جستجو بر اساس نام محصول'));
  }
}
