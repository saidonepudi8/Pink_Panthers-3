import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pest_terminator/features/auth/controllers/auth_controller.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/utils/validators.dart';
import 'package:pest_terminator/navigation_menu.dart';
import '../../data/auth_repo.dart';
import '../screens/register.dart';

// One-stop where creds validation and screen transitions happens
class LoginController extends GetxController {
  final AuthRepo _repo = AuthRepo();

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxnString errMsg = RxnString();

  String? validateEmail(String? v) => Validators.email(v);
  String? validatePass(String? v) => Validators.password(v);

  Future<void> signIn() async {
    FocusManager.instance.primaryFocus?.unfocus();
    errMsg.value = null;

    // Run validators on each form field
    if(!(formKey.currentState?.validate() ?? false)) return;

    isLoading.value = true;

    try {

      // Read what user typed
      final session = await _repo.login(
        email: emailController.text.trim(),
        password: passController.text,
      );

      // Save tokens and set logged in user
      await AuthController.instance.startSession(session);

      // Clear navigation stack and show Welcome page
      Get.offAll(() => const NavigationMenu());
    }
    on ApiException catch(e) {
      errMsg.value = e.message;
    }
    catch(_) {
      errMsg.value = 'Sometimg went wrong. Try again.';
    }
    finally {
      isLoading.value = false;
    }
  }

  void goToRegister() => Get.to(() => const RegisterScreen());

  // Back returns to Welcome screen
  void goBack() => Get.back();

  @override
  void onClose() {
    emailController.dispose();
    passController.dispose();
    super.onClose();
  }
}