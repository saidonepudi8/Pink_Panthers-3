import 'package:flutter/foundation.dart';

// Config to determins base URL based on platform and ENV var

class ApiConfig {
  ApiConfig._();

  static const String _override = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_override.isNotEmpty) return _override;

    // Web
    if(kIsWeb) return 'http://localhost:5000';

    // Android 
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5000';
    }

    // iOS
    return 'http://localhost:5000';
  }
}