import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:yalla_5roga/app.dart';
import 'package:yalla_5roga/core/di/app_dependencies.dart';
import 'package:yalla_5roga/core/monitoring/analytics_service.dart';
import 'package:yalla_5roga/core/monitoring/crashlytics_service.dart';
import 'package:yalla_5roga/core/monitoring/performance_service.dart';
import 'package:yalla_5roga/features/notifications/data/services/fcm_background_handler.dart';
import 'package:yalla_5roga/firebase_options.dart';

Future<void> main() async {
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    await CrashlyticsService.instance.initialize();
    await AnalyticsService.instance.initialize();
    await PerformanceService.instance.initialize();

    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      unawaited(
        CrashlyticsService.instance.recordFlutterFatalError(details),
      );
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      unawaited(
        CrashlyticsService.instance.recordError(
          error,
          stack,
          reason: 'platform_dispatcher',
          fatal: true,
        ),
      );
      return true;
    };

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    final deps = await AppDependencies.create();
    runApp(App(deps: deps));
  }, (error, stack) {
    debugPrint('[ZonedError] $error\n$stack');
    unawaited(
      CrashlyticsService.instance.recordError(
        error,
        stack,
        reason: 'runZonedGuarded',
        fatal: true,
      ),
    );
  });
}
