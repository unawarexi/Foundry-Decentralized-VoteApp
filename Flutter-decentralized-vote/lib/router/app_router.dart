import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ── Screens ──
import 'package:flutter_frontend_vote/app/screens/splash/splash_screen.dart';
import 'package:flutter_frontend_vote/app/screens/onbaording/onboarding_screen.dart';
import 'package:flutter_frontend_vote/app/bottom_navigation.dart';

// ── Auth ──
import 'package:flutter_frontend_vote/app/features/auth/presentation/signup_screen.dart';
import 'package:flutter_frontend_vote/app/features/auth/presentation/login_screen.dart';
import 'package:flutter_frontend_vote/app/features/auth/presentation/option_screen.dart';
import 'package:flutter_frontend_vote/app/features/auth/presentation/candidate_signup_screen.dart';
import 'package:flutter_frontend_vote/app/features/auth/presentation/wallet_connect_screen.dart';

// ── Elections ──
import 'package:flutter_frontend_vote/app/features/elections/presentation/screens/elections_screen.dart';
import 'package:flutter_frontend_vote/app/features/elections/presentation/screens/election_detail_screen.dart';
import 'package:flutter_frontend_vote/app/features/election/presentation/create_election_screen.dart';

// ── Voting ──
import 'package:flutter_frontend_vote/app/features/voting/presentation/screens/vote_casting_screen.dart';
import 'package:flutter_frontend_vote/app/features/voting/presentation/vote_confirmation_screen.dart';
import 'package:flutter_frontend_vote/app/features/voting/presentation/vote_receipt_screen.dart';

// ── Candidates ──
import 'package:flutter_frontend_vote/app/features/candidates/presentation/screens/candidate_profile_screen.dart';
import 'package:flutter_frontend_vote/app/features/candidates/presentation/screens/candidates_screen.dart';
import 'package:flutter_frontend_vote/app/features/candidate/presentation/candidate_qa_screen.dart';
import 'package:flutter_frontend_vote/app/features/candidate/presentation/manifesto_screen.dart';

// ── AI Checks ──
import 'package:flutter_frontend_vote/app/features/ai_checks/presentation/face_verification_screen.dart';
import 'package:flutter_frontend_vote/app/features/ai_checks/presentation/liveness_check_screen.dart';
import 'package:flutter_frontend_vote/app/features/ai_checks/presentation/id_scan_screen.dart';

// ── Wallet ──
import 'package:flutter_frontend_vote/app/features/wallet/presentation/wallet_screen.dart';
import 'package:flutter_frontend_vote/app/features/wallet/presentation/transaction_history_screen.dart';

// ── Region ──
import 'package:flutter_frontend_vote/app/features/region/presentation/region_map_screen.dart';

// ── Forum ──
import 'package:flutter_frontend_vote/app/features/forums/presentation/screens/forums_screen.dart';
import 'package:flutter_frontend_vote/app/features/forums/presentation/screens/question_detail_screen.dart';

// ── Analytics / Settings / Legal ──
import 'package:flutter_frontend_vote/app/features/analytics/presentation/analytics_dashboard_screen.dart';
import 'package:flutter_frontend_vote/app/features/settings/presentation/settings_screen.dart';
import 'package:flutter_frontend_vote/app/features/legal/presentation/terms_of_service_screen.dart';
import 'package:flutter_frontend_vote/app/features/legal/presentation/privacy_policy_screen.dart';
import 'package:flutter_frontend_vote/app/features/notification/presentation/notifications_screen.dart';
import 'package:flutter_frontend_vote/app/features/search/presentation/search_screen.dart';
import 'package:flutter_frontend_vote/app/features/global_dashboard/presentation/global_dashboard_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

