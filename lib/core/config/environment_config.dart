import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvironmentConfig {
  EnvironmentConfig._();

  static String get appName =>
      dotenv.get('APP_NAME', fallback: 'Aetram Ticket Support');
  static String get apiBaseUrl =>
      dotenv.get('API_BASE_URL').replaceAll(RegExp(r'/+$'), '');
  static int get connectTimeoutSeconds =>
      dotenv.getInt('API_CONNECT_TIMEOUT_SECONDS', fallback: 15);
  static int get receiveTimeoutSeconds =>
      dotenv.getInt('API_RECEIVE_TIMEOUT_SECONDS', fallback: 20);
  static int get pollingSeconds =>
      dotenv.getInt('TICKET_POLLING_SECONDS', fallback: 60);
  static int get androidAlarmIntervalSeconds =>
      dotenv.getInt('ANDROID_ALARM_INTERVAL_SECONDS', fallback: 10);
  static int get backgroundCheckMinutes =>
      dotenv.getInt('BACKGROUND_CHECK_MINUTES', fallback: 15);
  static bool get enableBackgroundCheck =>
      dotenv.getBool('ENABLE_BACKGROUND_CHECK', fallback: true);
}
