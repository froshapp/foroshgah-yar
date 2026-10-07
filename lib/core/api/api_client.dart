import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late Dio dio;
  final _storage = const FlutterSecureStorage();

  // آدرس پایه - در حالت چندفروشگاهی از StoreService گرفته می‌شود
  String baseUrl = '';

  ApiClient._internal() {
    dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      error: true,
      compact: true,
    ));

    // Interceptor برای اضافه کردن توکن
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'fy_token');
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        if (baseUrl.isNotEmpty) {
          options.baseUrl = baseUrl;
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          // توکن منقضی شده - می‌توان رویداد logout فرستاد
        }
        return handler.next(error);
      },
    ));
  }

  void setBaseUrl(String url) {
    // اطمینان از وجود /wp-json/foroshgah-yar/v1
    if (!url.endsWith('/')) url += '/';
    if (!url.contains('wp-json')) {
      url += 'wp-json/foroshgah-yar/v1/';
    }
    baseUrl = url;
    dio.options.baseUrl = url;
  }

  Future<void> saveToken(String token) async {
    await _storage.write(key: 'fy_token', value: token);
  }

  Future<void> clearToken() async {
    await _storage.delete(key: 'fy_token');
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'fy_token');
  }
}
