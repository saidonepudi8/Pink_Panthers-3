// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;

    return switch (defaultTargetPlatform) {
      TargetPlatform.android => android,
      TargetPlatform.iOS => ios,
      TargetPlatform.windows => windows,
      TargetPlatform.macOS || TargetPlatform.linux => throw UnsupportedError(
        'Firebase is not configured for this platform.',
      ),
      _ => throw UnsupportedError(
        'Firebase is not supported on this platform.',
      ),
    };
  }

  // Web config
  static FirebaseOptions get web => FirebaseOptions(
    apiKey: _required('WEB_API_KEY'),
    appId: _required('WEB_APP_ID'),
    messagingSenderId: _required('FIREBASE_MESSAGING_SENDER_ID'),
    projectId: _required('FIREBASE_PROJECT_ID'),
    authDomain: _required('WEB_AUTH_DOMAIN'),
    storageBucket: _required('FIREBASE_STORAGE_BUCKET'),
  );

  // Android config
  static FirebaseOptions get android => FirebaseOptions(
    apiKey: _required('ANDROID_API_KEY'),
    appId: _required('ANDROID_APP_ID'),
    messagingSenderId: _required('FIREBASE_MESSAGING_SENDER_ID'),
    projectId: _required('FIREBASE_PROJECT_ID'),
    storageBucket: _required('FIREBASE_STORAGE_BUCKET'),
  );

  // IOS config
  static FirebaseOptions get ios => FirebaseOptions(
    apiKey: _required('IOS_API_KEY'),
    appId: _required('IOS_APP_ID'),
    messagingSenderId: _required('FIREBASE_MESSAGING_SENDER_ID'),
    projectId: _required('FIREBASE_PROJECT_ID'),
    storageBucket: _required('FIREBASE_STORAGE_BUCKET'),
    iosBundleId: _required('IOS_BUNDLE_ID'),
  );

  // Windows config
  static FirebaseOptions get windows => FirebaseOptions(
    apiKey: _required('WINDOWS_API_KEY'),
    appId: _required('WINDOWS_APP_ID'),
    messagingSenderId: _required('FIREBASE_MESSAGING_SENDER_ID'),
    projectId: _required('FIREBASE_PROJECT_ID'),
    authDomain: _required('WINDOWS_AUTH_DOMAIN'),
    storageBucket: _required('FIREBASE_STORAGE_BUCKET'),
  );

  static String _required(String key) {
    final value = dotenv.env[key]?.trim();
    if (value == null || value.isEmpty || value.startsWith('REPLACE_WITH_')) {
      throw StateError('Missing Firebase configuration value: $key');
    }
    return value;
  }
}
