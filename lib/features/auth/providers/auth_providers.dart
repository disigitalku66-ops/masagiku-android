/// Auth Providers (Riverpod)
library;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/user_model.dart';
import '../data/services/auth_api_service.dart';
import '../data/repositories/auth_repository.dart';
import '../../../core/providers/core_providers.dart';

/// Auth API Service Provider
final authApiServiceProvider = Provider<AuthApiService>((ref) {
  final dio = ref.watch(dioClientProvider).dio;
  return AuthApiService(dio);
});

/// Auth Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiService = ref.watch(authApiServiceProvider);
  final storage = ref.watch(secureStorageProvider);
  return AuthRepository(apiService, storage);
});

/// Auth State
enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({AuthStatus? status, User? user, String? errorMessage}) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;
}

/// Auth Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  // ignore: unused_field
  final Ref _ref;

  AuthNotifier(this._repository, this._ref) : super(const AuthState()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final isLoggedIn = await _repository.isLoggedIn();
    if (isLoggedIn) {
      await refreshUser();

      // Update FCM Token locally without awaiting or checking result to avoid blocking
      await refreshUser();
      _updateFcmToken();
    } else {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<bool> login(String emailOrPhone, String password) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    final response = await _repository.login(emailOrPhone, password);

    if (response.success && response.data != null) {
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: response.data,
      );
      return true;
    }

    state = state.copyWith(
      status: AuthStatus.error,
      errorMessage: response.message ?? 'Login gagal',
    );
    return false;
  }

  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
    String? referralCode,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    final response = await _repository.register(
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      password: password,
      passwordConfirmation: passwordConfirmation,
      referralCode: referralCode,
    );

    if (response.success && response.data != null) {
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: response.data,
      );
      return true;
    }

    state = state.copyWith(
      status: AuthStatus.error,
      errorMessage: response.message ?? 'Registrasi gagal',
    );
    return false;
  }

  Future<bool> socialLogin({
    required String token,
    required String uniqueId,
    required String email,
    required String medium,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    final response = await _repository.socialLogin(
      token: token,
      uniqueId: uniqueId,
      email: email,
      medium: medium,
    );

    if (response.success && response.data != null) {
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: response.data,
      );
      return true;
    }

    state = state.copyWith(
      status: AuthStatus.error,
      errorMessage: response.message ?? 'Social login gagal',
    );
    return false;
  }

  Future<void> refreshUser() async {
    final response = await _repository.getProfile();

    if (response.success && response.data != null) {
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: response.data,
      );
    } else {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<bool> updateProfile({
    required String firstName,
    required String lastName,
    required String phone,
    String? password,
  }) async {
    // Note: Don't set global loading status to avoid full screen loader if not desired
    // Or set it if you want global blocking
    // state = state.copyWith(status: AuthStatus.loading);

    final response = await _repository.updateProfile(
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      password: password,
    );

    if (response.success) {
      await refreshUser();
      return true;
    }

    state = state.copyWith(
      errorMessage: response.message ?? 'Update profil gagal',
    );
    return false;
  }

  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading);
    await _repository.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  Future<void> _updateFcmToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await _repository.updateFcmToken(token);
      }
    } catch (e) {
      // Ignore errors (e.g. if Firebase not initialized)
    }
  }
}

/// Auth State Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository, ref);
});

/// Current User Provider
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).user;
});

/// Is Authenticated Provider
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

/// Forgot Password State
class ForgotPasswordState {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;
  final String? successMessage;

  const ForgotPasswordState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
    this.successMessage,
  });

  ForgotPasswordState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
    String? successMessage,
  }) {
    return ForgotPasswordState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

/// Forgot Password Notifier
class ForgotPasswordNotifier extends StateNotifier<ForgotPasswordState> {
  final AuthRepository _repository;

  ForgotPasswordNotifier(this._repository) : super(const ForgotPasswordState());

  Future<bool> sendResetLink(String emailOrPhone) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final response = await _repository.forgotPassword(emailOrPhone);

    if (response.success) {
      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        successMessage: response.message ?? 'Link reset password telah dikirim',
      );
      return true;
    }

    state = state.copyWith(
      isLoading: false,
      errorMessage: response.message ?? 'Gagal mengirim reset password',
    );
    return false;
  }

  Future<bool> resetPassword({
    required String resetToken,
    required String password,
    required String passwordConfirmation,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final response = await _repository.resetPassword(
      resetToken: resetToken,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );

    if (response.success) {
      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        successMessage: response.message ?? 'Password berhasil direset',
      );
      return true;
    }

    state = state.copyWith(
      isLoading: false,
      errorMessage: response.message ?? 'Gagal reset password',
    );
    return false;
  }

  void reset() {
    state = const ForgotPasswordState();
  }
}

/// Forgot Password Provider
final forgotPasswordProvider =
    StateNotifierProvider<ForgotPasswordNotifier, ForgotPasswordState>((ref) {
      final repository = ref.watch(authRepositoryProvider);
      return ForgotPasswordNotifier(repository);
    });

/// OTP State
class OtpState {
  final bool isLoading;
  final bool isOtpSent;
  final bool isVerified;
  final String? errorMessage;
  final int resendCountdown;

  const OtpState({
    this.isLoading = false,
    this.isOtpSent = false,
    this.isVerified = false,
    this.errorMessage,
    this.resendCountdown = 0,
  });

  OtpState copyWith({
    bool? isLoading,
    bool? isOtpSent,
    bool? isVerified,
    String? errorMessage,
    int? resendCountdown,
  }) {
    return OtpState(
      isLoading: isLoading ?? this.isLoading,
      isOtpSent: isOtpSent ?? this.isOtpSent,
      isVerified: isVerified ?? this.isVerified,
      errorMessage: errorMessage,
      resendCountdown: resendCountdown ?? this.resendCountdown,
    );
  }
}

/// OTP Notifier
class OtpNotifier extends StateNotifier<OtpState> {
  final AuthRepository _repository;

  OtpNotifier(this._repository) : super(const OtpState());

  Future<bool> sendOtp(String phone) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final response = await _repository.sendOtp(phone);

    if (response.success) {
      state = state.copyWith(
        isLoading: false,
        isOtpSent: true,
        resendCountdown: 60,
      );
      _startCountdown();
      return true;
    }

    state = state.copyWith(
      isLoading: false,
      errorMessage: response.message ?? 'Gagal mengirim OTP',
    );
    return false;
  }

  Future<bool> verifyOtp(String phone, String otp) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final response = await _repository.verifyOtp(phone, otp);

    if (response.success) {
      state = state.copyWith(isLoading: false, isVerified: true);
      return true;
    }

    state = state.copyWith(
      isLoading: false,
      errorMessage: response.message ?? 'OTP tidak valid',
    );
    return false;
  }

  void _startCountdown() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (state.resendCountdown > 0) {
        state = state.copyWith(resendCountdown: state.resendCountdown - 1);
        return true;
      }
      return false;
    });
  }

  void reset() {
    state = const OtpState();
  }
}

/// OTP Provider
final otpProvider = StateNotifierProvider<OtpNotifier, OtpState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return OtpNotifier(repository);
});
