import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract final class FirebaseEnvironmentConfig {
  static FirebaseOptions? get currentPlatform {
    final projectId = dotenv.maybeGet('FIREBASE_PROJECT_ID')?.trim() ?? '';
    final senderId =
        dotenv.maybeGet('FIREBASE_MESSAGING_SENDER_ID')?.trim() ?? '';
    final databaseUrl = dotenv.maybeGet('FIREBASE_DATABASE_URL')?.trim() ?? '';
    final storageBucket =
        dotenv.maybeGet('FIREBASE_STORAGE_BUCKET')?.trim() ?? '';
    final apiKey =
        dotenv
            .maybeGet(
              Platform.isIOS
                  ? 'FIREBASE_IOS_API_KEY'
                  : 'FIREBASE_ANDROID_API_KEY',
            )
            ?.trim() ??
        '';
    final appId =
        dotenv
            .maybeGet(
              Platform.isIOS
                  ? 'FIREBASE_IOS_APP_ID'
                  : 'FIREBASE_ANDROID_APP_ID',
            )
            ?.trim() ??
        '';
    if (projectId.isEmpty ||
        senderId.isEmpty ||
        databaseUrl.isEmpty ||
        apiKey.isEmpty ||
        appId.isEmpty) {
      return null;
    }
    return FirebaseOptions(
      apiKey: apiKey,
      appId: appId,
      messagingSenderId: senderId,
      projectId: projectId,
      databaseURL: databaseUrl,
      storageBucket: storageBucket.isEmpty ? null : storageBucket,
      iosBundleId: Platform.isIOS
          ? dotenv.maybeGet('FIREBASE_IOS_BUNDLE_ID')
          : null,
    );
  }
}
