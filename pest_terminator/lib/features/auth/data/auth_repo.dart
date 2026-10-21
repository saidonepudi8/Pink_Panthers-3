import '../../../core/network/api_client.dart';
import '../models/auth_user.dart';

// Handle getting session from server
class AuthRepo {
  AuthRepo({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  // Send creds to backend and return AuthSession
  Future<AuthSession> login({
    required String email,
    required String password
  }) async {
    final json = await _client.post(
      '/api/auth/login',
      body: {'email': email, 'password': password},
    );

    return AuthSession(
      user: AuthUser.fromJson(json['user'] as Map<String, dynamic>), 
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String?
    );
  }
}