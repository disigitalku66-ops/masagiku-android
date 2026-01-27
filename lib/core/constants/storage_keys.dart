/// Storage keys for secure storage and Hive
library;

abstract class StorageKeys {
  // Auth tokens
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String tokenExpiry = 'token_expiry';

  // User data
  static const String userId = 'user_id';
  static const String userName = 'user_name';
  static const String userEmail = 'user_email';
  static const String userPhone = 'user_phone';
  static const String userImage = 'user_image';

  // FCM
  static const String fcmToken = 'fcm_token';

  // App settings
  static const String isFirstLaunch = 'is_first_launch';
  static const String languageCode = 'language_code';
  static const String themeMode = 'theme_mode';

  // Cart (local)
  static const String cartItems = 'cart_items';

  // Recently viewed
  static const String recentProducts = 'recent_products';
  static const String searchHistory = 'search_history';
}

/// Hive box names
abstract class HiveBoxes {
  static const String settings = 'settings';
  static const String cache = 'cache';
  static const String cart = 'cart';
  static const String user = 'user';
}
