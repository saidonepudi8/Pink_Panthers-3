// Model of an authenticated user

class AuthUser {
  const AuthUser({required this.id, required this.email, this.name});

  // Store unique id, email, and name
  final String id;
  final String email;
  final String? name;

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
    id: json['id'].toString(),
    email: json['email'] as String,
    name: json['name'] as String?,
  );
}

class AuthSession {
  const AuthSession({
    required this.user,
    required this.accessToken,
    this.refreshToken,
  });

  final AuthUser user;
  final String accessToken;
  final String? refreshToken;
}