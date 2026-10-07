import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/order.dart';
import '../../core/services/orders_service.dart';
import '../../core/theme/app_theme.dart';
import 'order_detail_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final _searchController = TextEditingController();
  final Set<int> _selectedIds = {};
  bool _selectionMode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrdersService>().fetchOrders(refresh: true);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _statusColor(ColorStatus status) {
    switch (status) {
      case ColorStatus.success:
        return AppColors.success;
      case ColorStatus.info:
        return AppColors.info;
      case ColorStatus.warning:
        return AppColors.warning;
      case ColorStatus.error:
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<OrdersService>();

    return Scaffold(
      appBar: AppBar(
        title: _selectionMode
            ? Text('${_selectedIds.length} انتخاب شده')
            : const Text('سفارشات'),
        actions: [
          if (_selectionMode) ...[
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => setState(() {
                _selectionMode = false;
                _selectedIds.clear();
              }),
            ),
            PopupMenuButton<String>(
              onSelected: (status) async {
                final ok = await service.bulkUpdateStatus(_selectedIds.toList(), status);
                if (ok && mounted) {
                  setState(() {
                    _selectionMode = false;
                    _selectedIds.clear();
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('وضعیت سفارشات تغییر کرد')),
                  );
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'processing', child: Text('در حال انجام')),
                const PopupMenuItem(value: 'completed', child: Text('تکمیل شده')),
                const PopupMenuItem(value: 'on-hold', child: Text('در انتظار')),
                const PopupMenuItem(value: 'cancelled', child: Text('لغو شده')),
              ],
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: _OrderSearchDelegate(service),
                );
              },
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          // فیلتر وضعیت
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                _FilterChip(
                  label: 'همه',
                  selected: service.statusFilter == 'any',
                  onTap: () => service.setStatusFilter('any'),
                ),
                _FilterChip(
                  label: 'در انتظار',
                  selected: service.statusFilter == 'pending',
                  onTap: () => service.setStatusFilter('pending'),
                ),
                _FilterChip(
                  label: 'در حال انجام',
                  selected: service.statusFilter == 'processing',
                  onTap: () => service.setStatusFilter('processing'),
                ),
                _FilterChip(
                  label: 'تکمیل شده',
                  selected: service.statusFilter == 'completed',
                  onTap: () => service.setStatusFilter('completed'),
                ),
                _FilterChip(
                  label: 'لغو شده',
                  selected: service.statusFilter == 'cancelled',
                  onTap: () => service.setStatusFilter('cancelled'),
                ),
              ],
            ),
          ),

          // لیست
          Expanded(
            child: service.isLoading && service.orders.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : service.error != null && service.orders.isEmpty
                    ? Center(child: Text(service.error!))
                    : RefreshIndicator(
                        onRefresh: () => service.fetchOrders(refresh: true),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: service.orders.length + (service.hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index >= service.orders.length) {
                              service.fetchOrders();
                              return const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(child: CircularProgressIndicator()),
                              );
                            }

                            final order = service.orders[index];
                            final selected = _selectedIds.contains(order.id);

                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {
                                  if (_selectionMode) {
                                    setState(() {
                                      if (selected) {
                                        _selectedIds.remove(order.id);
                                        if (_selectedIds.isEmpty) _selectionMode = false;
                                      } else {
                                        _selectedIds.add(order.id);
                                      }
                                    });
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => OrderDetailScreen(orderId: order.id),
                                      ),
                                    );
                                  }
                                },
                                onLongPress: () {
                                  setState(() {
                                    _selectionMode = true;
                                    _selectedIds.add(order.id);
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Row(
                                    children: [
                                      if (_selectionMode)
                                        Checkbox(
                                          value: selected,
                                          onChanged: (v) {
                                            setState(() {
                                              if (v == true) {
                                                _selectedIds.add(order.id);
                                              } else {
                                                _selectedIds.remove(order.id);
                                                if (_selectedIds.isEmpty) _selectionMode = false;
                                              }
                                            });
                                          },
                                        ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  '#${order.number}',
                                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: _statusColor(order.statusColor).withOpacity(0.12),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Text(
                                                    order.statusLabel,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: _statusColor(order.statusColor),
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            Text(order.customer.name, style: Theme.of(context).textTheme.bodyMedium),
                                            const SizedBox(height: 4),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  order.dateCreatedJalali ?? order.dateCreated,
                                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
                                                ),
                                                Text(
                                                  order.formattedTotal,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.primary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primary.withOpacity(0.15),
        labelStyle: TextStyle(
          color: selected ? AppColors.primary : AppColors.textSecondary,
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }
}

class _OrderSearchDelegate extends SearchDelegate {
  final OrdersService service;

  _OrderSearchDelegate(this.service);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
    ];
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
    return const Center(child: Text('جستجو بر اساس شماره سفارش یا نام مشتری'));
  }
}
