import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static String get apiKey => dotenv.env['API_KEY'] ?? '';
  static String get apiUrl => dotenv.env['API_URL'] ?? '';
  static String get wsUrl => dotenv.env['WS_URL'] ?? '';
  static String get devHost => dotenv.env['DEV_HOST'] ?? 'localhost';

  // WalletConnect / Reown AppKit
  static String get walletConnectProjectId =>
      dotenv.env['WALLETCONNECT_PROJECT_ID'] ?? '';
}
