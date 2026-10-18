import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pest_terminator/features/auth/login/screens/login.dart';

// Welcome Page
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // App Logo + Title
            Text("Pest Terminator"),

            Text("Smart Farming Simplified"),
            
            // Main Title
            Text("Know your Field. Grow with Confidence"),

            // Continue Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                child: Text("Get Started"),
                onPressed: () {
                  Get.to(() => const LoginScreen());
                },
              ),
            )
          ],
        )
      )
    );
  }
}