import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'features/notifications/services/background_sync_service.dart';
import 'features/notifications/services/local_notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await LocalNotificationService.instance.initialize();
  if (Platform.isAndroid || Platform.isIOS) {
    await BackgroundSyncService.initialize();
  }
  runApp(const ProviderScope(child: AetramApp()));
}
