import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pest_terminator/navigation_menu.dart';

// Login Page
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // App Logo + Title
            Text("Login Screen"),

            // Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                child: Text("Sign In"),
                onPressed: () {
                  Get.to(() => const NavigationMenu());
                },
              ),
            ),
          ],
        )
      )
    );
  }
}