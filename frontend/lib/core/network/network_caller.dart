import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class NetworkCaller {
  static final NetworkCaller _instance = NetworkCaller._internal();
  late Dio _dio;

  factory NetworkCaller() {
    return _instance;
  }

  String get _getBaseUrl {
    // Vercel deployment URL
    return 'http://168.231.124.228:8069/api/v1';
  }

  NetworkCaller._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _getBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add auth token if needed here
          debugPrint('API Request: ${options.method} ${options.uri}');
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          debugPrint('API Error Message: ${e.message}');
          if (e.response != null) {
            debugPrint('API Error Response Data: ${e.response?.data}');
          }
          return handler.next(e);
        },
      ),
    );
  }

  // Generic GET request
  Future<Response?> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
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
  Future<Response?> delete(
    String endpoint, {
    Map<String, dynamic>? data,
  }) async {
    try {
      return await _dio.delete(endpoint, data: data);
    } catch (e) {
      _handleError(e);
      return null;
    }
  }

  void _handleError(dynamic error) {
    if (error is DioException) {
      debugPrint(
        "Network Error: ${error.response?.statusCode} - ${error.message}",
      );
      if (error.response?.data != null) {
        debugPrint("Response Body: ${error.response?.data}");
      }
    } else {
      debugPrint("Unknown Error: $error");
    }
  }
}
