import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_frontend_vote/app/domain/models/user_model.dart';
import 'package:flutter_frontend_vote/app/domain/repositories/auth_repository.dart';
import 'package:flutter_frontend_vote/core/network/api_client.dart';
import 'package:flutter_frontend_vote/core/apis/endpoints.dart';
import 'package:flutter_frontend_vote/store/auth_provider.dart';

// Repository for user-specific operations (profile, avatar, devices).
class UserRepository {
  final _api = ApiClient.instance;

  Future<UserModel> getProfile() async {
    final res = await _api.get(ApiEndpoints.userProfile);
    return UserModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<UserModel> updateProfile({
    String? displayName,
    String? phone,
    String? slogan,
    String? logoUrl,
    List<String>? languages,
    String? religion,
  }) async {
    final res = await _api.put(ApiEndpoints.userProfile, data: {
      if (displayName != null) 'displayName': displayName,
      if (phone != null) 'phone': phone,
      if (slogan != null) 'slogan': slogan,
      if (logoUrl != null) 'logoUrl': logoUrl,
      if (languages != null) 'languages': languages,
      if (religion != null) 'religion': religion,
    });
    return UserModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<UserModel> updateAvatar(String filePath) async {
    final formData = FormData.fromMap({
      'avatar': await MultipartFile.fromFile(filePath),
    });
    final res = await _api.upload(ApiEndpoints.userAvatar, formData: formData);
    return UserModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<void> registerDevice({
    required String fcmToken,
    required String platform,
  }) async {
    await _api.post(ApiEndpoints.userDevices,
        data: {'fcmToken': fcmToken, 'platform': platform});
  }

  Future<void> removeDevice(String deviceId) =>
      _api.delete(ApiEndpoints.userDevice(deviceId));
}

final userRepositoryProvider = Provider<UserRepository>((ref) => UserRepository());

/// Update profile and sync auth state notifier.
final updateProfileProvider = Provider<
    Future<UserModel> Function({
      String? displayName,
      String? phone,
      String? slogan,
      String? logoUrl,
      List<String>? languages,
      String? religion,
    })>((ref) {
  return ({
    String? displayName,
    String? phone,
    String? slogan,
    String? logoUrl,
    List<String>? languages,
    String? religion,
  }) async {
    final user = await ref.read(userRepositoryProvider).updateProfile(
          displayName: displayName,
          phone: phone,
          slogan: slogan,
          logoUrl: logoUrl,
          languages: languages,
          religion: religion,
        );
    ref.read(currentUserProvider.notifier).setUser(user);
    return user;
  };
});

/// Update avatar and sync auth state.
final updateAvatarProvider =
    Provider<Future<UserModel> Function(String filePath)>((ref) {
  return (String filePath) async {
    final user =
        await ref.read(userRepositoryProvider).updateAvatar(filePath);
    ref.read(currentUserProvider.notifier).setUser(user);
    return user;
  };
});

/// Voting history for the authenticated user.
final votingHistoryProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final api = ApiClient.instance;
  final res = await api.get(ApiEndpoints.userVotingHistory);
  final list = res.data['data'] as List;
  return list.cast<Map<String, dynamic>>();
});

/// Whether the authenticated user is a candidate.
final isCandidateProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider).valueOrNull?.isCandidate ?? false;
});

/// Convenience — current user role.
final userRoleProvider = Provider<String?>((ref) {
  return ref.watch(currentUserProvider).valueOrNull?.role;
});
