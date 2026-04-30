import 'package:flutter/material.dart';

class CandidateData {
  final String name;
  final String initials;
  final String party;
  final String partyCode;
  final Color partyColor;
  final String election;
  final String region;
  final String level;
  final int approvalPct;
  final double voteShare;
  final int forumQuestions;
  final bool isVerified;
  final bool isFollowed;
  final String manifestoSnippet;
  final String bio;
  final List<double>
  radarScores; // [Governance, Integrity, Economy, Social, Security]
  final List<double> approvalHistory; // monthly history
  final int milestonesTotal;
  final int milestonesAchieved;
  final List<String> milestoneLabels;
  final List<ManifestoPoint> manifestoPoints;
  final List<HistoryItem> lifeHistory;

  const CandidateData({
    required this.name,
    required this.initials,
    required this.party,
    required this.partyCode,
    required this.partyColor,
    required this.election,
    required this.region,
    required this.level,
    required this.approvalPct,
    required this.voteShare,
    required this.forumQuestions,
    this.isVerified = true,
    this.isFollowed = false,
    required this.manifestoSnippet,
    required this.bio,
    required this.radarScores,
    required this.approvalHistory,
    required this.milestonesTotal,
    required this.milestonesAchieved,
    required this.milestoneLabels,
    required this.manifestoPoints,
    required this.lifeHistory,
  });
}

class ManifestoPoint {
  final String title;
  final String description;
  const ManifestoPoint({required this.title, required this.description});
}

class HistoryItem {
  final String year;
  final String event;
  final String detail;
  const HistoryItem({
    required this.year,
    required this.event,
    required this.detail,
  });
}

class ForumQuestion {
  final String question;
  final int upvotes;
  final bool isUnanswered;
  final String timer;
  final String timePosted;
  const ForumQuestion({
    required this.question,
    required this.upvotes,
    required this.isUnanswered,
    required this.timer,
    required this.timePosted,
  });
}

// ── Radar axis labels ──────────────────────────────────────────
const radarLabels = [
  'Governance',
  'Integrity',
  'Economy',
  'Social',
  'Security',
];

// ══════════════════════════════════════════════════════════════
// MOCK DATA
// ══════════════════════════════════════════════════════════════

final List<ForumQuestion> mockForumQuestions = [
  const ForumQuestion(
    question:
        'What specific policy will you implement to reduce unemployment among Edo State youth within your first 100 days?',
    upvotes: 2841,
    isUnanswered: true,
    timer: '18h 44m to respond',
    timePosted: '6h ago',
  ),
  const ForumQuestion(
    question:
        'Your manifesto mentions "security reform" — can you define the measurable KPIs you will be held to?',
    upvotes: 1203,
    isUnanswered: false,
    timer: '',
    timePosted: '2h ago',
  ),
  const ForumQuestion(
    question:
        'How will you address the infrastructure gap in rural Edo communities within your first term?',
    upvotes: 876,
    isUnanswered: false,
    timer: '',
    timePosted: '1d ago',
  ),
];

