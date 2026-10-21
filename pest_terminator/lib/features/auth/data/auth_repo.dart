import '../../../core/network/api_client.dart';
import '../models/auth_user.dart';

// Handle getting session from server
class AuthRepo {
  AuthRepo({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  // Send creds to backend and return AuthSession
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final json = await _client.post(
      '/api/auth/login',
      body: {'email': email, 'password': password},
    );

    return _sessionFromJson(json);
  }

  // Register user API call to backend
  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final json = await _client.post(
      '/api/auth/register',
      body: {'name': name, 'email': email, 'password': password}
    );

    return _sessionFromJson(json);
  }

  AuthSession _sessionFromJson(Map<String, dynamic> json) {
    return AuthSession(
      user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String?
    );
  }
}