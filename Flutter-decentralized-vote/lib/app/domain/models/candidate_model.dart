import 'package:flutter_frontend_vote/app/domain/models/user_model.dart';

/// VoteSecure candidate — includes all campaign-specific fields.
class CandidateModel {
  final String id;
  final String userId;
  final String electionId;
  final String? partyId;
  final String? regionId;
  final String? onChainId;
  final String status; // PENDING | APPROVED | REJECTED | DISQUALIFIED | WITHDRAWN
  final int popularityScore;
  final String? manifestoHash;
  final String? manifestoUrl;
  final String? profileBio;
  final List<dynamic> achievements;
  final List<dynamic> milestones;
  final String? lifeSummary;
  final String? payoutAddress;
  // Campaign enrichment fields
  final String? logoUrl; // party / campaign logo
  final String? slogan; // campaign slogan
  final int totalVotesFor;
  final int slaBreaches;
  final String? approvedBy;
  final DateTime? approvedAt;
  final String? disqualifyReason;
  final UserModel? user;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CandidateModel({
    required this.id,
    required this.userId,
    required this.electionId,
    this.partyId,
    this.regionId,
    this.onChainId,
    required this.status,
    this.popularityScore = 0,
    this.manifestoHash,
    this.manifestoUrl,
    this.profileBio,
    this.achievements = const [],
    this.milestones = const [],
    this.lifeSummary,
    this.payoutAddress,
    this.logoUrl,
    this.slogan,
    this.totalVotesFor = 0,
    this.slaBreaches = 0,
    this.approvedBy,
    this.approvedAt,
    this.disqualifyReason,
    this.user,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CandidateModel.fromJson(Map<String, dynamic> json) {
    return CandidateModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      electionId: json['electionId'] as String,
      partyId: json['partyId'] as String?,
      regionId: json['regionId'] as String?,
      onChainId: json['onChainId'] as String?,
      status: json['status'] as String? ?? 'PENDING',
      popularityScore: json['popularityScore'] as int? ?? 0,
      manifestoHash: json['manifestoHash'] as String?,
      manifestoUrl: json['manifestoUrl'] as String?,
      profileBio: json['profileBio'] as String?,
      achievements: json['achievements'] as List<dynamic>? ?? [],
      milestones: json['milestones'] as List<dynamic>? ?? [],
      lifeSummary: json['lifeSummary'] as String?,
      payoutAddress: json['payoutAddress'] as String?,
      logoUrl: json['logoUrl'] as String?,
      slogan: json['slogan'] as String?,
      totalVotesFor: json['totalVotesFor'] as int? ?? 0,
      slaBreaches: json['slaBreaches'] as int? ?? 0,
      approvedBy: json['approvedBy'] as String?,
      approvedAt: json['approvedAt'] != null
          ? DateTime.parse(json['approvedAt'] as String)
          : null,
      disqualifyReason: json['disqualifyReason'] as String?,
      user: json['user'] != null
          ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'electionId': electionId,
        if (partyId != null) 'partyId': partyId,
        if (regionId != null) 'regionId': regionId,
        'status': status,
        'popularityScore': popularityScore,
        if (manifestoUrl != null) 'manifestoUrl': manifestoUrl,
        if (profileBio != null) 'profileBio': profileBio,
        'achievements': achievements,
        'milestones': milestones,
        if (lifeSummary != null) 'lifeSummary': lifeSummary,
        if (payoutAddress != null) 'payoutAddress': payoutAddress,
        if (logoUrl != null) 'logoUrl': logoUrl,
        if (slogan != null) 'slogan': slogan,
        'totalVotesFor': totalVotesFor,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  bool get isApproved => status == 'APPROVED';
  bool get isPending => status == 'PENDING';
  bool get isDisqualified => status == 'DISQUALIFIED';
  String get displayName => user?.displayNameOrEmail ?? userId;
  String? get avatarUrl => user?.avatarUrl;
}

