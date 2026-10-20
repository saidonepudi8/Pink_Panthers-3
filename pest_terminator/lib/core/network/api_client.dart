import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

// JSON wrapper around 'http' so every failure becomes an APIexception that user can see
class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const Duration _timeout = Duration(seconds: 15);

  Future<Map<String, dynamic>> post(
    String path, {
      Map<String, dynamic>? body,
      String? accessToken,
    }) async {
      try {
        final response = await _client
        .post(
          Uri.parse('${ApiConfig.baseUrl}$path'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            if (accessToken != null) 'Authorization': 'Bearer $accessToken',
          },
          body: jsonEncode(body ?? {})
        ).timeout(_timeout);

        final decoded = response.body.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(response.body) as Map<String, dynamic>;

        if (response.statusCode >= 200 && response.statusCode < 300) {
          return decoded;
        }

      // Exception Handling
        throw ApiException(
          (decoded['message'] ?? decoded['error'] ?? _fallback(response.statusCode)).toString(),
        );
      } 
      on ApiException { rethrow; }
      on TimeoutException { throw ApiException('Server took too long to respond.');}
      on http.ClientException { throw ApiException('Could no reach server. Check your connection and try again.');}
      on FormatException { throw ApiException('Received an unexpected response from server');}
    }

  String _fallback(int status) {
    if (status == 401) return 'Incorrect email or password.';
    if (status == 429) return 'Too many attempts. Wait a moment and try again.';
    if (status >= 500) return 'Server error. Try again shortly.';
    return 'Something went wrong. Try again.';
  }
}
