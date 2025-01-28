import 'package:flutter_dotenv/flutter_dotenv.dart';

class Config {
  static String get lambdaUrl => dotenv.env['LAMBDA_URL'] ?? '';
  static String get apiKey => dotenv.env['API_KEY'] ?? '';
  static String get appId => dotenv.env['APP_ID'] ?? '';
  static String get messagingSenderId => dotenv.env['MESSAGING_SENDER_ID'] ?? '';
  static String get projectId => dotenv.env['PROJECT_ID'] ?? '';
}
String fetchData() {
  final lambdaUrl = Config.lambdaUrl;
  return lambdaUrl;
}