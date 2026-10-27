import 'package:get/get.dart';

import '../../../navigation_menu.dart';
import '../models/pest_alert.dart';
import '../data/alerts_repository.dart';

// Holds alert list, search query and alert being investigated. BOTH Reports & Investigate read from this controller.
class AlertsController extends GetxController {
  static AlertsController get instance => Get.find();

  // Tab positions in bottom nav: Home, Investigate (1), Reports (2), Profile
  static const int _investigateTab = 1;
  static const int _reportsTab = 2;

  final _repository = AlertsRepository();

  // TODO(api): replace with data from Flask (same pattern as AuthController)
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

  // TODO: Need to pull this from backend
  final stats = const AlertStats(total: 18, active: 3, resolved: 12).obs;

  final query = ''.obs;
  final selected = Rxn<PestAlert>();

  // Classification results for selected pest
  final results = <AnalysisResult>[].obs;
  final isPredicting = false.obs;
  final predError = RxnString();


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

  // Called from Reports to select a pest alert to investigate in Investigate page
  void investigate(PestAlert alert) {

    // Avoid showing another pest alert's results
    if(selected.value?.id != alert.id) {
      results.clear();
      predError.value = null;
    }

    selected.value = alert;
    Get.find<NavigationController>().selectedIndex.value = _investigateTab;
  }

  // Called by Predict/Investigate button to display once results is populated
  Future<void> runPrediction() async {
    final alert = selected.value;
    if(alert == null) return;

    isPredicting.value = true;
    predError.value = null;

    // Await repository to fill results data
    try {
      final result = await _repository.classify(alert);

      // User switched alerts
      if(selected.value?.id != alert.id) return;
      results.assignAll(result);
    } catch (e) {
      predError.value = 'Could not complete analysis. Try again.';
    } finally {
      isPredicting.value = false;
    }
  }

  void backToAlerts() {
    Get.find<NavigationController>().selectedIndex.value = _reportsTab;
  }
}