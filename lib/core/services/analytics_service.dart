import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    try {
      await _analytics.logEvent(name: name, parameters: parameters);
      debugPrint('Analytics: Logged event $name');
    } catch (e) {
      debugPrint('Analytics Error: $e');
    }
  }

  Future<void> setUserProperties({required String userId, String? role}) async {
    try {
      await _analytics.setUserId(id: userId);
      if (role != null) {
        await _analytics.setUserProperty(name: 'role', value: role);
      }
    } catch (e) {
      debugPrint('Analytics Error: $e');
    }
  }

  Future<void> logLogin({String method = 'email'}) async {
    try {
      await _analytics.logLogin(loginMethod: method);
    } catch (e) {
      debugPrint('Analytics Error: $e');
    }
  }

  Future<void> logViewItem({
    required String itemId,
    required String itemName,
    required String itemCategory,
  }) async {
    try {
      await _analytics.logViewItem(
        currency: 'IDR',
        value: 0, // Optional
        items: [
          AnalyticsEventItem(
            itemId: itemId,
            itemName: itemName,
            itemCategory: itemCategory,
          ),
        ],
      );
    } catch (e) {
      debugPrint('Analytics Error: $e');
    }
  }

  Future<void> logAddToCart({
    required String itemId,
    required String itemName,
    required double value,
  }) async {
    try {
      await _analytics.logAddToCart(
        currency: 'IDR',
        value: value,
        items: [AnalyticsEventItem(itemId: itemId, itemName: itemName)],
      );
    } catch (e) {
      debugPrint('Analytics Error: $e');
    }
  }
}
