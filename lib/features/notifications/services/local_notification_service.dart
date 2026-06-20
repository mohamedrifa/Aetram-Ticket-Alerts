import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../tickets/models/ticket_model.dart';

class LocalNotificationService {
  LocalNotificationService._();
  static final instance = LocalNotificationService._();
  final _plugin = FlutterLocalNotificationsPlugin();
  static const _askedKey = 'notificationPermissionAsked';
  static void Function(int ticketId)? onTicketTap;

  Future<void> initialize() async {
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        final id = int.tryParse(response.payload ?? '');
        if (id != null) onTicketTap?.call(id);
      },
    );
    const channel = AndroidNotificationChannel(
      'ticket_alerts',
      'Ticket alerts',
      description: 'Alerts for newly created support tickets',
      importance: Importance.high,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  Future<void> explainAndRequestPermission(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_askedKey) ?? false) return;
    if (!context.mounted) return;
    final enable =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Enable Ticket Alerts'),
            content: const Text(
              'Allow notifications so you can receive alerts when new support tickets are created.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Not now'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Enable'),
              ),
            ],
          ),
        ) ??
        false;
    await prefs.setBool(_askedKey, true);
    if (enable) {
      final android = await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
      final ios = await _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      await prefs.setBool(
        'notificationPermissionGranted',
        android ?? ios ?? false,
      );
    }
  }

  Future<void> showNewTickets(List<TicketModel> tickets) async {
    if (tickets.isEmpty) return;
    final one = tickets.length == 1 ? tickets.first : null;
    final title = one == null
        ? '${tickets.length} New Support Tickets'
        : 'New Support Ticket #${one.ticketId}';
    final body = one == null
        ? 'New requests are waiting for the support team.'
        : '${one.subject} • Raised by ${one.raisedBy}';
    await _plugin.show(
      one?.ticketId ?? 5000,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'ticket_alerts',
          'Ticket alerts',
          channelDescription: 'Alerts for newly created support tickets',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: one == null ? null : '${one.ticketId}',
    );
  }
}
