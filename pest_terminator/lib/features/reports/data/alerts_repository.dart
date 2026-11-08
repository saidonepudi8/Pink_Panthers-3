import 'package:flutter/services.dart' show AssetManifest, rootBundle;

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

  // TEST DATA: one alert per image in assets/ so the model can be tried on each one.
  // Add more by dropping images into assets/ and restarting the app.
  // [skip] = images already used by other alerts.
  Future<List<PestAlert>> loadTestImageAlerts({Set<String> skip = const {}}) async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final images = manifest
        .listAssets()
        .where((path) => RegExp(r'^assets/[^/]+\.(jpe?g|png|webp|bmp)$', caseSensitive: false).hasMatch(path))
        .where((path) => !skip.contains(path))
        .toList()
      ..sort();

    // Newest first: Test image 1 at the top of the timeline
    final newest = DateTime(2025, 6, 1, 12);
    return [
      for (var i = 0; i < images.length; i++)
        PestAlert(
          id: 'test-${i + 1}',
          title: 'Test image ${i + 1}',
          species: 'Unknown',
          field: 'Test camera: ${_cameraName(images[i])}',
          crop: 'Test',
          priority: AlertPriority.medium,
          status: AlertStatus.newDetection,
          detectedAt: newest.subtract(Duration(hours: i)),
          imageSrc: images[i],
        ),
    ];
  }

  // "assets/missouri__97c5.jpg" -> "Missouri" (dataset the photo came from)
  static String _cameraName(String path) {
    final file = path.split('/').last;
    final source = file.contains('__') ? file.split('__').first : 'unknown';
    return source[0].toUpperCase() + source.substring(1);
  }

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
