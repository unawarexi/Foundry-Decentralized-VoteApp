enum ElectionStatus { live, upcoming, closed }

class ElectionData {
  final String title;
  final String region;
  final String level;
  final ElectionStatus status;
  final int participation;
  final String timeDisplay;
  final int candidates;
  final bool isBookmarked;

  const ElectionData({
    required this.title,
    required this.region,
    required this.level,
    required this.status,
    required this.participation,
    required this.timeDisplay,
    required this.candidates,
    this.isBookmarked = false,
  });
}

class CandidateData {
  final String name;
  final String initials;
  final String party;
  final int pollPct;

  const CandidateData({
    required this.name,
    required this.initials,
    required this.party,
    required this.pollPct,
  });
}

const List<ElectionData> allElections = [
  // ── LIVE
  ElectionData(
    title: 'Edo State Gubernatorial Election 2024',
    region: 'Benin City · Edo State',
    level: 'State',
    status: ElectionStatus.live,
    participation: 68,
    timeDisplay: '4h 22m left',
    candidates: 7,
    isBookmarked: true,
  ),
  ElectionData(
    title: 'Lagos Local Government Area Chairman',
    region: 'Ikeja · Lagos State',
    level: 'Local Gov',
    status: ElectionStatus.live,
    participation: 55,
    timeDisplay: '11h 08m left',
    candidates: 5,
  ),
  ElectionData(
    title: 'University of Benin Student Union President',
    region: 'Ugbowo Campus · NG',
    level: 'Campus',
    status: ElectionStatus.live,
    participation: 42,
    timeDisplay: '2d 4h left',
    candidates: 4,
  ),
  // ── UPCOMING
  ElectionData(
    title: 'Federal House of Representatives — Edo North',
    region: 'Etsako West · Edo State',
    level: 'Federal',
    status: ElectionStatus.upcoming,
    participation: 0,
    timeDisplay: 'Jun 3, 2024',
    candidates: 6,
  ),
  ElectionData(
    title: 'Abuja FCT Senatorial District Poll',
    region: 'Federal Capital Territory',
    level: 'Federal',
    status: ElectionStatus.upcoming,
    participation: 0,
    timeDisplay: 'May 12, 2024',
    candidates: 4,
    isBookmarked: true,
  ),
  ElectionData(
    title: 'Rivers State Local Council Elections',
    region: 'Port Harcourt · Rivers State',
    level: 'Local Gov',
    status: ElectionStatus.upcoming,
    participation: 0,
    timeDisplay: 'May 19, 2024',
    candidates: 8,
  ),
  ElectionData(
    title: 'Zenith Bank Board of Directors Election',
    region: 'Lagos · Corporate',
    level: 'Corporate',
    status: ElectionStatus.upcoming,
    participation: 0,
    timeDisplay: 'May 30, 2024',
    candidates: 3,
  ),
  // ── CLOSED
  ElectionData(
    title: 'Kano State Gubernatorial Election 2023',
    region: 'Kano · Kano State',
    level: 'State',
    status: ElectionStatus.closed,
    participation: 81,
    timeDisplay: 'Closed Mar 18',
    candidates: 5,
  ),
  ElectionData(
    title: 'Covenant University SUG Elections',
    region: 'Ota · Ogun State',
    level: 'Campus',
    status: ElectionStatus.closed,
    participation: 77,
    timeDisplay: 'Closed Apr 2',
    candidates: 3,
  ),
];

const List<CandidateData> mockCandidates = [
  CandidateData(
    name: 'Monday Okpebholo',
    initials: 'MO',
    party: 'APC · All Progressives Congress',
    pollPct: 38,
  ),
  CandidateData(
    name: 'Asue Ighodalo',
    initials: 'AI',
    party: 'PDP · Peoples Democratic Party',
    pollPct: 34,
  ),
  CandidateData(
    name: 'Olumide Akpata',
    initials: 'OA',
    party: 'LP · Labour Party',
    pollPct: 18,
  ),
  CandidateData(
    name: 'Kenneth Imasuangbon',
    initials: 'KI',
    party: 'IND · Independent',
    pollPct: 10,
  ),
];
