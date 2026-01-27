/// Auth API Service
library;

import 'package:dio/dio.dart';
import '../models/auth_models.dart';
import '../models/user_model.dart';
import '../../../../core/network/api_response.dart';

class AuthApiService {
  final Dio _dio;

  AuthApiService(this._dio);

  /// Login with email/phone and password
  Future<ApiResponse<AuthResponse>> login(LoginRequest request) async {
    try {
      final response = await _dio.post('/auth/login', data: request.toJson());

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return ApiResponse(
          success: true,
          message: data['message'] as String?,
          data: AuthResponse.fromJson(data),
        );
      }

      return ApiResponse(
        success: false,
        message: response.data['message'] ?? 'Login gagal',
        errors: _extractErrors(response.data),
      );
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message: e.response?.data?['message'] ?? e.message ?? 'Login gagal',
        errors: _extractErrors(e.response?.data),
      );
    }
  }

  /// Register new user
  Future<ApiResponse<AuthResponse>> register(RegisterRequest request) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        return ApiResponse(
          success: true,
          message: data['message'] as String?,
          data: AuthResponse.fromJson(data),
        );
      }

      return ApiResponse(
        success: false,
        message: response.data['message'] ?? 'Registrasi gagal',
        errors: _extractErrors(response.data),
      );
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message:
            e.response?.data?['message'] ?? e.message ?? 'Registrasi gagal',
        errors: _extractErrors(e.response?.data),
      );
    }
  }

  /// Social login (Google, Facebook, Apple)
  Future<ApiResponse<AuthResponse>> socialLogin(
    SocialLoginRequest request,
  ) async {
    try {
      final response = await _dio.post(
        '/auth/social-login',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return ApiResponse(
          success: true,
          message: data['message'] as String?,
          data: AuthResponse.fromJson(data),
        );
      }

      return ApiResponse(
        success: false,
        message: response.data['message'] ?? 'Social login gagal',
        errors: _extractErrors(response.data),
      );
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message:
            e.response?.data?['message'] ?? e.message ?? 'Social login gagal',
        errors: _extractErrors(e.response?.data),
      );
    }
  }

  /// Send OTP to phone
  Future<ApiResponse<void>> sendOtp(String phone) async {
    try {
      final response = await _dio.post(
        '/auth/check-phone',
        data: {'phone': phone},
      );

      return ApiResponse(
        success: response.statusCode == 200,
        message: response.data['message'] as String?,
      );
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message: e.response?.data?['message'] ?? 'Gagal mengirim OTP',
      );
    }
  }

  /// Verify OTP
  Future<ApiResponse<void>> verifyOtp(OtpVerificationRequest request) async {
    try {
      final response = await _dio.post(
        '/auth/verify-phone',
        data: request.toJson(),
      );

      return ApiResponse(
        success: response.statusCode == 200,
        message: response.data['message'] as String?,
      );
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message: e.response?.data?['message'] ?? 'OTP tidak valid',
      );
    }
  }

  /// Forgot password - send reset link/OTP
  Future<ApiResponse<void>> forgotPassword(
    ForgotPasswordRequest request,
  ) async {
    try {
      final response = await _dio.post(
        '/auth/forgot-password',
        data: request.toJson(),
      );

      return ApiResponse(
        success: response.statusCode == 200,
        message: response.data['message'] as String?,
      );
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message:
            e.response?.data?['message'] ?? 'Gagal mengirim reset password',
      );
    }
  }

  /// Reset password with token
  Future<ApiResponse<void>> resetPassword(ResetPasswordRequest request) async {
    try {
      final response = await _dio.put(
        '/auth/reset-password',
        data: request.toJson(),
      );

      return ApiResponse(
        success: response.statusCode == 200,
        message: response.data['message'] as String?,
      );
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message: e.response?.data?['message'] ?? 'Gagal reset password',
      );
    }
  }

  /// Get current user profile
  Future<ApiResponse<User>> getProfile() async {
    try {
      final response = await _dio.get('/customer/info');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return ApiResponse(
          success: true,
          data: User.fromJson(data['data'] ?? data),
        );
      }

      return ApiResponse(
        success: false,
        message: response.data['message'] ?? 'Gagal mengambil profil',
      );
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message: e.response?.data?['message'] ?? 'Gagal mengambil profil',
      );
    }
  }

  /// Logout
  Future<ApiResponse<void>> logout() async {
    try {
      final response = await _dio.post('/auth/logout');
      return ApiResponse(
        success: response.statusCode == 200,
        message: response.data['message'] as String?,
      );
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message: e.response?.data?['message'] ?? 'Gagal logout',
      );
    }
  }

  /// Update profile (name, phone, etc)
  Future<ApiResponse<void>> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/customer/update-profile', data: data);

      return ApiResponse(
        success: response.statusCode == 200,
        message: response.data['message'] as String?,
      );
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message:
            e.response?.data?['message'] ?? e.message ?? 'Gagal update profil',
        errors: _extractErrors(e.response?.data),
      );
    }
  }

  /// Update FCM token
  Future<ApiResponse<void>> updateFcmToken(String token) async {
    try {
      final response = await _dio.put(
        '/customer/cm-firebase-token',
        data: {'cm_firebase_token': token},
      );
      return ApiResponse(
        success: response.statusCode == 200,
        message: response.data['message'] as String?,
      );
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message: e.response?.data?['message'] ?? 'Gagal update FCM token',
      );
    }
  }

  List<String>? _extractErrors(dynamic data) {
    if (data == null) return null;
    if (data is Map) {
      final errors = data['errors'];
      if (errors is Map) {
        final List<String> errorList = [];
        errors.forEach((key, value) {
          if (value is List) {
            errorList.addAll(value.map((e) => e.toString()));
          } else {
            errorList.add(value.toString());
          }
        });
        return errorList.isEmpty ? null : errorList;
      }
    }
    return null;
  }
}
