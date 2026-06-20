import 'dart:io';

import 'package:flutter/services.dart';

abstract final class BatteryOptimizationService {
  static const _channel = MethodChannel(
    'com.aetram.ticket_alerts/battery_optimization',
  );

  static Future<void> requestExemptionIfNeeded() async {
    if (!Platform.isAndroid) return;
    try {
      final exempt =
          await _channel.invokeMethod<bool>('isIgnoringBatteryOptimizations') ??
          false;
      if (!exempt) {
        await _channel.invokeMethod<void>('requestIgnoreBatteryOptimizations');
      }
    } on PlatformException {
      // Permission checks must never prevent app startup.
    }
  }
}
