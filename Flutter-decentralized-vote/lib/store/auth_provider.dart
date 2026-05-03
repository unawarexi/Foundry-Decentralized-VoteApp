import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_frontend_vote/app/domain/models/user_model.dart';
import 'package:flutter_frontend_vote/app/domain/repositories/auth_repository.dart';
import 'package:flutter_frontend_vote/store/user_provider.dart';
import 'package:flutter_frontend_vote/core/network/account_guard.dart';
import 'package:flutter_frontend_vote/core/services/notification_service.dart';
import 'package:flutter_frontend_vote/core/services/websocket.dart';

// ── Repository ───────────────────────────────────────────────────────────────

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository());

// ── Session state ───────────────────────────────────────────────────────────

/// True once a user session exists (JWT cached in Hive).
final hasSessionProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider).valueOrNull != null;
});

// ── Current user ───────────────────────────────────────────────────────────────

final currentUserProvider =
    StateNotifierProvider<CurrentUserNotifier, AsyncValue<UserModel?>>((ref) {
  return CurrentUserNotifier(ref);
});

class CurrentUserNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final Ref _ref;

  CurrentUserNotifier(this._ref) : super(const AsyncValue.data(null)) {
    _init();
  }

  void _init() {
    final cached = _ref.read(authRepositoryProvider).getCachedUser();
    if (cached != null) {
      state = AsyncValue.data(cached);
      _connectWebSocket(cached);
    }
  }

  // ── Email / password sign-in ──────────────────────────────────────────────

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = await _ref
          .read(authRepositoryProvider)
          .signInWithEmail(email: email, password: password);
      state = AsyncValue.data(user);
      _registerPushToken();
      _connectWebSocket(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // ── Wallet sign-in ────────────────────────────────────────────────────────

  Future<void> signInWithWallet({
    required String walletAddress,
    required String signature,
    required String message,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = await _ref.read(authRepositoryProvider).signInWithWallet(
            walletAddress: walletAddress,
            signature: signature,
            message: message,
          );
      state = AsyncValue.data(user);
      _registerPushToken();
      _connectWebSocket(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // ── Registration ────────────────────────────────────────────────────────────

  Future<void> registerVoter(Map<String, dynamic> fields) async {
    state = const AsyncValue.loading();
    try {
      final user = await _ref.read(authRepositoryProvider).registerVoter(
            email: fields['email'] as String,
            displayName: fields['displayName'] as String,
            password: fields['password'] as String,
            phone: fields['phone'] as String?,
            dateOfBirth: fields['dateOfBirth'] as String?,
            occupation: fields['occupation'] as String?,
            address: fields['address'] as String?,
            maritalStatus: fields['maritalStatus'] as String?,
            gender: fields['gender'] as String?,
            familyRole: fields['familyRole'] as String?,
            country: fields['country'] as String?,
            state: fields['state'] as String?,
            lga: fields['lga'] as String?,
            avatarUrl: fields['avatarUrl'] as String?,
            logoUrl: fields['logoUrl'] as String?,
            slogan: fields['slogan'] as String?,
            languages: (fields['languages'] as List?)?.cast<String>(),
            religion: fields['religion'] as String?,
            idNumber: fields['idNumber'] as String?,
          );
      state = AsyncValue.data(user);
      _registerPushToken();
      _connectWebSocket(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // ── Profile refresh ─────────────────────────────────────────────────────────

  Future<void> fetchProfile() async {
    try {
      final user = await _ref.read(authRepositoryProvider).getMe();
      state = AsyncValue.data(user);
    } catch (e, st) {
      if (e is DioException && e.response?.statusCode == 404) {
        state = const AsyncValue.data(null);
        AccountGuard.trigger();
        return;
      }
      if (state.valueOrNull == null) state = AsyncValue.error(e, st);
    }
  }

  // ── Sign-out / delete ───────────────────────────────────────────────────────

  Future<void> signOut() async {
    await _ref.read(authRepositoryProvider).signOut();
    WebSocketService().disconnect();
    state = const AsyncValue.data(null);
  }

  Future<void> deleteAccount() async {
    await _ref.read(authRepositoryProvider).deleteAccount();
    state = const AsyncValue.data(null);
  }

  void setUser(UserModel user) => state = AsyncValue.data(user);
  void clear() => state = const AsyncValue.data(null);

  // ── Private helpers ─────────────────────────────────────────────────────────

  Future<void> _registerPushToken() async {
    try {
      final token = await NotificationService.instance.getToken();
      if (token != null) {
        await _ref.read(userRepositoryProvider).registerDevice(
              fcmToken: token,
              platform: Platform.isIOS ? 'ios' : 'android',
            );
      }
    } catch (e) {
      debugPrint('[Push] Token registration failed: $e');
    }
  }

  void _connectWebSocket(UserModel? user) {
    if (user == null) return;
    final ws = WebSocketService();
    ws.connect().then((_) => ws.setUserId(user.id));
  }
}

