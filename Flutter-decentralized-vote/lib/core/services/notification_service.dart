import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_frontend_vote/router/app_router.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  // ── Android Notification Channels ──

  static const _electionChannel = AndroidNotificationChannel(
    'election_updates',
    'Election Updates',
    description: 'Notifications for election start, end, and results',
    importance: Importance.high,
    enableVibration: true,
  );

  static const _voteChannel = AndroidNotificationChannel(
    'vote_confirmations',
    'Vote Confirmations',
    description: 'On-chain vote confirmation receipts',
    importance: Importance.high,
    enableVibration: true,
  );

  static const _systemChannel = AndroidNotificationChannel(
    'system_notifications',
    'System Notifications',
    description: 'General system notifications',
    importance: Importance.defaultImportance,
  );

  // ── Init ────────────────────────────────────────────────────────────────────

  Future<void> init() async {
    if (Platform.isIOS || Platform.isMacOS) return;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await _local.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    if (Platform.isAndroid) {
      final androidPlugin = _local
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.createNotificationChannel(_electionChannel);
      await androidPlugin?.createNotificationChannel(_voteChannel);
      await androidPlugin?.createNotificationChannel(_systemChannel);
    }
  }

  // ── Push token stubs ─────────────────────────────────────────────────────────
  // Push tokens are no longer Firebase-based.
  // Implement your own push provider (APNs direct, OneSignal, etc.) here.

  Future<String?> getToken() async => null;

  Stream<String> get onTokenRefresh => const Stream.empty();

  // ── Show notifications ────────────────────────────────────────────────────────

  Future<void> showElectionNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    if (!Platform.isAndroid) return;
    await _local.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _electionChannel.id,
          _electionChannel.name,
          channelDescription: _electionChannel.description,
          importance: _electionChannel.importance,
          priority: Priority.high,
          enableVibration: true,
        ),
      ),
      payload: data != null ? jsonEncode(data) : null,
    );
  }

  Future<void> showVoteConfirmation({
    required String txHash,
    required String electionName,
  }) async {
    if (!Platform.isAndroid) return;
    await _local.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'Vote Confirmed',
      'Your vote for "$electionName" has been recorded on-chain.',
      NotificationDetails(
        android: AndroidNotificationDetails(
          _voteChannel.id,
          _voteChannel.name,
          channelDescription: _voteChannel.description,
          importance: _voteChannel.importance,
          priority: Priority.high,
          enableVibration: true,
        ),
      ),
      payload: jsonEncode({'type': 'vote_confirmed', 'txHash': txHash}),
    );
  }

  // ── Navigation ───────────────────────────────────────────────────────────────

  void _onNotificationTap(NotificationResponse response) {
    if (response.payload == null) return;
    try {
      final data = jsonDecode(response.payload!) as Map<String, dynamic>;
      _navigateFromData(data);
    } catch (_) {}
  }

  void _navigateFromData(Map<String, dynamic> data) {
    final type = data['type'] ?? '';
    switch (type) {
      case 'election_update':
        appRouter.go('/elections');
        break;
      case 'vote_confirmed':
        appRouter.go('/home');
        break;
      default:
        appRouter.go('/home');
    }
  }
}

