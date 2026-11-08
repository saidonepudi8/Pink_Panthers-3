import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../core/network/api_config.dart';

// One candidate species returned by the model
class SpeciesGuess {
  const SpeciesGuess(this.label, this.confidence);

  final String label; // e.g. "wild_pig"
  final double confidence; // 0.0 - 1.0

  factory SpeciesGuess.fromJson(Map<String, dynamic> json) =>
      SpeciesGuess(json['label'] as String, (json['confidence'] as num).toDouble());
}

// Model output from POST /api/predict
class PredictionResponse {
  const PredictionResponse({required this.top});

  final List<SpeciesGuess> top; // Best guess first

  SpeciesGuess get best => top.first;

  factory PredictionResponse.fromJson(Map<String, dynamic> json) => PredictionResponse(
        top: (json['top'] as List)
            .map((e) => SpeciesGuess.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class PredictService {
  const PredictService();

  // Uploads the image to the backend and returns the classifier's prediction.
  Future<PredictionResponse> predict(Uint8List imageBytes, {String filename = 'image.png'}) async {
    final request = http.MultipartRequest('POST', Uri.parse('${ApiConfig.baseUrl}/api/predict'))
      ..files.add(http.MultipartFile.fromBytes('file', imageBytes, filename: filename));

    // Long timeout: the first request can wait on the server loading the model
    final streamed = await request.send().timeout(const Duration(seconds: 60));
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode != 200) {
      throw Exception('Predict API returned HTTP ${response.statusCode}: ${response.body}');
    }
    return PredictionResponse.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }
}
