/// Secure Storage Service for tokens and sensitive data
library;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/storage_keys.dart';

class SecureStorageService {
  late final FlutterSecureStorage _storage;

  SecureStorageService() {
    _storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    );
  }

  // Access Token
  Future<String?> getAccessToken() async {
    return await _storage.read(key: StorageKeys.accessToken);
  }

  Future<void> setAccessToken(String token) async {
    await _storage.write(key: StorageKeys.accessToken, value: token);
  }

  // Refresh Token
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: StorageKeys.refreshToken);
  }

  Future<void> setRefreshToken(String token) async {
    await _storage.write(key: StorageKeys.refreshToken, value: token);
  }

  // User ID
  Future<String?> getUserId() async {
    return await _storage.read(key: StorageKeys.userId);
  }

  Future<void> setUserId(String id) async {
    await _storage.write(key: StorageKeys.userId, value: id);
  }

  // FCM Token
  Future<String?> getFcmToken() async {
    return await _storage.read(key: StorageKeys.fcmToken);
  }

  Future<void> setFcmToken(String token) async {
    await _storage.write(key: StorageKeys.fcmToken, value: token);
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  // Save auth data
  Future<void> saveAuth({
    required String accessToken,
    String? refreshToken,
    required String userId,
  }) async {
    await setAccessToken(accessToken);
    if (refreshToken != null) {
      await setRefreshToken(refreshToken);
    }
    await setUserId(userId);
  }

  // Clear auth data
  Future<void> clearAuth() async {
    await _storage.delete(key: StorageKeys.accessToken);
    await _storage.delete(key: StorageKeys.refreshToken);
    await _storage.delete(key: StorageKeys.userId);
    await _storage.delete(key: StorageKeys.userName);
    await _storage.delete(key: StorageKeys.userEmail);
    await _storage.delete(key: StorageKeys.userPhone);
    await _storage.delete(key: StorageKeys.userImage);
  }

  // Clear all data
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  // Generic read
  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  // Generic write
  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  // Generic delete
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }
}
