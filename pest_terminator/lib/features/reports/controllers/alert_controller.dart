import 'package:get/get.dart';

import '../../../navigation_menu.dart';
import '../models/pest_alert.dart';

// Holds alert list, search query and alert being investigated. BOTH Reports & Investigate read from this controller.
class AlertsController extends GetxController {
  static AlertsController get instance => Get.find();

  // Tab positions in bottom nav: Home, Investigate (1), Reports (2), Profile
  static const int _investigateTab = 1;
  static const int _reportsTab = 2;

  // TODO: Replace sample alerts with data loaded from Firestore.
  final alerts = <PestAlert>[
    PestAlert(
      id: '1',
      title: 'Pest Detected',
      species: 'Unknown',
      field: 'North Field',
      crop: 'Wheat',
      priority: AlertPriority.high,
      status: AlertStatus.newDetection,
      detectedAt: DateTime(2025, 5, 14, 7, 42),
      matchPercent: 89,
      imageSrc: 'rodent.png',
    ),
    PestAlert(
      id: '2',
      title: 'Pest detected',
      species: 'Unknown',
      field: 'East Field',
      crop: 'Corn',
      priority: AlertPriority.medium,
      status: AlertStatus.monitoring,
      detectedAt: DateTime(2025, 5, 10, 6, 15),
    ),
    PestAlert(
      id: '3',
      title: 'Pest detected',
      species: 'Unknown',
      field: 'South Field',
      crop: 'Soybean',
      priority: AlertPriority.low,
      status: AlertStatus.resolved,
      detectedAt: DateTime(2025, 5, 4, 18, 30),
    ),
  ].obs;

  final stats = const AlertStats(total: 18, active: 3, resolved: 12).obs;
  final query = ''.obs;
  final selected = Rxn<PestAlert>();

  @override
  void onInit() {
    super.onInit();
    // Investigate tab opens on the newest unresolved alert by default
    selected.value = _newestFirst
        .where((a) => a.status != AlertStatus.resolved)
        .firstOrNull;
  }

  List<PestAlert> get _newestFirst =>
      [...alerts]..sort((a, b) => b.detectedAt.compareTo(a.detectedAt));

  // Alerts matching the search box, newest first.
  List<PestAlert> get filtered {
    final q = query.value.trim().toLowerCase();
    if (q.isEmpty) return _newestFirst;
    return _newestFirst.where((a) => a.searchText.contains(q)).toList();
  }

  // Newest-first order.
  Map<String, List<PestAlert>> get groupedByMonth {
    final groups = <String, List<PestAlert>>{};
    for (final alert in filtered) {
      groups.putIfAbsent(alert.monthYear, () => []).add(alert);
    }
    return groups;
  }

  // Control nav between two tabs: investigate and reports
  void investigate(PestAlert alert) {
    selected.value = alert;
    Get.find<NavigationController>().selectedIndex.value = _investigateTab;
  }

  void backToAlerts() {
    Get.find<NavigationController>().selectedIndex.value = _reportsTab;
  }
}