/// App-wide constants
library;

import 'package:flutter/foundation.dart';

abstract class AppConstants {
  // API Configuration
  static const String apiVersion = 'v4';

  // For development (Android Emulator localhost)
  static const String devBaseUrl = 'http://10.0.2.2/api';

  // For production
  static const String prodBaseUrl = 'https://masagiku.com/api';

  // Platform-aware Base URL
  static String get baseUrl {
    if (kIsWeb) {
      // For Web (Browser) - Laragon Fallback (if domain fails)
      // Usually: http://localhost/[folder_name]/public/api
      return 'http://localhost/masagiku/public/api';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      // For Android Emulator (10.0.2.2 maps to host localhost)
      return 'http://10.0.2.2/api';
    } else {
      // Default / iOS Simulator
      return 'http://localhost/api';
    }
  }

  // API Endpoints prefix
  static String get apiUrl => '$baseUrl/$apiVersion';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Cache
  static const Duration cacheMaxAge = Duration(hours: 1);
  static const int maxCacheSize = 50 * 1024 * 1024; // 50 MB

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Image
  static const int imageQuality = 85;
  static const int maxImageWidth = 1080;
  static const int maxImageHeight = 1080;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Touch Targets (dp)
  static const double minTouchTarget = 48.0;
  static const double buttonHeight = 52.0;
  static const double iconButtonSize = 44.0;

  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;
  static const double radiusCircular = 999.0;

  // Spacing
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;

  // Elevation
  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;
}
