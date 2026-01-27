import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:masagiku_app/core/network/api_response.dart';
import 'package:masagiku_app/features/auth/data/models/auth_models.dart';
import 'package:masagiku_app/features/auth/data/models/user_model.dart';
import 'package:masagiku_app/features/auth/data/repositories/auth_repository.dart';

import '../../../../helpers/manual_mocks.dart';

void main() {
  late AuthRepository repository;
  late MockAuthApiService mockApiService;
  late MockSecureStorageService mockStorage;

  setUp(() {
    mockApiService = MockAuthApiService();
    mockStorage = MockSecureStorageService();
    repository = AuthRepository(mockApiService, mockStorage);
  });

  group('AuthRepository', () {
    const tEmail = 'test@example.com';
    const tPassword = 'password123';
    const tToken = 'access.token.123';
    const tUserId = 1;
    final tUser = User(
      id: tUserId,
      name: 'Test User',
      email: tEmail,
      phone: '08123456789',
    );
    final tAuthResponse = AuthResponse(token: tToken, user: tUser);

    test('should return User when login call is successful', () async {
      // Arrange
      when(mockApiService.login(any)).thenAnswer(
        (_) async => ApiResponse(
          success: true,
          data: tAuthResponse,
          message: 'Login success',
        ),
      );
      when(
        mockStorage.saveAuth(accessToken: tToken, userId: '$tUserId'),
      ).thenAnswer((_) async => {});

      // Act
      final result = await repository.login(tEmail, tPassword);

      // Assert
      expect(result.success, true);
      expect(result.data, tUser);
      verify(mockApiService.login(any));
      verify(mockStorage.saveAuth(accessToken: tToken, userId: '$tUserId'));
    });

    test('should return error when login call fails', () async {
      // Arrange
      when(mockApiService.login(any)).thenAnswer(
        (_) async =>
            ApiResponse(success: false, message: 'Invalid credentials'),
      );

      // Act
      final result = await repository.login(tEmail, tPassword);

      // Assert
      expect(result.success, false);
      expect(result.message, 'Invalid credentials');
      verify(mockApiService.login(any));
      verifyNoMoreInteractions(mockStorage);
    });
  });
}
