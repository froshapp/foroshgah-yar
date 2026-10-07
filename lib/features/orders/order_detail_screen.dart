import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/order.dart';
import '../../core/services/orders_service.dart';
import '../../core/theme/app_theme.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  Order? _order;
  bool _loading = true;
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final order = await context.read<OrdersService>().getOrder(widget.orderId);
    setState(() {
      _order = order;
      _loading = false;
    });
  }

  Future<void> _changeStatus(String status) async {
    final ok = await context.read<OrdersService>().updateStatus(
      widget.orderId,
      status,
      note: _noteController.text.isNotEmpty ? _noteController.text : null,
    );
    if (ok) {
      _noteController.clear();
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('وضعیت سفارش تغییر کرد')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('جزئیات سفارش')),
        body: const Center(child: Text('سفارش یافت نشد')),
      );
    }

    final order = _order!;

    return Scaffold(
      appBar: AppBar(
        title: Text('سفارش #${order.number}'),
        actions: [
          PopupMenuButton<String>(
            onSelected: _changeStatus,
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'processing', child: Text('در حال انجام')),
              const PopupMenuItem(value: 'completed', child: Text('تکمیل شده')),
              const PopupMenuItem(value: 'on-hold', child: Text('در انتظار')),
              const PopupMenuItem(value: 'cancelled', child: Text('لغو شده')),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // وضعیت و مبلغ
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('وضعیت'),
                      Text(order.statusLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('مبلغ کل'),
                      Text(order.formattedTotal, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 18)),
                    ],
                  ),
                  if (order.paymentMethod != null) ...[
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('روش پرداخت'),
                        Text(order.paymentMethod!),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // مشتری
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('مشتری', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Text(order.customer.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  if (order.customer.phone.isNotEmpty) Text(order.customer.phone),
                  if (order.customer.email.isNotEmpty) Text(order.customer.email),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // اقلام
          if (order.lineItems != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('اقلام سفارش', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    ...order.lineItems!.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              if (item.image != null && item.image!.isNotEmpty)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(item.image!, width: 48, height: 48, fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 48)),
                                )
                              else
                                const Icon(Icons.image, size: 48, color: AppColors.border),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.name, maxLines: 2, overflow: TextOverflow.ellipsis),
                                    Text('${item.quantity} × ${item.total.toStringAsFixed(0)} تومان',
                                        style: Theme.of(context).textTheme.bodyMedium),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // یادداشت جدید
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('افزودن یادداشت', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _noteController,
                    maxLines: 2,
                    decoration: const InputDecoration(hintText: 'یادداشت خود را بنویسید...'),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton(
                      onPressed: () => _changeStatus(order.status),
                      child: const Text('ذخیره یادداشت'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // یادداشت‌های قبلی
          if (order.notes != null && order.notes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('یادداشت‌ها', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    ...order.notes!.map((n) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(n.content),
                              Text(n.date, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11)),
                              const Divider(),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
