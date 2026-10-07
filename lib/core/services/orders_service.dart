import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../api/api_client.dart';
import '../models/order.dart';

class OrdersService extends ChangeNotifier {
  final ApiClient _api = ApiClient();

  List<Order> _orders = [];
  bool _isLoading = false;
  String? _error;
  int _page = 1;
  int _totalPages = 1;
  bool _hasMore = true;
  String _statusFilter = 'any';
  String _search = '';

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;
  String get statusFilter => _statusFilter;

  Future<void> fetchOrders({bool refresh = false}) async {
    if (refresh) {
      _page = 1;
      _orders = [];
      _hasMore = true;
    }

    if (!_hasMore && !refresh) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final params = {
        'page': _page,
        'per_page': 20,
        if (_statusFilter != 'any') 'status': _statusFilter,
        if (_search.isNotEmpty) 'search': _search,
      };

      final response = await _api.dio.get('orders', queryParameters: params);

      if (response.statusCode == 200 && response.data['success'] == true) {
        final list = (response.data['orders'] as List)
            .map((e) => Order.fromJson(e))
            .toList();

        if (refresh) {
          _orders = list;
        } else {
          _orders.addAll(list);
        }

        final pagination = response.data['pagination'];
        _totalPages = pagination['total_pages'] ?? 1;
        _hasMore = _page < _totalPages;
        _page++;
      }
    } on DioException catch (e) {
      _error = e.response?.data?['message'] ?? 'خطا در دریافت سفارشات';
    } catch (e) {
      _error = 'خطای ناشناخته';
    }

    _isLoading = false;
    notifyListeners();
  }

  void setStatusFilter(String status) {
    _statusFilter = status;
    fetchOrders(refresh: true);
  }

  void setSearch(String query) {
    _search = query;
    fetchOrders(refresh: true);
  }

  Future<Order?> getOrder(int id) async {
    try {
      final response = await _api.dio.get('orders/$id');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return Order.fromJson(response.data['order']);
      }
    } catch (_) {}
    return null;
  }

  Future<bool> updateStatus(int orderId, String status, {String? note}) async {
    try {
      final data = {'status': status};
      if (note != null && note.isNotEmpty) data['note'] = note;

      final response = await _api.dio.put('orders/$orderId', data: data);
      if (response.statusCode == 200 && response.data['success'] == true) {
        // به‌روزرسانی در لیست
        final index = _orders.indexWhere((o) => o.id == orderId);
        if (index != -1) {
          _orders[index] = Order.fromJson(response.data['order']);
          notifyListeners();
        }
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<bool> bulkUpdateStatus(List<int> ids, String status) async {
    try {
      final response = await _api.dio.post('orders/bulk-status', data: {
        'order_ids': ids,
        'status': status,
      });
      if (response.statusCode == 200 && response.data['success'] == true) {
        await fetchOrders(refresh: true);
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<Order?> createOrder({
    required List<Map<String, dynamic>> items,
    int customerId = 0,
    String status = 'pending',
    String? note,
  }) async {
    try {
      final response = await _api.dio.post('orders', data: {
        'items': items,
        'customer_id': customerId,
        'status': status,
        if (note != null) 'note': note,
      });
      if (response.statusCode == 200 && response.data['success'] == true) {
        final order = Order.fromJson(response.data['order']);
        _orders.insert(0, order);
        notifyListeners();
        return order;
      }
    } catch (_) {}
    return null;
  }
}
