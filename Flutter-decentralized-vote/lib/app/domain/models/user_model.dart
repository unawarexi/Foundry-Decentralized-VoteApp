import 'package:flutter_frontend_vote/app/domain/models/region_model.dart';

/// VoteSecure user — mirrors the Express User model (biometricHash excluded).
class UserModel {
  final String id;
  final String firebaseUid;
  final String email;
  final String? displayName;
  final String? avatarUrl;
  final String? logoUrl; // company / org logo
  final String? slogan; // personal motto / tagline
  final List<String> languages;
  final String? religion;
  final String? phone;
  final String? walletAddress;
  final String role; // VOTER | CANDIDATE | ADMIN | ...
  final String kycStatus;
  final bool isBanned;
  final bool isActive;
  final bool emailVerified;
  final bool phoneVerified;
  final String? regionId;
  final String? countryCode;
  final String? locale;
  final String? fcmToken;
  final String? identityHash;
  final RegionModel? region;
  final DateTime? lastSeenAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.firebaseUid,
    required this.email,
    this.displayName,
    this.avatarUrl,
    this.logoUrl,
    this.slogan,
    this.languages = const [],
    this.religion,
    this.phone,
    this.walletAddress,
    required this.role,
    required this.kycStatus,
    this.isBanned = false,
    this.isActive = true,
    this.emailVerified = false,
    this.phoneVerified = false,
    this.regionId,
    this.countryCode,
    this.locale,
    this.fcmToken,
    this.identityHash,
    this.region,
    this.lastSeenAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      firebaseUid: json['firebaseUid'] as String? ?? '',
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      logoUrl: json['logoUrl'] as String?,
      slogan: json['slogan'] as String?,
      languages: (json['languages'] as List<dynamic>?)?.cast<String>() ?? [],
      religion: json['religion'] as String?,
      phone: json['phone'] as String?,
      walletAddress: json['walletAddress'] as String?,
      role: json['role'] as String? ?? 'VOTER',
      kycStatus: json['kycStatus'] as String? ?? 'NONE',
      isBanned: json['isBanned'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
      emailVerified: json['emailVerified'] as bool? ?? false,
      phoneVerified: json['phoneVerified'] as bool? ?? false,
      regionId: json['regionId'] as String?,
      countryCode: json['countryCode'] as String?,
      locale: json['locale'] as String?,
      fcmToken: json['fcmToken'] as String?,
      identityHash: json['identityHash'] as String?,
      region: json['region'] != null
          ? RegionModel.fromJson(json['region'] as Map<String, dynamic>)
          : null,
      lastSeenAt: json['lastSeenAt'] != null
          ? DateTime.parse(json['lastSeenAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'firebaseUid': firebaseUid,
        'email': email,
        if (displayName != null) 'displayName': displayName,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
        if (logoUrl != null) 'logoUrl': logoUrl,
        if (slogan != null) 'slogan': slogan,
        'languages': languages,
        if (religion != null) 'religion': religion,
        if (phone != null) 'phone': phone,
        if (walletAddress != null) 'walletAddress': walletAddress,
        'role': role,
        'kycStatus': kycStatus,
        'isBanned': isBanned,
        'isActive': isActive,
        'emailVerified': emailVerified,
        'phoneVerified': phoneVerified,
        if (regionId != null) 'regionId': regionId,
        if (countryCode != null) 'countryCode': countryCode,
        if (locale != null) 'locale': locale,
        if (fcmToken != null) 'fcmToken': fcmToken,
        if (identityHash != null) 'identityHash': identityHash,
        if (lastSeenAt != null) 'lastSeenAt': lastSeenAt!.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  UserModel copyWith({
    String? displayName,
    String? avatarUrl,
    String? logoUrl,
    String? slogan,
    List<String>? languages,
    String? religion,
    String? phone,
    String? walletAddress,
    String? role,
    String? kycStatus,
    bool? isBanned,
    bool? isActive,
    bool? emailVerified,
    bool? phoneVerified,
    String? regionId,
    String? countryCode,
    String? locale,
    String? fcmToken,
    RegionModel? region,
  }) {
    return UserModel(
      id: id,
      firebaseUid: firebaseUid,
      email: email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      logoUrl: logoUrl ?? this.logoUrl,
      slogan: slogan ?? this.slogan,
      languages: languages ?? this.languages,
      religion: religion ?? this.religion,
      phone: phone ?? this.phone,
      walletAddress: walletAddress ?? this.walletAddress,
      role: role ?? this.role,
      kycStatus: kycStatus ?? this.kycStatus,
      isBanned: isBanned ?? this.isBanned,
      isActive: isActive ?? this.isActive,
      emailVerified: emailVerified ?? this.emailVerified,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      regionId: regionId ?? this.regionId,
      countryCode: countryCode ?? this.countryCode,
      locale: locale ?? this.locale,
      fcmToken: fcmToken ?? this.fcmToken,
      identityHash: identityHash,
      region: region ?? this.region,
      lastSeenAt: lastSeenAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  String get displayNameOrEmail => displayName ?? email.split('@').first;
  bool get isCandidate => role == 'CANDIDATE';
  bool get isAdmin => role == 'SUPER_ADMIN' || role == 'ADMIN' || role == 'MODERATOR';
  bool get isKycVerified =>
      kycStatus == 'BIOMETRIC_VERIFIED' || kycStatus == 'FULLY_VERIFIED';
}

