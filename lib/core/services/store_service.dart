import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Store {
  final String id;
  final String name;
  final String url;
  final String? token;

  Store({
    required this.id,
    required this.name,
    required this.url,
    this.token,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'url': url,
        'token': token,
      };

  factory Store.fromJson(Map<String, dynamic> json) => Store(
        id: json['id'],
        name: json['name'],
        url: json['url'],
        token: json['token'],
      );
}

class StoreService extends ChangeNotifier {
  List<Store> _stores = [];
  Store? _currentStore;

  List<Store> get stores => _stores;
  Store? get currentStore => _currentStore;

  Future<void> loadStores() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('fy_stores');
    if (raw != null) {
      final list = jsonDecode(raw) as List;
      _stores = list.map((e) => Store.fromJson(e)).toList();
    }

    final currentId = prefs.getString('fy_current_store');
    if (currentId != null && _stores.isNotEmpty) {
      _currentStore = _stores.firstWhere(
        (s) => s.id == currentId,
        orElse: () => _stores.first,
      );
    }
    notifyListeners();
  }

  Future<void> addStore(Store store) async {
    _stores.removeWhere((s) => s.url == store.url);
    _stores.add(store);
    _currentStore = store;
    await _save();
    notifyListeners();
  }

  Future<void> setCurrentStore(Store store) async {
    _currentStore = store;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fy_current_store', store.id);
    notifyListeners();
  }

  Future<void> removeStore(String id) async {
    _stores.removeWhere((s) => s.id == id);
    if (_currentStore?.id == id) {
      _currentStore = _stores.isNotEmpty ? _stores.first : null;
    }
    await _save();
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(_stores.map((s) => s.toJson()).toList());
    await prefs.setString('fy_stores', raw);
    if (_currentStore != null) {
      await prefs.setString('fy_current_store', _currentStore!.id);
    }
  }
}