/// VoteSecure application router.
///
/// Deep link schemes:
///   votesecure://election/:id     → election details
///   votesecure://vote/:id         → cast vote for election
///   votesecure://candidate/:id    → candidate profile
final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/splash',
  debugLogDiagnostics: true,

  routes: [
    // ──────────── Splash ────────────
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),

    // ──────────── Onboarding ────────────
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),

    // ──────────── Auth ────────────
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      name: 'signup',
      builder: (context, state) => const SignUpScreen(),
    ),
    GoRoute(
      path: '/option',
      name: 'option',
      builder: (context, state) => const AuthOptionScreen(),
    ),
    GoRoute(
      path: '/candidate-signup',
      name: 'candidate-signup',
      builder: (context, state) => const CandidateSignUpScreen(),
    ),
    GoRoute(
      path: '/wallet-connect',
      name: 'wallet-connect',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const WalletConnectScreen(),
    ),

    // ──────────── Main App (Bottom Nav) ────────────
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const BottomNavigation(),
    ),

    // ──────────── Elections ────────────
    GoRoute(
      path: '/elections',
      name: 'elections',
      builder: (context, state) => const ElectionsScreen(),
    ),
    GoRoute(
      path: '/election/:id',
      name: 'election-detail',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const ElectionDetailScreen(),
    ),
    GoRoute(
      path: '/create-election',
      name: 'create-election',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const ElectionDetailScreen(),
    ),

    // ──────────── Voting ────────────
    GoRoute(
      path: '/vote/:electionId',
      name: 'cast-vote',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const VoteCastingScreen(),
    ),
    GoRoute(
      path: '/vote-confirmation',
      name: 'vote-confirmation',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const VoteCastingScreen(),
    ),
    GoRoute(
      path: '/vote-receipt/:txHash',
      name: 'vote-receipt',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const VoteReceiptScreen(),
    ),

    // ──────────── Candidates ────────────
    GoRoute(
      path: '/candidates',
      name: 'candidates',
      builder: (context, state) => const CandidatesScreen(),
    ),
    GoRoute(
      path: '/candidate/:id',
      name: 'candidate-profile',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const CandidateProfileScreen(),
    ),
    GoRoute(
      path: '/candidate/:id/qa',
      name: 'candidate-qa',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const CandidateProfileScreen(),
    ),
    GoRoute(
      path: '/candidate/:id/manifesto',
      name: 'candidate-manifesto',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const ManifestoScreen(),
    ),

    // ──────────── AI Verification ────────────
    GoRoute(
      path: '/verify/face',
      name: 'face-verification',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const FaceVerificationScreen(),
    ),
    GoRoute(
      path: '/verify/liveness',
      name: 'liveness-check',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const LivenessCheckScreen(),
    ),
    GoRoute(
      path: '/verify/id',
      name: 'id-scan',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const IdScanScreen(),
    ),

    // ──────────── Wallet ────────────
    GoRoute(
      path: '/wallet',
      name: 'wallet',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const WalletScreen(),
    ),
    GoRoute(
      path: '/transactions',
      name: 'transactions',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const TransactionHistoryScreen(),
    ),

    // ──────────── Forum ────────────
    GoRoute(
      path: '/forum',
      name: 'forum',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const ForumScreen(),
    ),
    GoRoute(
      path: '/forum/question/:id',
      name: 'question-detail',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const QuestionDetailScreen(),
    ),

    // ──────────── Region ────────────
    GoRoute(
      path: '/region-map',
      name: 'region-map',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const RegionMapScreen(),
    ),

    // ──────────── Analytics ────────────
    GoRoute(
      path: '/analytics',
      name: 'analytics',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const AnalyticsDashboardScreen(),
    ),

    // ──────────── Global Dashboard ────────────
    GoRoute(
      path: '/global',
      name: 'global-dashboard',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const GlobalDashboardScreen(),
    ),

    // ──────────── Settings ────────────
    GoRoute(
      path: '/settings',
      name: 'settings',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const SettingsScreen(),
    ),

    // ──────────── Search / Notifications ────────────
    GoRoute(
      path: '/search',
      name: 'search',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const SearchScreen(),
    ),
    GoRoute(
      path: '/notifications',
      name: 'notifications',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const NotificationsScreen(),
    ),

    // ──────────── Legal ────────────
    GoRoute(
      path: '/terms',
      name: 'terms',
      builder: (context, state) => const TermsOfServiceScreen(),
    ),
    GoRoute(
      path: '/privacy',
      name: 'privacy',
      builder: (context, state) => const PrivacyPolicyScreen(),
    ),
  ],

  // Error / 404
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text('Page not found', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/option'),
            child: const Text('Go Home'),
          ),
        ],
      ),
    ),
  ),
);
