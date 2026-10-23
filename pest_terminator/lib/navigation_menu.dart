import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pest_terminator/features/auth/home/screens/homepage.dart';
import 'package:pest_terminator/features/reports/screens/report_screen.dart';

// Bottom Navigation Menu
class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());

    return Scaffold(
      // Apply Obx to update bottom NavBar menu to show selected icon
      bottomNavigationBar: Obx(
        () => NavigationBar(
          height: 80,
          elevation: 0,
          // Set default index to 0
          selectedIndex: controller.selectedIndex.value,
          // Trigger set state using GetX to update to selected page index
          onDestinationSelected: (index) => controller.selectedIndex.value = index,

          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.search_outlined),
              selectedIcon: Icon(Icons.search),
              label: 'Investigate',
            ),
            NavigationDestination(
              icon: Icon(Icons.description_outlined),
              selectedIcon: Icon(Icons.description),
              label: 'Reports'
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ]
        ),
      ),

      // Change body (content) to be the selected screen.
      body: Obx(() => controller.screens[controller.selectedIndex.value])
    );
  }
}

// Stateful widget to observe if another page index selected
class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs; // Observer variable which will be observed by widget

  // Replace containers with screens
  final screens = [
    const HomeScreen(),
    Container(color: Colors.blue), // Investigate Page
    const ReportScreen(), // Reports Page
    Container(color: Colors.purple), // Profile Page
  ];
}