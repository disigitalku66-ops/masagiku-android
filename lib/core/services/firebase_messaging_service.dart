import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../storage/secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';

final firebaseMessagingServiceProvider = Provider<FirebaseMessagingService>((
  ref,
) {
  return FirebaseMessagingService();
});

class FirebaseMessagingService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> initialize(BuildContext context) async {
    if (_isInitialized) return;

    try {
      // 1. Request Permission
      NotificationSettings settings = await _firebaseMessaging
          .requestPermission(
            alert: true,
            badge: true,
            sound: true,
            provisional: false,
          );

      debugPrint('User granted permission: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // 2. Setup Local Notifications (for Foreground)
        await _setupLocalNotifications();

        // 3. Get Token
        final token = await _firebaseMessaging.getToken();
        debugPrint('FCM Token: $token');
        if (token != null) {
          await SecureStorageService().setFcmToken(token);
          debugPrint('FCM Token saved to SecureStorage');
        }

        // 4. Handle Foreground Messages
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          debugPrint('Got a message whilst in the foreground!');
          debugPrint('Message data: ${message.data}');

          if (message.notification != null) {
            debugPrint(
              'Message also contained a notification: ${message.notification}',
            );
            _showLocalNotification(message);
          }
        });

        // 5. Handle Background/Terminated Tap
        if (context.mounted) {
          _setupInteractedMessage(context);
        }

        _isInitialized = true;
      }
    } catch (e) {
      debugPrint('Error initializing Firebase Messaging: $e');
      // Graceful degradation: App continues without notifications
    }
  }

  Future<String?> getToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  Future<void> _setupLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        // Handle local notification tap if needed
        debugPrint('Local warning tapped: ${response.payload}');
      },
    );
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null && android != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel', // id
            'High Importance Notifications', // title
            channelDescription:
                'This channel is used for important notifications.', // description
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(),
        ),
        payload: jsonEncode(message.data),
      );
    }
  }

  // Handle taps on notifications when app is in background or terminated
  Future<void> _setupInteractedMessage(BuildContext context) async {
    // 1. Get any messages that caused the application to open from a terminated state
    RemoteMessage? initialMessage = await _firebaseMessaging
        .getInitialMessage();

    if (initialMessage != null && context.mounted) {
      _handleMessage(context, initialMessage);
    }

    // 2. Handle taps when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (context.mounted) {
        _handleMessage(context, message);
      }
    });
  }

  void _handleMessage(BuildContext context, RemoteMessage message) {
    debugPrint('Notification Logic: Handling interaction ${message.data}');

    // Example: Check for 'type' or 'route' in data
    // final type = message.data['type'];
    // final id = message.data['id'];

    // if (type == 'order_status') {
    //   context.push('${AppRoutes.orderDetail}/$id');
    // } else {
    context.go(AppRoutes.notifications); // Default fallback
    // }
  }
}
