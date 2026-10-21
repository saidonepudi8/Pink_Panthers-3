import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_sizes.dart';

// Register Screen
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Back button
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(onPressed: Get.back, icon: const Icon(Icons.chevron_left_rounded, size:28)),
      ),

      // Create an account section 
      // TODO: Need to fill with email and pass slots.
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Text('Create an account',
          style: Theme.of(context).textTheme.headlineLarge
        )
      )
    );
  }
}
