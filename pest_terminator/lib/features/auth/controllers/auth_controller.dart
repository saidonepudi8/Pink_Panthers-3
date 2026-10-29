import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../../services/auth_service.dart';

class AuthController extends GetxController {
  AuthController({required AuthService authService})
    : _authService = authService;

  static AuthController get instance => Get.find();

  final AuthService _authService;
  final Rxn<User> user = Rxn<User>();
  late final StreamSubscription<User?> _userSubscription;

  bool get isLoggedIn => user.value != null;

  @override
  void onInit() {
    super.onInit();
    user.value = _authService.currentUser;
    _userSubscription = _authService.userChanges.listen((firebaseUser) {
      user.value = firebaseUser;
    });
  }

  // Sign in method for UI use
  Future<void> signIn({
    required String email,
    required String password,
  }) => _authService.signIn(email: email, password: password);

  // Register method for UI use
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) => _authService.register(name: name, email: email, password: password);

  // Sign out method for UI use
  Future<void> signOut() => _authService.signOut();

  // Handle authentication errors
  static String messageFor(FirebaseAuthException error) {
    return switch (error.code) {
      'invalid-email' => 'Enter a valid email address.',
      'user-not-found' ||
      'wrong-password' ||
      'invalid-credential' => 'The email or password is incorrect.',
      'email-already-in-use' => 'An account already exists for this email.',
      'weak-password' => 'Choose a stronger password.',
      'network-request-failed' =>
        'Could not connect. Check your internet connection and try again.',
      'too-many-requests' =>
        'Too many attempts. Please wait a while and try again.',
      'operation-not-allowed' =>
        'Email and password sign-in is not enabled for this Firebase project.',
      _ => error.message ?? 'Authentication failed. Please try again.',
    };
  }

  @override
  void onClose() {
    unawaited(_userSubscription.cancel());
    super.onClose();
  }
}
