import 'package:pest_terminator/features/auth/controllers/auth_controller.dart';

import '../../data/auth_repo.dart';

// Accept credentials and throw expection on failure. Screen-owned state
class LoginController {
  final AuthRepo _repo = AuthRepo();

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    final session = await _repo.login(email: email, password: password);
    await AuthController.instance.startSession(session);
  }
}