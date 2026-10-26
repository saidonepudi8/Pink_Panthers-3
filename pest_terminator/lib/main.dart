import 'package:flutter/material.dart';
import 'pest_terminator.dart';
import 'package:get/get.dart';
import 'features/reports/controllers/alert_controller.dart';
import 'features/auth/controllers/auth_controller.dart';

void main() {
  Get.put(AuthController(), permanent: true); // must exist for session from first frame
  Get.lazyPut(() => AlertsController(), fenix: true);
  runApp(const PestTerminator());
}

