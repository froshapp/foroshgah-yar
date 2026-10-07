import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/dashboard_service.dart';
import '../../core/theme/app_theme.dart';
import '../orders/orders_screen.dart';
import '../products/products_screen.dart';
import '../orders/order_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final _pages = const [
    _DashboardTab(),
    OrdersScreen(),
    ProductsScreen(),
    _MoreTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'داشبورد'),
          NavigationDestination(icon: Icon(Icons.shopping_bag_outlined), selectedIcon: Icon(Icons.shopping_bag), label: 'سفارشات'),
          NavigationDestination(icon: Icon(Icons.inventory_2_outlined), selectedIcon: Icon(Icons.inventory_2), label: 'محصولات'),
          NavigationDestination(icon: Icon(Icons.more_horiz), selectedIcon: Icon(Icons.more_horiz), label: 'بیشتر'),
        ],
      ),
    );
  }
}

class _DashboardTab extends StatefulWidget {
  const _DashboardTab();

  @override
  State<_DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<_DashboardTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardService>().fetchStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final dash = context.watch<DashboardService>();
    final siteName = auth.site?['name'] ?? 'فروشگاه';
    final stats = dash.stats;

    return Scaffold(
      appBar: AppBar(
        title: Text(siteName),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => dash.fetchStats(period: dash.period),
          ),
        ],
      ),
      body: dash.isLoading && stats == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => dash.fetchStats(period: dash.period),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // فیلتر دوره
                  Row(
                    children: [
                      _PeriodChip(label: 'امروز', selected: dash.period == 'today', onTap: () => dash.fetchStats(period: 'today')),
                      const SizedBox(width: 8),
                      _PeriodChip(label: 'هفته', selected: dash.period == 'week', onTap: () => dash.fetchStats(period: 'week')),
                      const SizedBox(width: 8),
                      _PeriodChip(label: 'ماه', selected: dash.period == 'month', onTap: () => dash.fetchStats(period: 'month')),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // کارت‌های آمار
                  Row(
                    children: [
                      Expanded(child: _StatCard(title: 'تعداد سفارش', value: '${stats?.ordersCount ?? 0}', icon: Icons.shopping_bag, color: AppColors.primary)),
                      const SizedBox(width: 12),
                      Expanded(child: _StatCard(title: 'فروش', value: stats?.formattedSales ?? '۰', icon: Icons.payments, color: AppColors.success)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _StatCard(title: 'در انتظار', value: '${stats?.pendingOrders ?? 0}', icon: Icons.hourglass_empty, color: AppColors.warning)),
                      const SizedBox(width: 12),
                      Expanded(child: _StatCard(title: 'موجودی کم', value: '${stats?.lowStockCount ?? 0}', icon: Icons.warning_amber, color: AppColors.error)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text('آخرین سفارشات', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),

                  if (stats?.recentOrders.isEmpty ?? true)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Text(
                            dash.error ?? 'هنوز سفارشی ثبت نشده',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ),
                    )
                  else
                    ...stats!.recentOrders.map((o) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text('#${o['number']} - ${o['customer'] ?? ''}'),
                            subtitle: Text(o['status_label'] ?? o['status'] ?? ''),
                            trailing: Text(
                              '${(o['total'] as num?)?.toStringAsFixed(0) ?? 0} ت',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => OrderDetailScreen(orderId: o['id'] as int),
                                ),
                              );
                            },
                          ),
                        )),
                ],
              ),
            ),
    );
  }
}

class _PeriodChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PeriodChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primary.withOpacity(0.15),
      labelStyle: TextStyle(
        color: selected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: color)),
            const SizedBox(height: 4),
            Text(title, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _MoreTab extends StatelessWidget {
  const _MoreTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('بیشتر')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.store),
            title: const Text('مدیریت فروشگاه‌ها'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('تنظیمات'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: const Text('خروج', style: TextStyle(color: AppColors.error)),
            onTap: () {
              context.read<AuthService>().logout();
            },
          ),
        ],
      ),
    );
  }
}
