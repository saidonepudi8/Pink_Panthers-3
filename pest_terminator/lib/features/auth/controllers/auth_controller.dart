import 'package:get/get.dart';
import '../../../core/network/token_storage.dart';
import '../models/auth_user.dart';

// Set app-wide session state. Registered once in main.dart as permanent controller.
class AuthController extends GetxController {

  // Convenience shortcut for use in other files
  static AuthController get instance => Get.find();

  final TokenStorage _tokens = TokenStorage();
  final Rxn<AuthUser> user = Rxn<AuthUser>();

  // if user obj exists, then logged in
  bool get isLoggedIn => user.value != null;

  // If user logged in, save tokens to persistent storage so user stays logged in across app restarts
  Future<void> startSession(AuthSession sesh) async {
    await _tokens.save(accessToken: sesh.accessToken, refreshToken: sesh.refreshToken);
    user.value = sesh.user;  // update that user is logged in
  }

  Future<void> signOut() async {
    await _tokens.clear();
    user.value = null;  // update that user is logged out
  }
}