import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pest_terminator/features/auth/controllers/auth_controller.dart';
import 'package:pest_terminator/features/auth/onboarding/screens/welcome.dart';
import 'package:pest_terminator/features/reports/controllers/alert_controller.dart';
import 'package:pest_terminator/navigation_menu.dart';
import 'package:pest_terminator/services/auth_service.dart';

class PestTerminator extends StatelessWidget {
  const PestTerminator({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Pest Terminator',
      initialBinding: BindingsBuilder(() {
        Get.lazyPut(() => AlertsController(), fenix: true);
        Get.put(AuthService(), permanent: true);
        Get.put(
          AuthController(authService: Get.find<AuthService>()),
          permanent: true,
        );
      }),
      home: const _AuthGate(),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  // If authenticated user, take to Home page. Else, take to Welcome page.
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AuthController.instance.isLoggedIn
          ? const NavigationMenu()
          : const WelcomeScreen(),
    );
  }
}