final List<CandidateData> allCandidates = [
  CandidateData(
    name: 'Monday Okpebholo',
    initials: 'MO',
    party: 'All Progressives Congress',
    partyCode: 'APC',
    partyColor: const Color(0xFF10B981),
    election: 'Edo State Gubernatorial 2024',
    region: 'Etsako West · Edo State',
    level: 'State',
    approvalPct: 38,
    voteShare: 0.38,
    forumQuestions: 24,
    isFollowed: true,
    manifestoSnippet:
        'Security, infrastructure development, and youth empowerment as the three pillars of a new Edo.',
    bio:
        'Monday Okpebholo is a businessman and politician from Etsako West. He has served in various capacities within the APC and is known for his constituency development work.',
    radarScores: const [0.72, 0.65, 0.58, 0.80, 0.88],
    approvalHistory: const [
      0.28,
      0.30,
      0.32,
      0.35,
      0.33,
      0.36,
      0.38,
      0.40,
      0.38,
      0.42,
      0.40,
      0.38,
      0.39,
    ],
    milestonesTotal: 5,
    milestonesAchieved: 2,
    milestoneLabels: const ['Reg.', 'Nom.', 'Debate', 'Rally', 'Vote'],
    manifestoPoints: const [
      ManifestoPoint(
        title: 'Voter Registration Drive',
        description: '500,000 new voters registered across 18 LGAs',
      ),
      ManifestoPoint(
        title: 'APC Nomination Secured',
        description: 'Won APC primary with 68% of delegate votes',
      ),
      ManifestoPoint(
        title: 'First Gubernatorial Debate',
        description: 'Upcoming — INEC-sanctioned debate on May 14',
      ),
      ManifestoPoint(
        title: 'State-wide Rally',
        description: 'Pending — Nationwide campaign rally scheduled',
      ),
      ManifestoPoint(
        title: 'Election Day',
        description: 'Pending — November 16, 2024 general election',
      ),
    ],
    lifeHistory: const [
      HistoryItem(
        year: '1972',
        event: 'Born in Etsako West',
        detail: 'Raised in Fugar, Etsako West LGA, Edo State',
      ),
      HistoryItem(
        year: '1994',
        event: 'Graduated University of Benin',
        detail: 'B.Sc. Business Administration',
      ),
      HistoryItem(
        year: '2003',
        event: 'Entered Private Sector',
        detail: 'Founded Okpebholo Holdings, a construction conglomerate',
      ),
      HistoryItem(
        year: '2015',
        event: 'Joined APC',
        detail: 'Became state organising secretary',
      ),
      HistoryItem(
        year: '2024',
        event: 'Gubernatorial Candidate',
        detail: 'Won APC primary, now facing general election',
      ),
    ],
  ),

  CandidateData(
    name: 'Asue Ighodalo',
    initials: 'AI',
    party: 'Peoples Democratic Party',
    partyCode: 'PDP',
    partyColor: const Color(0xFF3B82F6),
    election: 'Edo State Gubernatorial 2024',
    region: 'Oredo · Benin City',
    level: 'State',
    approvalPct: 34,
    voteShare: 0.34,
    forumQuestions: 18,
    manifestoSnippet:
        'A vision of inclusive growth — jobs, education, and healthcare for every Edo citizen.',
    bio:
        'Asue Ighodalo is a renowned corporate lawyer and businessman. He is the managing partner of Banwo & Ighodalo and has decades of experience in corporate governance.',
    radarScores: const [0.85, 0.78, 0.82, 0.68, 0.55],
    approvalHistory: const [
      0.22,
      0.25,
      0.28,
      0.30,
      0.32,
      0.31,
      0.33,
      0.34,
      0.36,
      0.34,
      0.33,
      0.34,
    ],
    milestonesTotal: 5,
    milestonesAchieved: 3,
    milestoneLabels: const ['Reg.', 'Nom.', 'Debate', 'Rally', 'Vote'],
    manifestoPoints: const [
      ManifestoPoint(
        title: 'Voter Registration Drive',
        description: '600,000 new PDP-aligned voters registered',
      ),
      ManifestoPoint(
        title: 'PDP Nomination Secured',
        description: 'Emerged as PDP flag-bearer after primary',
      ),
      ManifestoPoint(
        title: 'Economic Blueprint Released',
        description: 'Published 100-day economic action plan',
      ),
      ManifestoPoint(
        title: 'First Gubernatorial Debate',
        description: 'Upcoming — INEC-sanctioned debate',
      ),
      ManifestoPoint(
        title: 'Election Day',
        description: 'Pending — November 16, 2024',
      ),
    ],
    lifeHistory: const [
      HistoryItem(
        year: '1968',
        event: 'Born in Benin City',
        detail: 'Raised in Oredo LGA, Edo State',
      ),
      HistoryItem(
        year: '1990',
        event: 'Called to Bar',
        detail: 'Nigerian Law School, Lagos Campus',
      ),
      HistoryItem(
        year: '1996',
        event: 'Founded Banwo & Ighodalo',
        detail: 'One of Nigeria\'s foremost corporate law firms',
      ),
      HistoryItem(
        year: '2020',
        event: 'Joined PDP',
        detail: 'Began political career under Gov. Obaseki',
      ),
      HistoryItem(
        year: '2024',
        event: 'PDP Gubernatorial Candidate',
        detail: 'Faces APC in November general election',
      ),
    ],
  ),

  CandidateData(
    name: 'Olumide Akpata',
    initials: 'OA',
    party: 'Labour Party',
    partyCode: 'LP',
    partyColor: const Color(0xFFEF4444),
    election: 'Edo State Gubernatorial 2024',
    region: 'Ikpoba-Okha · Edo State',
    level: 'State',
    approvalPct: 18,
    voteShare: 0.18,
    forumQuestions: 31,
    manifestoSnippet:
        'Workers\' rights, youth employment, and constitutional reform for a truly democratic Nigeria.',
    bio:
        'Olumide Akpata is a Nigerian lawyer and former President of the Nigerian Bar Association. He is known for his advocacy of judicial independence and workers\' rights.',
    radarScores: const [0.60, 0.90, 0.65, 0.88, 0.45],
    approvalHistory: const [
      0.08,
      0.10,
      0.12,
      0.14,
      0.15,
      0.16,
      0.17,
      0.18,
      0.19,
      0.18,
      0.17,
      0.18,
    ],
    milestonesTotal: 5,
    milestonesAchieved: 2,
    milestoneLabels: const ['Reg.', 'Nom.', 'Debate', 'Rally', 'Vote'],
    manifestoPoints: const [
      ManifestoPoint(
        title: 'Labour Party Nomination',
        description: 'Secured LP ticket for Edo governorship',
      ),
      ManifestoPoint(
        title: 'Workers Manifesto Published',
        description: 'Released 50-point labour rights charter',
      ),
      ManifestoPoint(
        title: 'Youth Forum Engagement',
        description: 'Held 12 town halls across Edo State',
      ),
      ManifestoPoint(
        title: 'Debate Participation',
        description: 'Pending INEC debate',
      ),
      ManifestoPoint(
        title: 'Election Day',
        description: 'Pending November 16, 2024',
      ),
    ],
    lifeHistory: const [
      HistoryItem(
        year: '1974',
        event: 'Born in Lagos',
        detail: 'Raised in Lagos, Edo State heritage',
      ),
      HistoryItem(
        year: '1998',
        event: 'Admitted to the Bar',
        detail: 'Specialized in commercial and labour law',
      ),
      HistoryItem(
        year: '2020',
        event: 'NBA President',
        detail: 'Elected President, Nigerian Bar Association 2020–2022',
      ),
      HistoryItem(
        year: '2023',
        event: 'Joined Labour Party',
        detail: 'Declared support for LP\'s structural reform agenda',
      ),
      HistoryItem(
        year: '2024',
        event: 'LP Gubernatorial Candidate',
        detail: 'Running for Edo State Governor',
      ),
    ],
  ),

  CandidateData(
    name: 'Dr. Aisha Bukar',
    initials: 'AB',
    party: 'New Nigeria Peoples Party',
    partyCode: 'NNPP',
    partyColor: const Color(0xFFF59E0B),
    election: 'Abuja FCT Senatorial 2024',
    region: 'Abuja Municipal · FCT',
    level: 'Federal',
    approvalPct: 52,
    voteShare: 0.52,
    forumQuestions: 14,
    manifestoSnippet:
        'Digital infrastructure, women\'s rights, and a knowledge economy for a stronger FCT.',
    bio:
        'Dr. Aisha Bukar holds a PhD in Public Policy from LSE. She has served in various federal advisory capacities and is a leading advocate for digital inclusion.',
    radarScores: const [0.78, 0.82, 0.90, 0.75, 0.60],
    approvalHistory: const [
      0.40,
      0.42,
      0.45,
      0.48,
      0.50,
      0.49,
      0.51,
      0.52,
      0.54,
      0.52,
      0.51,
      0.52,
    ],
    milestonesTotal: 4,
    milestonesAchieved: 3,
    milestoneLabels: const ['Reg.', 'Nom.', 'Debate', 'Vote'],
    manifestoPoints: const [
      ManifestoPoint(
        title: 'NNPP Nomination',
        description: 'Secured senatorial ticket for Abuja FCT',
      ),
      ManifestoPoint(
        title: 'Digital Policy Framework',
        description: 'Published 40-page digital infrastructure bill',
      ),
      ManifestoPoint(
        title: 'Women\'s Forum',
        description: '10,000 women registered for voter ID drive',
      ),
      ManifestoPoint(
        title: 'Election Day',
        description: 'Pending May 12, 2024',
      ),
    ],
    lifeHistory: const [
      HistoryItem(
        year: '1980',
        event: 'Born in Maiduguri',
        detail: 'Borno State heritage, raised in Abuja',
      ),
      HistoryItem(
        year: '2003',
        event: 'MSc LSE',
        detail: 'Master\'s in Development Economics',
      ),
      HistoryItem(
        year: '2008',
        event: 'PhD Public Policy',
        detail: 'London School of Economics',
      ),
      HistoryItem(
        year: '2015',
        event: 'Federal Advisory Role',
        detail: 'Senior Policy Adviser, Federal Ministry of Communications',
      ),
      HistoryItem(
        year: '2024',
        event: 'Senatorial Candidate',
        detail: 'NNPP candidate for Abuja FCT Senate seat',
      ),
    ],
  ),
];
