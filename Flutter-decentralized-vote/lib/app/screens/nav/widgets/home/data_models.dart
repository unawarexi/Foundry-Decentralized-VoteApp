import 'package:flutter/material.dart';
import 'package:flutter_frontend_vote/core/constants/colors.dart';

// ══════════════════════════════════════════════════════════════
// DATA MODELS
// ══════════════════════════════════════════════════════════════

class ElectionData {
  final String title;
  final String region;
  final String level;
  final int participation;
  final String timeLeft;
  final int candidates;
  final bool isUrgent;

  const ElectionData({
    required this.title,
    required this.region,
    required this.level,
    required this.participation,
    required this.timeLeft,
    required this.candidates,
    this.isUrgent = false,
  });
}

class UpcomingData {
  final String title;
  final String region;
  final String level;
  final String month;
  final String day;

  const UpcomingData({
    required this.title,
    required this.region,
    required this.level,
    required this.month,
    required this.day,
  });
}

class FeedItem {
  final String flag;
  final String title;
  final String subtitle;
  final bool isLive;
  final String result;
  final Color color;

  const FeedItem({
    required this.flag,
    required this.title,
    required this.subtitle,
    required this.isLive,
    required this.result,
    required this.color,
  });
}

class ForumData {
  final String candidate;
  final String question;
  final int upvotes;
  final int answers;
  final bool isUnanswered;
  final String timer;
  final String timePosted;

  const ForumData({
    required this.candidate,
    required this.question,
    required this.upvotes,
    required this.answers,
    required this.isUnanswered,
    required this.timer,
    required this.timePosted,
  });
}

// ══════════════════════════════════════════════════════════════
// MOCK DATA
// ══════════════════════════════════════════════════════════════

const List<ElectionData> activeElections = [
  ElectionData(
    title: 'Edo State Gubernatorial Election 2024',
    region: 'Benin City · Nigeria',
    level: 'STATE',
    participation: 68,
    timeLeft: '4h 22m left',
    candidates: 7,
    isUrgent: true,
  ),
  ElectionData(
    title: 'University of Benin Student Union President',
    region: 'Ugbowo Campus · NG',
    level: 'CAMPUS',
    participation: 42,
    timeLeft: '2 days left',
    candidates: 4,
  ),
  ElectionData(
    title: 'Lagos Local Government Chairman',
    region: 'Ikeja · Lagos State',
    level: 'LOCAL GOV',
    participation: 55,
    timeLeft: '1 day left',
    candidates: 6,
  ),
];

const List<UpcomingData> upcomingElections = [
  UpcomingData(
    title: 'Abuja FCT Senatorial District Poll',
    region: 'Federal Capital Territory · NG',
    level: 'SENATE',
    month: 'MAY',
    day: '12',
  ),
  UpcomingData(
    title: 'Rivers State Local Council Development Area',
    region: 'Port Harcourt · Rivers',
    level: 'LOCAL',
    month: 'MAY',
    day: '19',
  ),
  UpcomingData(
    title: 'Federal House of Representatives — Edo North',
    region: 'Etsako · Edo State',
    level: 'FEDERAL',
    month: 'JUN',
    day: '3',
  ),
];

final List<FeedItem> globalFeedItems = [
  FeedItem(
    flag: '🇿🇦',
    title: 'South Africa General Election',
    subtitle: '24.1M votes cast · 89% reporting',
    isLive: true,
    result: '',
    color: TColors.success,
  ),
  FeedItem(
    flag: '🇧🇷',
    title: 'São Paulo State Governor',
    subtitle: 'Final · Tarcísio de Freitas wins',
    isLive: false,
    result: 'FINAL',
    color: TColors.secondary,
  ),
  FeedItem(
    flag: '🇮🇳',
    title: 'Delhi Municipal Corporation Election',
    subtitle: '3.2M registered · Polling opens in 2h',
    isLive: false,
    result: 'SOON',
    color: TColors.accent,
  ),
];

const List<ForumData> forumQuestions = [
  ForumData(
    candidate: 'GOV CANDIDATE · MONDAY OKPEBHOLO',
    question:
        'What specific policy will you implement to reduce unemployment among Edo State youth within your first 100 days?',
    upvotes: 2841,
    answers: 0,
    isUnanswered: true,
    timer: '18h 44m to respond',
    timePosted: '6h ago',
  ),
  ForumData(
    candidate: 'SENATE · DR. AISHA BUKAR',
    question:
        'Your manifesto mentions "digital infrastructure" — can you define the measurable KPIs you will be held to?',
    upvotes: 1203,
    answers: 1,
    isUnanswered: false,
    timer: '',
    timePosted: '2h ago',
  ),
];
