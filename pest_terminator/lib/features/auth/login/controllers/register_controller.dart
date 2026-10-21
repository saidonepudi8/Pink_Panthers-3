import '../../controllers/auth_controller.dart';
import '../../data/auth_repo.dart';

class RegisterController {
  RegisterController({AuthRepo? repository})
    : _repository = repository ?? AuthRepo();

  final AuthRepo _repository;

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final session = await _repository.register(
      name: name,
      email: email,
      password: password,
    );
    await AuthController.instance.startSession(session);
  }
}
