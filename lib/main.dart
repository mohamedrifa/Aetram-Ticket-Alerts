import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app.dart';
import 'core/config/firebase_environment_config.dart';
import 'features/notifications/services/background_sync_service.dart';
import 'features/notifications/services/android_alarm_ticket_service.dart';
import 'features/notifications/services/local_notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  final firebaseOptions = FirebaseEnvironmentConfig.currentPlatform;
  if (firebaseOptions != null) {
    try {
      await Firebase.initializeApp(options: firebaseOptions);
    } on FirebaseException catch (error) {
      debugPrint('Firebase initialization skipped: ${error.message}');
    }
  } else {
    debugPrint('Firebase initialization skipped: configuration is missing.');
  }
  await LocalNotificationService.instance.initialize();
  await AndroidAlarmTicketService.initialize();
  if (Platform.isAndroid || Platform.isIOS) {
    await BackgroundSyncService.initialize();
  }
  runApp(const ProviderScope(child: AetramApp()));
}
