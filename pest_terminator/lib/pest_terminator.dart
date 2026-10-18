import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pest_terminator/features/auth/onboarding/screens/welcome.dart';

class PestTerminator extends StatelessWidget {
  const PestTerminator({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Pest Terminator',
      // Set Welcome page as initial page
      home: WelcomeScreen(),
    );
  }
}