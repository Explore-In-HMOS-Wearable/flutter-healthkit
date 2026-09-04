import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  AppConstants._();

  static String get authUrl => dotenv.env['AUTH_URL']!;
  static String get clientId => dotenv.env['CLIENT_ID']!;
  static String get clientSecret => dotenv.env['CLIENT_SECRET']!;
  static String get redirectUrl => dotenv.env['REDIRECT_URL']!;
  static String get tokenUrl => dotenv.env['TOKEN_URL']!;
  static String get baseUrl => dotenv.env['BASE_URL']!;
  static String get wafCookie => dotenv.env['WAF_COOKIE']!;
}
