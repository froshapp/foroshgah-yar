import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../api/api_client.dart';

class DashboardStats {
  final String period;
  final int ordersCount;
  final double totalSales;
  final int pendingOrders;
  final String currency;
  final String currencySymbol;
  final int lowStockCount;
  final List<Map<String, dynamic>> lowStock;
  final List<Map<String, dynamic>> recentOrders;

  DashboardStats({
    required this.period,
    required this.ordersCount,
    required this.totalSales,
    required this.pendingOrders,
    required this.currency,
    required this.currencySymbol,
    required this.lowStockCount,
    required this.lowStock,
    required this.recentOrders,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      period: json['period'] ?? 'today',
      ordersCount: json['orders_count'] ?? 0,
      totalSales: (json['total_sales'] ?? 0).toDouble(),
      pendingOrders: json['pending_orders'] ?? 0,
      currency: json['currency'] ?? 'IRT',
      currencySymbol: json['currency_symbol'] ?? 'تومان',
      lowStockCount: json['low_stock_count'] ?? 0,
      lowStock: List<Map<String, dynamic>>.from(json['low_stock'] ?? []),
      recentOrders: List<Map<String, dynamic>>.from(json['recent_orders'] ?? []),
    );
  }

  String get formattedSales {
    final t = totalSales.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
    return '$t تومان';
  }
}

class DashboardService extends ChangeNotifier {
  final ApiClient _api = ApiClient();

  DashboardStats? _stats;
  bool _isLoading = false;
  String? _error;
  String _period = 'today';

  DashboardStats? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get period => _period;

  Future<void> fetchStats({String period = 'today'}) async {
    _period = period;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.dio.get('dashboard', queryParameters: {
        'period': period,
      });

      if (response.statusCode == 200 && response.data['success'] == true) {
        _stats = DashboardStats.fromJson(response.data['stats']);
      } else {
        _error = 'خطا در دریافت آمار';
      }
    } on DioException catch (e) {
      _error = e.response?.data?['message'] ?? 'خطا در اتصال به سرور';
    } catch (e) {
      _error = 'خطای ناشناخته';
    }

    _isLoading = false;
    notifyListeners();
  }
}
