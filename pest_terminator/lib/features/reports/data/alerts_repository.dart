import '../models/pest_alert.dart';

class AlertsRepository {
  Future<List<AnalysisResult>> classify(PestAlert alert) async {
    // Temporary model training simulation, remove once we have model training code
    await Future.delayed(const Duration(seconds: 2));

    final risk = alert.priority.name;

    // Dummy data
    return [
      AnalysisResult('label0', 'value0'),
      AnalysisResult('Risk level', risk[0].toUpperCase() + risk.substring(1), level: alert.priority),
      AnalysisResult('label2', 'value2')
    ];
  }
}