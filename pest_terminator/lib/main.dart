import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'firebase_options.dart';
import 'pest_terminator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load env vars
  await dotenv.load(fileName: 'lib/.env');

  // Connect to Firebase backend
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const PestTerminator());
}
