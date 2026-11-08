import 'package:flutter/services.dart' show rootBundle;

import '../../../services/predict_service.dart';
import '../models/pest_alert.dart';

// Error with a message that is safe to show to the user
class PredictionException implements Exception {
  const PredictionException(this.message);
  final String message;

  @override
  String toString() => message;
}

class AlertsRepository {
  AlertsRepository({PredictService service = const PredictService()}) : _service = service;

  final PredictService _service;

  // Sends the alert's image to the trained model and builds the rows for the results table
  Future<List<AnalysisResult>> classify(PestAlert alert) async {
    final src = alert.imageSrc;
    if (src == null) {
      throw const PredictionException("There is no photo for this alert, so the app can't check it.");
    }

    // TODO: Load from the camera/Firestore image URL once alerts come from the backend.
    final data = await rootBundle.load(src);
    final prediction = await _service.predict(
      data.buffer.asUint8List(),
      filename: src.split('/').last,
    );

    final best = prediction.best;
    final risk = alert.priority.name;

    // Only mention other animals the model gave a real chance (5% or more)
    final others = prediction.top.skip(1).where((g) => g.confidence >= 0.05);

    return [
      AnalysisResult('Animal spotted', _animalName(best.label)),
      AnalysisResult('How sure the app is', '${_sureWords(best.confidence)} (${_percent(best.confidence)})'),
      AnalysisResult('Risk to crops', risk[0].toUpperCase() + risk.substring(1), level: alert.priority),
      if (others.isNotEmpty)
        AnalysisResult('Could also be', others.map((g) => _animalName(g.label)).join('\n')),
    ];
  }

  // Plain names for the model's class labels
  static const _animalNames = {
    'beaver': 'Beaver',
    'bird': 'Bird',
    'coyote': 'Coyote',
    'livestock': 'Livestock (cattle, sheep, goats)',
    'other_wildlife': 'Other wild animal',
    'person': 'Person',
    'pet': 'Pet (dog or cat)',
    'rabbit': 'Rabbit',
    'rodent': 'Rodent (rat or mouse)',
    'squirrel': 'Squirrel',
    'wild_pig': 'Wild pig (feral hog)',
  };

  static String _animalName(String label) {
    final known = _animalNames[label];
    if (known != null) return known;
    final words = label.replaceAll('_', ' '); // Fallback if the model gains new classes
    return words[0].toUpperCase() + words.substring(1);
  }

  // Confidence in everyday words
  static String _sureWords(double confidence) {
    if (confidence >= 0.90) return 'Very sure';
    if (confidence >= 0.70) return 'Fairly sure';
    if (confidence >= 0.50) return 'Not very sure';
    return 'Unsure, check the photo';
  }

  // Model probability as a percent with 2 decimals. Truncates instead of rounding so
  // 0.99954 shows "99.95%" (never a misleading "100%"); tiny values show "<0.01%".
  static String _percent(double confidence) {
    final hundredths = (confidence * 10000).floor(); // percent * 100
    if (hundredths < 1) return '<0.01%';
    return '${(hundredths / 100).toStringAsFixed(2)}%';
  }
}
