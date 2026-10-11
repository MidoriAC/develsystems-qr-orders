import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static Future<void> initEnvironment() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (e) {
      debugPrint("Error en la carga de env $e");
    }
  }

  static String get baseUrl =>
      dotenv.maybeGet('API_BASE_URL') ?? 'https://dummyjson.com';

  static int get timeoutMs =>
      int.tryParse(dotenv.maybeGet('API_TIMEOUT_MS') ?? '10000') ?? 10000;

  static bool get useFake =>
      (dotenv.maybeGet('USE_FAKE') ?? 'false').toLowerCase() == 'true';
}
