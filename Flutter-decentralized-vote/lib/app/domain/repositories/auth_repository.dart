import 'dart:async';
import 'package:flutter_frontend_vote/core/network/api_client.dart';
import 'package:flutter_frontend_vote/core/apis/endpoints.dart';
import 'package:flutter_frontend_vote/core/services/storage_service.dart';
import 'package:flutter_frontend_vote/core/db/hive.dart';
import 'package:flutter_frontend_vote/core/network/api_exception.dart';
import 'package:flutter_frontend_vote/app/domain/models/user_model.dart';

class AuthRepository {
  final _api = ApiClient.instance;

  /// True when a cached user exists in Hive (fast, synchronous check).
  bool get isLoggedIn => HiveService.userCache.get('current_user') != null;

  // ── Registration ──────────────────────────────────────────────────────────

  /// Register a new voter account directly on the backend (no Firebase).
  Future<UserModel> registerVoter({
    required String email,
    required String displayName,
    required String password,
    String? phone,
    String? dateOfBirth,
    String? occupation,
    String? address,
    String? maritalStatus,
    String? gender,
    String? familyRole,
    String? country,
    String? state,
    String? lga,
    String? avatarUrl,
    String? logoUrl,
    String? slogan,
    List<String>? languages,
    String? religion,
    String? idNumber,
  }) async {
    try {
      final res = await _api.post(ApiEndpoints.register, data: {
        'email': email,
        'displayName': displayName,
        'password': password,
        if (phone != null) 'phone': phone,
        if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
        if (occupation != null) 'occupation': occupation,
        if (address != null) 'address': address,
        if (maritalStatus != null) 'maritalStatus': maritalStatus,
        if (gender != null) 'gender': gender,
        if (familyRole != null) 'familyRole': familyRole,
        if (country != null) 'country': country,
        if (state != null) 'state': state,
        if (lga != null) 'lga': lga,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
        if (logoUrl != null) 'logoUrl': logoUrl,
        if (slogan != null) 'slogan': slogan,
        if (languages != null) 'languages': languages,
        if (religion != null) 'religion': religion,
        if (idNumber != null) 'idNumber': idNumber,
      });
      final user = UserModel.fromJson(res.data['data']['user']);
      await _cacheUser(user, token: res.data['data']['token'] as String?);
      return user;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  // ── Sign-in ───────────────────────────────────────────────────────────────

  /// Email + password sign-in — backend issues JWT directly.
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _api.post(ApiEndpoints.signIn, data: {
        'email': email,
        'password': password,
      });
      final user = UserModel.fromJson(res.data['data']['user']);
      await _cacheUser(user, token: res.data['data']['token'] as String?);
      return user;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  /// Wallet-based sign-in.
  /// [walletAddress] — checksummed EVM address.
  /// [signature]     — personal_sign result from WalletConnect.
  /// [message]       — the SIWE nonce message that was signed.
  Future<UserModel> signInWithWallet({
    required String walletAddress,
    required String signature,
    required String message,
  }) async {
    try {
      final res = await _api.post(ApiEndpoints.verifyWallet, data: {
        'walletAddress': walletAddress,
        'signature': signature,
        'message': message,
      });
      final user = UserModel.fromJson(res.data['data']['user']);
      await _cacheUser(user, token: res.data['data']['token'] as String?);
      return user;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  // ── Profile ───────────────────────────────────────────────────────────────

  Future<UserModel> getMe() async {
    final res = await _api.get(ApiEndpoints.me);
    final user = UserModel.fromJson(res.data['data']);
    HiveService.userCache.put('current_user', user.toJson());
    return user;
  }

  UserModel? getCachedUser() {
    final cached = HiveService.userCache.get('current_user');
    if (cached != null) {
      return UserModel.fromJson(Map<String, dynamic>.from(cached as Map));
    }
    return null;
  }

  // ── Sign-out / Delete ─────────────────────────────────────────────────────

  Future<void> signOut() async {
    unawaited(_api.post(ApiEndpoints.signOut).then((_) {}, onError: (_) {}));
    await Future.wait([
      SecureStorageService.clearAll(),
      HiveService.clearAll(),
    ]);
  }

  Future<void> deleteAccount() async {
    await _api.delete(ApiEndpoints.deleteAccount);
    await Future.wait([
      SecureStorageService.clearAll(),
      HiveService.clearAll(),
    ]);
  }

  // ── Wallet binding ────────────────────────────────────────────────────────

  /// Link a wallet address to the authenticated user.
  Future<void> bindWallet({
    required String walletAddress,
    required String signature,
    required String message,
  }) async {
    await _api.post(ApiEndpoints.verifyWallet, data: {
      'walletAddress': walletAddress,
      'signature': signature,
      'message': message,
    });
  }

  /// Register the user identity on-chain (calls smart contract).
  Future<void> registerOnChain({
    required String regionId,
    required String identityHash,
  }) async {
    await _api.post(ApiEndpoints.registerOnChain, data: {
      'regionId': regionId,
      'identityHash': identityHash,
    });
  }

  // ── Private ───────────────────────────────────────────────────────────────

  Future<void> _cacheUser(UserModel user, {String? token}) async {
    await SecureStorageService.saveUserId(user.id);
    if (token != null) {
      await SecureStorageService.saveToken(token);
    }
    HiveService.userCache.put('current_user', user.toJson());
  }
}

