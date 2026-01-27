/// Masagiku App - Main Entry Point
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'app/routes.dart';
import 'app/theme.dart';
import 'core/services/firebase_messaging_service.dart';
import 'core/services/analytics_service.dart';
import 'core/widgets/offline_builder.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'firebase_options.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (Safe Mode)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialized successfully');

    if (kDebugMode) {
      try {
        final String host = Platform.isAndroid ? '10.0.2.2' : 'localhost';
        await FirebaseAuth.instance.useAuthEmulator(host, 9099);
        FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
        debugPrint('Connected to Firebase Emulators at $host');
      } catch (e) {
        debugPrint('Failed to connect to emulators: $e');
      }
    }
  } catch (e) {
    debugPrint('Warning: Firebase initialization failed (Config missing?): $e');
  }

  // Initialize Hive
  await Hive.initFlutter();
  await Hive.openBox('authBox');
  await Hive.openBox('cartBox');
  await Hive.openBox('settingsBox');

  // Set orientation to portrait only
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runZonedGuarded(
    () {
      runApp(const ProviderScope(child: MasagiApp()));
    },
    (error, stack) {
      debugPrint('Global Error Caught: $error');
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    },
  );
}

class MasagiApp extends ConsumerStatefulWidget {
  const MasagiApp({super.key});

  @override
  ConsumerState<MasagiApp> createState() => _MasagiAppState();
}

class _MasagiAppState extends ConsumerState<MasagiApp> {
  @override
  void initState() {
    super.initState();
    // Initialize Firebase Messaging after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initFirebaseMessaging();
    });
  }

  Future<void> _initFirebaseMessaging() async {
    final messagingService = ref.read(firebaseMessagingServiceProvider);
    await messagingService.initialize(context);

    // Log app open
    final analytics = ref.read(analyticsServiceProvider);
    await analytics.logEvent(name: 'app_open');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Masagiku',
      debugShowCheckedModeBanner: false,

      // Theme
      theme: MasagiTheme.lightTheme,

      // Router
      routerConfig: AppRouter.router,

      // Global Builder (Offline Wrapper)
      builder: (context, child) {
        return OfflineBuilder(child: child!);
      },

      // Localization (will be added later)
      // localizationsDelegates: const [...],
      // supportedLocales: const [...],
    );
  }
}
