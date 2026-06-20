import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:workmanager/workmanager.dart';

import '../../../core/config/environment_config.dart';
import '../../../core/storage/auth_storage.dart';
import '../../tickets/data/ticket_api_service.dart';
import '../utils/new_ticket_detector.dart';
import 'local_notification_service.dart';
import 'seen_ticket_store.dart';

const _backgroundTask = 'aetramTicketBackgroundCheck';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    try {
      await dotenv.load(fileName: '.env');
      final user = await AuthStorage().restore();
      if (user == null) return true;
      final dio = Dio(
        BaseOptions(
          baseUrl: EnvironmentConfig.apiBaseUrl,
          connectTimeout: Duration(
            seconds: EnvironmentConfig.connectTimeoutSeconds,
          ),
          receiveTimeout: Duration(
            seconds: EnvironmentConfig.receiveTimeoutSeconds,
          ),
        ),
      );
      final tickets = await TicketApiService(dio).getTickets();
      final store = SeenTicketStore();
      final seen = await store.read(user.backendUserId);
      if (seen == null) {
        await store.write(user.backendUserId, tickets.map((e) => e.ticketId));
        return true;
      }
      final fresh = detectNewOpenTickets(tickets, seen);
      await LocalNotificationService.instance.initialize();
      await LocalNotificationService.instance.showNewTickets(fresh);
      await store.write(user.backendUserId, {
        ...seen,
        ...tickets.map((e) => e.ticketId),
      });
      return true;
    } catch (_) {
      return false;
    }
  });
}

abstract final class BackgroundSyncService {
  static Future<void> initialize() async {
    if (!EnvironmentConfig.enableBackgroundCheck) return;
    await Workmanager().initialize(callbackDispatcher);
    if (Platform.isAndroid) {
      await Workmanager().registerPeriodicTask(
        _backgroundTask,
        _backgroundTask,
        frequency: Duration(
          minutes: EnvironmentConfig.backgroundCheckMinutes < 15
              ? 15
              : EnvironmentConfig.backgroundCheckMinutes,
        ),
        existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
      );
    }
  }
}
