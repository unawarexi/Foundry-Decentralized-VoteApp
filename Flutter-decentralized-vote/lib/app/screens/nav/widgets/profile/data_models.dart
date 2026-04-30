import 'package:flutter/material.dart';

class VoteRecord {
  final String election;
  final String region;
  final String level;
  final String month;
  final String day;
  final String txHash;

  const VoteRecord({
    required this.election,
    required this.region,
    required this.level,
    required this.month,
    required this.day,
    required this.txHash,
  });
}

class FollowedCandidate {
  final String name;
  final String initials;
  final String partyCode;
  final Color partyColor;

  const FollowedCandidate({
    required this.name,
    required this.initials,
    required this.partyCode,
    required this.partyColor,
  });
}

const List<VoteRecord> voteHistory = [
  VoteRecord(
    election: 'Edo State Gubernatorial Election 2024',
    region: 'Benin City · Edo State',
    level: 'STATE',
    month: 'NOV',
    day: '16',
    txHash: '0x7f4a3e12...',
  ),
  VoteRecord(
    election: 'University of Benin Student Union',
    region: 'Ugbowo Campus · NG',
    level: 'CAMPUS',
    month: 'SEP',
    day: '04',
    txHash: '0x2d1b9c44...',
  ),
  VoteRecord(
    election: 'Lagos LGA Chairman — Ikeja',
    region: 'Ikeja · Lagos State',
    level: 'LOCAL',
    month: 'JUL',
    day: '22',
    txHash: '0x5a8f7e01...',
  ),
];

final List<FollowedCandidate> followedCandidates = [
  const FollowedCandidate(
    name: 'Monday Okpebholo',
    initials: 'MO',
    partyCode: 'APC',
    partyColor: Color(0xFF10B981),
  ),
  const FollowedCandidate(
    name: 'Asue Ighodalo',
    initials: 'AI',
    partyCode: 'PDP',
    partyColor: Color(0xFF3B82F6),
  ),
  const FollowedCandidate(
    name: 'Dr. Aisha Bukar',
    initials: 'AB',
    partyCode: 'NNPP',
    partyColor: Color(0xFFF59E0B),
  ),
  const FollowedCandidate(
    name: 'Olumide Akpata',
    initials: 'OA',
    partyCode: 'LP',
    partyColor: Color(0xFFEF4444),
  ),
];
