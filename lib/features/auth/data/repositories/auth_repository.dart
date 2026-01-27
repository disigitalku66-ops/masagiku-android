/// Auth Repository
library;

import '../models/auth_models.dart';
import '../models/user_model.dart';
import '../services/auth_api_service.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/network/api_response.dart';

class AuthRepository {
  final AuthApiService _apiService;
  final SecureStorageService _storage;

  AuthRepository(this._apiService, this._storage);

  /// Login with email/phone and password
  Future<ApiResponse<User>> login(String emailOrPhone, String password) async {
    final request = LoginRequest(
      emailOrPhone: emailOrPhone,
      password: password,
    );

    final response = await _apiService.login(request);

    if (response.success && response.data != null) {
      // Save token and user data
      await _storage.saveAuth(
        accessToken: response.data!.token,
        userId: response.data!.user.id.toString(),
      );

      return ApiResponse(
        success: true,
        message: response.message,
        data: response.data!.user,
      );
    }

    return ApiResponse(
      success: false,
      message: response.message,
      errors: response.errors,
    );
  }

  /// Register new user
  Future<ApiResponse<User>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
    String? referralCode,
  }) async {
    final request = RegisterRequest(
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      password: password,
      passwordConfirmation: passwordConfirmation,
      referralCode: referralCode,
    );

    final response = await _apiService.register(request);

    if (response.success && response.data != null) {
      // Save token and user data
      await _storage.saveAuth(
        accessToken: response.data!.token,
        userId: response.data!.user.id.toString(),
      );

      return ApiResponse(
        success: true,
        message: response.message,
        data: response.data!.user,
      );
    }

    return ApiResponse(
      success: false,
      message: response.message,
      errors: response.errors,
    );
  }

  /// Social login (Google, Facebook, Apple)
  Future<ApiResponse<User>> socialLogin({
    required String token,
    required String uniqueId,
    required String email,
    required String medium,
  }) async {
    final request = SocialLoginRequest(
      token: token,
      uniqueId: uniqueId,
      email: email,
      medium: medium,
    );

    final response = await _apiService.socialLogin(request);

    if (response.success && response.data != null) {
      await _storage.saveAuth(
        accessToken: response.data!.token,
        userId: response.data!.user.id.toString(),
      );

      return ApiResponse(
        success: true,
        message: response.message,
        data: response.data!.user,
      );
    }

    return ApiResponse(
      success: false,
      message: response.message,
      errors: response.errors,
    );
  }

  /// Send OTP
  Future<ApiResponse<void>> sendOtp(String phone) async {
    return await _apiService.sendOtp(phone);
  }

  /// Verify OTP
  Future<ApiResponse<void>> verifyOtp(String phone, String otp) async {
    final request = OtpVerificationRequest(phone: phone, otp: otp);
    return await _apiService.verifyOtp(request);
  }

  /// Forgot password
  Future<ApiResponse<void>> forgotPassword(String emailOrPhone) async {
    final request = ForgotPasswordRequest(emailOrPhone: emailOrPhone);
    return await _apiService.forgotPassword(request);
  }

  /// Reset password
  Future<ApiResponse<void>> resetPassword({
    required String resetToken,
    required String password,
    required String passwordConfirmation,
  }) async {
    final request = ResetPasswordRequest(
      resetToken: resetToken,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
    return await _apiService.resetPassword(request);
  }

  /// Get current user
  Future<ApiResponse<User>> getProfile() async {
    return await _apiService.getProfile();
  }

  /// Logout
  Future<ApiResponse<void>> logout() async {
    final response = await _apiService.logout();
    await _storage.clearAuth();
    return response;
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    return await _storage.isLoggedIn();
  }

  /// Update profile
  Future<ApiResponse<void>> updateProfile({
    required String firstName,
    required String lastName,
    required String phone,
    String? password,
    String? image,
  }) async {
    final data = {'f_name': firstName, 'l_name': lastName, 'phone': phone};

    if (password != null && password.isNotEmpty) {
      data['password'] = password;
    }

    // Note: Handle image upload via MultipartFile if needed

    final response = await _apiService.updateProfile(data);

    if (response.success) {
      // Refresh profile data locally
      await getProfile();
    }

    return response;
  }

  /// Update FCM token
  Future<ApiResponse<void>> updateFcmToken(String token) async {
    await _storage.setFcmToken(token);
    return await _apiService.updateFcmToken(token);
  }
}
