import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../api/api_client.dart';

class AuthService extends ChangeNotifier {
  final ApiClient _api = ApiClient();

  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _user;
  Map<String, dynamic>? _site;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get user => _user;
  Map<String, dynamic>? get site => _site;

  /// اتصال با توکن (روش اصلی و پیشنهادی)
  Future<bool> connectWithToken({
    required String siteUrl,
    required String token,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _api.setBaseUrl(siteUrl);

      final response = await _api.dio.post('connect', data: {
        'token': token,
      });

      if (response.statusCode == 200 && response.data['success'] == true) {
        await _api.saveToken(token);
        _user = response.data['user'];
        _site = response.data['site'];
        _isAuthenticated = true;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.data['message'] ?? 'خطا در اتصال';
      }
    } on DioException catch (e) {
      if (e.response?.data != null && e.response?.data['message'] != null) {
        _error = e.response?.data['message'];
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        _error = 'اتصال به سرور برقرار نشد. آدرس سایت را بررسی کنید.';
      } else {
        _error = 'خطا در اتصال به سرور.';
      }
    } catch (e) {
      _error = 'خطای ناشناخته';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// ورود با نام کاربری و رمز (روش جایگزین)
  Future<bool> login({
    required String siteUrl,
    required String username,
    required String password,
    String deviceName = 'Android',
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _api.setBaseUrl(siteUrl);

      final response = await _api.dio.post('login', data: {
        'username': username,
        'password': password,
        'device_name': deviceName,
      });

      if (response.statusCode == 200 && response.data['success'] == true) {
        final token = response.data['token'] as String;
        await _api.saveToken(token);
        _user = response.data['user'];
        _site = response.data['site'];
        _isAuthenticated = true;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.data['message'] ?? 'خطا در ورود';
      }
    } on DioException catch (e) {
      if (e.response?.data != null && e.response?.data['message'] != null) {
        _error = e.response?.data['message'];
      } else {
        _error = 'خطا در اتصال به سرور. آدرس سایت را بررسی کنید.';
      }
    } catch (e) {
      _error = 'خطای ناشناخته';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    try {
      await _api.dio.post('logout');
    } catch (_) {}
    await _api.clearToken();
    _isAuthenticated = false;
    _user = null;
    _site = null;
    notifyListeners();
  }

  Future<void> checkAuth() async {
    final token = await _api.getToken();
    _isAuthenticated = token != null && token.isNotEmpty;
    notifyListeners();
  }
}
