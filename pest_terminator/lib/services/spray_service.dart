import 'package:http/http.dart' as http;

import '../core/network/api_config.dart';

class SprayService {
  const SprayService();

  Future<void> sendSignal() async {
    // GET method to /spray endpoint
    final response = await http
        .get(
          Uri.parse('${ApiConfig.baseUrl}/api/spray'),
        )
        .timeout(const Duration(seconds: 5));

    // HTTP 200 - served finished processing request 
    if (response.statusCode != 200) {
      throw Exception('Spray API returned HTTP ${response.statusCode}.');
    }
  }
}
