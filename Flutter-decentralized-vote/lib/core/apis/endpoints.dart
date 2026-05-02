/// Centralized API endpoint paths — VoteSecure backend (Express + FastAPI).
/// All paths are relative to the base URL set on the Dio client.
class ApiEndpoints {
  ApiEndpoints._();

  // ──────────── Auth ────────────
  static const register = '/auth/register';
  static const signIn = '/auth/signin';
  static const signOut = '/auth/signout';
  static const me = '/auth/me';
  static const verifyWallet = '/auth/verify-wallet';
  static const registerOnChain = '/auth/register-on-chain';
  static const bindDevice = '/auth/bind-device';
  static const deleteAccount = '/auth/account';

  // ──────────── Users ────────────
  static const userProfile = '/users/profile';
  static const userAvatar = '/users/avatar';
  static const userDevices = '/users/devices';
  static String userDevice(String deviceId) => '/users/devices/$deviceId';
  static const userVotingHistory = '/users/voting-history';
  static String userById(String id) => '/users/$id';

  // ──────────── Elections ────────────
  static const elections = '/elections';
  static const activeElections = '/elections/active';
  static String electionById(String id) => '/elections/$id';
  static String electionResults(String id) => '/elections/$id/results';
  static String electionsByRegion(String regionId) => '/elections/by-region/$regionId';
  static String electionPhase(String id) => '/elections/$id/phase';

  // ──────────── Votes ────────────
  static const castVote = '/votes';
  static const myVotes = '/votes/mine';
  static String voteStatus(String electionId) => '/votes/$electionId/status';

  // ──────────── Candidates ────────────
  static const registerCandidate = '/candidates';
  static String candidatesByElection(String electionId) => '/candidates/election/$electionId';
  static String candidateById(String id) => '/candidates/$id';
  static String updateCandidate(String id) => '/candidates/$id';
  static String reviewCandidate(String id) => '/candidates/$id/review';

  // ──────────── Parties ────────────
  static const parties = '/parties';
  static String partyById(String id) => '/parties/$id';
  static String approveParty(String id) => '/parties/$id/approve';

  // ──────────── Regions ────────────
  static const regions = '/regions';
  static String regionById(String id) => '/regions/$id';
  static String regionElections(String id) => '/regions/$id/elections';
  static String assignVoterRegion(String id) => '/regions/$id/assign-voter';

  // ──────────── Forum ────────────
  static const forumPosts = '/forum';
  static String forumPost(String id) => '/forum/$id';
  static String answerPost(String id) => '/forum/$id/answer';
  static String votePost(String id) => '/forum/$id/vote';

  // ──────────── Fraud ────────────
  static const fraudReports = '/fraud';
  static String resolveReport(String id) => '/fraud/$id/resolve';
  static String userRiskScore(String userId) => '/fraud/risk/$userId';

  // ──────────── Notifications ────────────
  static const notifications = '/notifications';
  static String notificationRead(String id) => '/notifications/$id/read';
  static String notificationDelete(String id) => '/notifications/$id';

  // ──────────── Analytics ────────────
  static const platformStats = '/analytics/platform';
  static String electionAnalytics(String id) => '/analytics/election/$id';
  static String turnoutByRegion(String id) => '/analytics/election/$id/turnout';

  // ──────────── Admin ────────────
  static const adminOverview = '/admin/overview';
  static const adminUsers = '/admin/users';
  static String adminSetRole(String userId) => '/admin/users/$userId/role';
  static String adminBanUser(String userId) => '/admin/users/$userId/ban';
  static String adminUnbanUser(String userId) => '/admin/users/$userId/unban';
  static const adminBroadcast = '/admin/broadcast';

  // ──────────── Wallet ────────────
  static const walletTransactions = '/wallet/transactions';
  static const walletBalance = '/wallet/balance';

  // ──────────── AI / Identity Verification (FastAPI) ────────────
  static const aiFaceVerify = '/ai/verify/face';
  static const aiLivenessCheck = '/ai/verify/liveness';
  static const aiIdScan = '/ai/verify/id';
  static const aiAgeVerify = '/ai/verify/age';
  static const aiFraudAnalyze = '/ai/fraud/analyze';
  static const aiVoterRiskScore = '/ai/fraud/risk';
}
