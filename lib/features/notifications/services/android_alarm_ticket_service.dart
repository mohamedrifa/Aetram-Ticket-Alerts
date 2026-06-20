import 'dart:io';
import 'dart:ui';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';

import '../../../core/config/environment_config.dart';
import '../../tickets/data/ticket_api_service.dart';
import 'local_notification_service.dart';
import 'ticket_notification_checker.dart';

const _ticketAlarmId = 71001;

@pragma('vm:entry-point')
Future<void> ticketAlarmCallback(
  int alarmId,
  Map<String, dynamic> params,
) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  try {
    final userId = params['userId'] as int?;
    final baseUrl = params['baseUrl'] as String?;
    if (userId == null || baseUrl == null || baseUrl.isEmpty) return;
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: Duration(
          seconds: params['connectTimeoutSeconds'] as int? ?? 15,
        ),
        receiveTimeout: Duration(
          seconds: params['receiveTimeoutSeconds'] as int? ?? 20,
        ),
        headers: const {'Accept': 'application/json'},
      ),
    );
    final tickets = await TicketApiService(dio).getTickets();
    await LocalNotificationService.instance.initialize();
    await processTicketSnapshot(userId: userId, tickets: tickets);
  } catch (_) {
    // Android will invoke the next scheduled alarm after transient failures.
  }
}

abstract final class AndroidAlarmTicketService {
  static Future<void> initialize() async {
    if (Platform.isAndroid) await AndroidAlarmManager.initialize();
  }

  static Future<bool> schedule(int userId) async {
    if (!Platform.isAndroid) return false;
    await AndroidAlarmManager.cancel(_ticketAlarmId);
    return AndroidAlarmManager.periodic(
      Duration(seconds: EnvironmentConfig.androidAlarmIntervalSeconds),
      _ticketAlarmId,
      ticketAlarmCallback,
      wakeup: true,
      rescheduleOnReboot: true,
      params: {
        'userId': userId,
        'baseUrl': EnvironmentConfig.apiBaseUrl,
        'connectTimeoutSeconds': EnvironmentConfig.connectTimeoutSeconds,
        'receiveTimeoutSeconds': EnvironmentConfig.receiveTimeoutSeconds,
      },
    );
  }

  static Future<bool> cancel() => Platform.isAndroid
      ? AndroidAlarmManager.cancel(_ticketAlarmId)
      : Future.value(true);
}
