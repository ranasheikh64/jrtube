import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';



class NetworkCaller {
  static final NetworkCaller _instance = NetworkCaller._internal();
  late Dio _dio;

  factory NetworkCaller() {
    return _instance;
  }

  String get _getBaseUrl {
    // Since you are using a physical Android device and have run `adb reverse`, 
    // the device's localhost (127.0.0.1) is now mapped to your computer's localhost.
    return 'http://127.0.0.1:8000/api/v1'; 
  }

  NetworkCaller._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _getBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add auth token if needed here
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          debugPrint('API Error: ${e.message}');
          return handler.next(e);
        },
      ),
    );
  }

  // Generic GET request
  Future<Response?> get(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(endpoint, queryParameters: queryParameters);
    } catch (e) {
      _handleError(e);
      return null;
    }
  }

  // Generic POST request
  Future<Response?> post(String endpoint, {Map<String, dynamic>? data}) async {
    try {
      return await _dio.post(endpoint, data: data);
    } catch (e) {
      _handleError(e);
      return null;
    }
  }

  // Generic PUT request
  Future<Response?> put(String endpoint, {Map<String, dynamic>? data}) async {
    try {
      return await _dio.put(endpoint, data: data);
    } catch (e) {
      _handleError(e);
      return null;
    }
  }

  // Generic DELETE request
  Future<Response?> delete(String endpoint, {Map<String, dynamic>? data}) async {
    try {
      return await _dio.delete(endpoint, data: data);
    } catch (e) {
      _handleError(e);
      return null;
    }
  }

  void _handleError(dynamic error) {
    if (error is DioException) {
      debugPrint("Network Error: ${error.response?.statusCode} - ${error.message}");
    } else {
      debugPrint("Unknown Error: $error");
    }
  }
}
