import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_frontend_vote/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_frontend_vote/core/db/hive.dart';
import 'package:flutter_frontend_vote/core/services/notification_service.dart';
import 'package:flutter_frontend_vote/core/services/storage_service.dart';
import 'package:flutter_frontend_vote/injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables before dependency setup.
  await dotenv.load(fileName: '.env');

  // Initialize DI
  await initDependencies();

  // Parallel init for independent services
  await Future.wait([
    HiveService.init(),
    LocalStorageService.init(),
  ]);

  // Prune expired cache entries
  await HiveService.pruneExpired();

  // Local notifications channels/handlers.
  await NotificationService.instance.init();

  // Lock orientation on mobile
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final app = const ProviderScope(child: VoteSecureApp());

  runApp(app);
}
