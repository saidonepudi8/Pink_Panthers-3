import 'package:flutter/material.dart';

// Home Page
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          // Align vertially
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Temporary Title
            Text("Home Page 😎"),
          ],
        ),
      )
    );
  }
}