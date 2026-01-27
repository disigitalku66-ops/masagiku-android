/// Core Riverpod Providers
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/dio_client.dart';
import '../storage/secure_storage.dart';

/// Secure Storage Provider
final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

/// Dio Client Provider
final dioClientProvider = Provider<DioClient>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return DioClient(storage);
});

/// Auth State
enum AuthStatus { initial, authenticated, unauthenticated }

/// Auth State Provider
final authStatusProvider = StateProvider<AuthStatus>((ref) {
  return AuthStatus.initial;
});

/// Loading State Provider (for global loading overlay)
final globalLoadingProvider = StateProvider<bool>((ref) {
  return false;
});
