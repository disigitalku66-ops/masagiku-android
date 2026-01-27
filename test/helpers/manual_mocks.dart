import 'package:mockito/mockito.dart';
import 'package:masagiku_app/core/network/api_response.dart';
import 'package:masagiku_app/core/storage/secure_storage.dart';
import 'package:masagiku_app/features/auth/data/models/auth_models.dart';
import 'package:masagiku_app/features/auth/data/services/auth_api_service.dart';

// Manual Mock implementation to avoid build_runner dependency in this environment

class MockAuthApiService extends Mock implements AuthApiService {
  @override
  Future<ApiResponse<AuthResponse>> login(LoginRequest? request) {
    return super.noSuchMethod(
      Invocation.method(#login, [request]),
      returnValue: Future.value(
        ApiResponse<AuthResponse>(success: false, message: 'Mock Default'),
      ),
    );
  }

  @override
  Future<ApiResponse<AuthResponse>> register(RegisterRequest? request) {
    return super.noSuchMethod(
      Invocation.method(#register, [request]),
      returnValue: Future.value(
        ApiResponse<AuthResponse>(success: false, message: 'Mock Default'),
      ),
    );
  }
}

class MockSecureStorageService extends Mock implements SecureStorageService {
  @override
  Future<void> saveAuth({
    required String accessToken,
    String? refreshToken,
    required String userId,
  }) {
    return super.noSuchMethod(
      Invocation.method(#saveAuth, [], {
        #accessToken: accessToken,
        #refreshToken: refreshToken,
        #userId: userId,
      }),
      returnValue: Future.value(),
    );
  }
}
