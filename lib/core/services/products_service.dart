import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../api/api_client.dart';
import '../models/product.dart';

class ProductsService extends ChangeNotifier {
  final ApiClient _api = ApiClient();

  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;
  int _page = 1;
  int _totalPages = 1;
  bool _hasMore = true;
  String _search = '';

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;

  Future<void> fetchProducts({bool refresh = false}) async {
    if (refresh) {
      _page = 1;
      _products = [];
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
        if (_search.isNotEmpty) 'search': _search,
      };

      final response = await _api.dio.get('products', queryParameters: params);

      if (response.statusCode == 200 && response.data['success'] == true) {
        final list = (response.data['products'] as List)
            .map((e) => Product.fromJson(e))
            .toList();

        if (refresh) {
          _products = list;
        } else {
          _products.addAll(list);
        }

        final pagination = response.data['pagination'];
        _totalPages = pagination['total_pages'] ?? 1;
        _hasMore = _page < _totalPages;
        _page++;
      }
    } on DioException catch (e) {
      _error = e.response?.data?['message'] ?? 'خطا در دریافت محصولات';
    } catch (e) {
      _error = 'خطای ناشناخته';
    }

    _isLoading = false;
    notifyListeners();
  }

  void setSearch(String query) {
    _search = query;
    fetchProducts(refresh: true);
  }

  Future<Product?> getProduct(int id) async {
    try {
      final response = await _api.dio.get('products/$id');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return Product.fromJson(response.data['product']);
      }
    } catch (_) {}
    return null;
  }

  Future<Product?> createProduct({
    required String name,
    String type = 'simple',
    String? regularPrice,
    String? salePrice,
    String? sku,
    int? stockQuantity,
    bool manageStock = false,
    String? description,
    String status = 'publish',
  }) async {
    try {
      final data = {
        'name': name,
        'type': type,
        'status': status,
        if (regularPrice != null) 'regular_price': regularPrice,
        if (salePrice != null) 'sale_price': salePrice,
        if (sku != null) 'sku': sku,
        'manage_stock': manageStock,
        if (stockQuantity != null) 'stock_quantity': stockQuantity,
        if (description != null) 'description': description,
      };

      final response = await _api.dio.post('products', data: data);
      if (response.statusCode == 200 && response.data['success'] == true) {
        final product = Product.fromJson(response.data['product']);
        _products.insert(0, product);
        notifyListeners();
        return product;
      }
    } catch (_) {}
    return null;
  }

  Future<bool> updateProduct(int id, Map<String, dynamic> data) async {
    try {
      final response = await _api.dio.put('products/$id', data: data);
      if (response.statusCode == 200 && response.data['success'] == true) {
        final updated = Product.fromJson(response.data['product']);
        final index = _products.indexWhere((p) => p.id == id);
        if (index != -1) {
          _products[index] = updated;
          notifyListeners();
        }
        return true;
      }
    } catch (_) {}
    return false;
  }
}
