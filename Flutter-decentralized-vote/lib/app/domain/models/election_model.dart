import 'package:flutter_frontend_vote/app/domain/models/region_model.dart';

class ElectionModel {
  final String id;
  final String title;
  final String? description;
  final String status; // DRAFT | ACTIVE | PAUSED | COMPLETED | CANCELLED
  final String level; // NATIONAL | STATE | LOCAL
  final String electionType; // GENERAL | PRIMARY | SPECIAL | REFERENDUM
  final String? regionId;
  final RegionModel? region;
  final String? onChainId;
  final String? contractAddress;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime? nominationDeadline;
  final int totalVoters;
  final int totalVotesCast;
  final bool resultsPublished;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ElectionModel({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    required this.level,
    required this.electionType,
    this.regionId,
    this.region,
    this.onChainId,
    this.contractAddress,
    required this.startDate,
    required this.endDate,
    this.nominationDeadline,
    this.totalVoters = 0,
    this.totalVotesCast = 0,
    this.resultsPublished = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ElectionModel.fromJson(Map<String, dynamic> json) => ElectionModel(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        status: json['status'] as String? ?? 'DRAFT',
        level: json['level'] as String? ?? 'STATE',
        electionType: json['electionType'] as String? ?? 'GENERAL',
        regionId: json['regionId'] as String?,
        region: json['region'] != null
            ? RegionModel.fromJson(json['region'] as Map<String, dynamic>)
            : null,
        onChainId: json['onChainId'] as String?,
        contractAddress: json['contractAddress'] as String?,
        startDate: DateTime.parse(json['startDate'] as String),
        endDate: DateTime.parse(json['endDate'] as String),
        nominationDeadline: json['nominationDeadline'] != null
            ? DateTime.parse(json['nominationDeadline'] as String)
            : null,
        totalVoters: json['totalVoters'] as int? ?? 0,
        totalVotesCast: json['totalVotesCast'] as int? ?? 0,
        resultsPublished: json['resultsPublished'] as bool? ?? false,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        if (description != null) 'description': description,
        'status': status,
        'level': level,
        'electionType': electionType,
        if (regionId != null) 'regionId': regionId,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'totalVoters': totalVoters,
        'totalVotesCast': totalVotesCast,
        'resultsPublished': resultsPublished,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  bool get isActive => status == 'ACTIVE';
  bool get isCompleted => status == 'COMPLETED';
  double get turnoutPercent =>
      totalVoters == 0 ? 0 : (totalVotesCast / totalVoters) * 100;
}
