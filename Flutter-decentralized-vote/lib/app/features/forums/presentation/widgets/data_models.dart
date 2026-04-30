class ForumQuestion {
  final int id;
  final String candidateName;
  final String question;
  final String election;
  final String electionLevel;
  final int upvotes;
  final int answers;
  final bool isUnanswered;
  final double hoursRemaining;
  final String answerPreview;
  final String answerFull;
  final String responseTime;
  final int answerRating;
  final String postedDisplay;
  final int postedAgo; // minutes ago for sorting
  final bool isOwn;

  const ForumQuestion({
    required this.id,
    required this.candidateName,
    required this.question,
    required this.election,
    required this.electionLevel,
    required this.upvotes,
    required this.answers,
    required this.isUnanswered,
    required this.hoursRemaining,
    this.answerPreview = '',
    this.answerFull = '',
    this.responseTime = '',
    this.answerRating = 0,
    required this.postedDisplay,
    required this.postedAgo,
    this.isOwn = false,
  });
}

class ScoreboardCandidate {
  final String name;
  final String initials;
  final double responseScore; // 0.0–1.0
  final List<double> activityDots; // 7 days, 0.0–1.0

  const ScoreboardCandidate({
    required this.name,
    required this.initials,
    required this.responseScore,
    required this.activityDots,
  });
}

// ═════════════════════════════════════════════════════════════════
// MOCK DATA
// ═════════════════════════════════════════════════════════════════

const List<ForumQuestion> allQuestions = [
  ForumQuestion(
    id: 1,
    candidateName: 'Monday Okpebholo',
    question:
        'What specific policy will you implement to reduce unemployment among Edo State youth within your first 100 days in office?',
    election: 'Edo State Gubernatorial 2024',
    electionLevel: 'STATE',
    upvotes: 2841,
    answers: 0,
    isUnanswered: true,
    hoursRemaining: 18.7,
    postedDisplay: '6h ago',
    postedAgo: 360,
    isOwn: true,
  ),
  ForumQuestion(
    id: 2,
    candidateName: 'Dr. Aisha Bukar',
    question:
        'Your manifesto mentions "digital infrastructure" — can you define the measurable KPIs you will be held to by the FCT Senate?',
    election: 'Abuja FCT Senatorial 2024',
    electionLevel: 'FEDERAL',
    upvotes: 1203,
    answers: 1,
    isUnanswered: false,
    hoursRemaining: 0,
    answerPreview:
        'We will target 500,000 new broadband connections within 18 months, with quarterly INEC-verified reporting on fibre rollout milestones.',
    answerFull:
        'We will target 500,000 new broadband connections within 18 months, '
        'with quarterly INEC-verified reporting on fibre rollout milestones. '
        'The KPIs include: (1) 80% of FCT secondary schools with fibre by Q2 2025, '
        '(2) 15% reduction in data cost per GB, (3) establishment of 3 tech hubs '
        'in underserved areas. These will be published on-chain via our governance portal.',
    responseTime: '4h 12m',
    answerRating: 4,
    postedDisplay: '2h ago',
    postedAgo: 120,
  ),
  ForumQuestion(
    id: 3,
    candidateName: 'Asue Ighodalo',
    question:
        'How will your administration address the infrastructure gap in rural Edo communities, specifically the 47 communities without motorable roads?',
    election: 'Edo State Gubernatorial 2024',
    electionLevel: 'STATE',
    upvotes: 976,
    answers: 1,
    isUnanswered: false,
    hoursRemaining: 0,
    answerPreview:
        'Our road infrastructure fund will prioritize the 47 identified communities with a ₦12 billion allocation in the first budget.',
    answerFull:
        'Our road infrastructure fund will prioritize the 47 identified communities '
        'with a ₦12 billion allocation in the first budget cycle. This will be '
        'executed through a public-private framework with verified '
        'contractors, milestone payments, and community oversight committees.',
    responseTime: '8h 55m',
    answerRating: 3,
    postedDisplay: '14h ago',
    postedAgo: 840,
  ),
  ForumQuestion(
    id: 4,
    candidateName: 'Olumide Akpata',
    question:
        'You\'ve criticised the current minimum wage structure. What specific figure do you propose and how will Edo State fund it sustainably?',
    election: 'Edo State Gubernatorial 2024',
    electionLevel: 'STATE',
    upvotes: 654,
    answers: 0,
    isUnanswered: true,
    hoursRemaining: 5.2,
    postedDisplay: '19h ago',
    postedAgo: 1140,
  ),
  ForumQuestion(
    id: 5,
    candidateName: 'Monday Okpebholo',
    question:
        'Your running mate has no prior government experience. What specific role will they play and how does this strengthen your ticket?',
    election: 'Edo State Gubernatorial 2024',
    electionLevel: 'STATE',
    upvotes: 521,
    answers: 0,
    isUnanswered: true,
    hoursRemaining: 22.1,
    postedDisplay: '2h ago',
    postedAgo: 130,
  ),
  ForumQuestion(
    id: 6,
    candidateName: 'Dr. Aisha Bukar',
    question:
        'What is your position on the proposed expansion of the FCT boundary into neighbouring states, and have you consulted affected communities?',
    election: 'Abuja FCT Senatorial 2024',
    electionLevel: 'FEDERAL',
    upvotes: 389,
    answers: 1,
    isUnanswered: false,
    hoursRemaining: 0,
    answerPreview:
        'I oppose boundary expansion without a proper community referendum. My bill will mandate consultation before any territorial adjustment.',
    answerFull:
        'I firmly oppose boundary expansion without a proper community referendum. '
        'I have already drafted a bill that mandates multi-stakeholder consultation '
        'and INEC-supervised referendums before any territorial adjustment can be '
        'approved by the Senate. Affected communities deserve a voice.',
    responseTime: '2h 07m',
    answerRating: 5,
    postedDisplay: '1d ago',
    postedAgo: 1440,
    isOwn: true,
  ),
];

const List<ScoreboardCandidate> scoreboardCandidatesData = [
  ScoreboardCandidate(
    name: 'Dr. Aisha Bukar',
    initials: 'AB',
    responseScore: 0.92,
    activityDots: [0.2, 0.8, 0.6, 1.0, 0.5, 0.9, 0.7],
  ),
  ScoreboardCandidate(
    name: 'Asue Ighodalo',
    initials: 'AI',
    responseScore: 0.74,
    activityDots: [0.5, 0.3, 0.8, 0.4, 1.0, 0.2, 0.6],
  ),
  ScoreboardCandidate(
    name: 'Monday Okpebholo',
    initials: 'MO',
    responseScore: 0.45,
    activityDots: [0.3, 0.1, 0.5, 0.2, 0.6, 0.1, 0.4],
  ),
];
