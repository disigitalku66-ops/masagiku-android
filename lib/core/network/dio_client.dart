/// Dio HTTP Client with interceptors
library;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_constants.dart';
import '../storage/secure_storage.dart';

class DioClient {
  late final Dio _dio;
  final SecureStorageService _storage;

  DioClient(this._storage) {
    _dio = Dio(_baseOptions);
    _dio.interceptors.addAll([
      _authInterceptor(),
      _loggerInterceptor(),
      _errorInterceptor(),
    ]);
  }

  Dio get dio => _dio;

  static BaseOptions get _baseOptions => BaseOptions(
    baseUrl: AppConstants.apiUrl,
    connectTimeout: AppConstants.connectTimeout,
    receiveTimeout: AppConstants.receiveTimeout,
    sendTimeout: AppConstants.sendTimeout,
    headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
    validateStatus: (status) => status != null && status < 500,
  );

  /// Auth Interceptor - Adds token to requests
  InterceptorsWrapper _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.getAccessToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // Token expired - try to refresh or logout
          await _storage.clearAuth();
          // Note: Token refresh / redirect handled by app router
        }
        return handler.next(error);
      },
    );
  }

  /// Logger Interceptor - Debug logging
  InterceptorsWrapper _loggerInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        if (kDebugMode) {
          debugPrint(
            '┌────────────────────────────────────────────────────────────',
          );
          debugPrint('│ 🚀 REQUEST: ${options.method} ${options.uri}');
          debugPrint('│ Headers: ${options.headers}');
          if (options.data != null) {
            debugPrint('│ Body: ${options.data}');
          }
          debugPrint(
            '└────────────────────────────────────────────────────────────',
          );
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        if (kDebugMode) {
          debugPrint(
            '┌────────────────────────────────────────────────────────────',
          );
          debugPrint(
            '│ ✅ RESPONSE: ${response.statusCode} ${response.requestOptions.uri}',
          );
          debugPrint(
            '│ Data: ${response.data.toString().substring(0, (response.data.toString().length > 500) ? 500 : response.data.toString().length)}...',
          );
          debugPrint(
            '└────────────────────────────────────────────────────────────',
          );
        }
        return handler.next(response);
      },
      onError: (error, handler) {
        if (kDebugMode) {
          debugPrint(
            '┌────────────────────────────────────────────────────────────',
          );
          debugPrint(
            '│ ❌ ERROR: ${error.response?.statusCode} ${error.requestOptions.uri}',
          );
          debugPrint('│ Message: ${error.message}');
          debugPrint('│ Response: ${error.response?.data}');
          debugPrint(
            '└────────────────────────────────────────────────────────────',
          );
        }
        return handler.next(error);
      },
    );
  }

  /// Error Interceptor - Handle common errors
  InterceptorsWrapper _errorInterceptor() {
    return InterceptorsWrapper(
      onError: (error, handler) {
        // Handle network errors
        if (error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout ||
            error.type == DioExceptionType.sendTimeout) {
          return handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              error: 'Koneksi timeout. Silakan coba lagi.',
              type: error.type,
            ),
          );
        }

        if (error.type == DioExceptionType.connectionError) {
          return handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              error: 'Tidak ada koneksi internet.',
              type: error.type,
            ),
          );
        }

        return handler.next(error);
      },
    );
  }
}

// ==================== RIVERPOD PROVIDERS ====================
// ==================== RIVERPOD PROVIDERS ====================

/// Provider for SecureStorageService
final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

/// Provider for Dio instance
final dioProvider = Provider<Dio>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return DioClient(storage).dio;
});
