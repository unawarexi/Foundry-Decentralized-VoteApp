# VoteSecure Flutter — Project Skills Reference

> **App**: VoteSecure — Decentralized civic voting platform  
> **Package**: `flutter_frontend_vote`  
> **Flutter SDK**: ^3.8.0  
> **State Management**: Riverpod 2.6 (manual `StateNotifier`, no code-gen)  
> **Navigation**: GoRouter 16.0  
> **Design System**: Material 3 (light/dark, `TAppTheme`)  
> **Backend**: Node.js (Express) + FastAPI (AI layer)  
> **Auth**: Firebase Auth + Biometric (`local_auth`) + Google Sign-In  
> **Blockchain**: `web3dart` + `walletconnect_dart`  
> **Real-time**: Socket.IO (`socket_io_client`)  
> **DI**: GetIt 8.0 (`injection_container.dart`)  
> **Local Cache**: Hive + GetStorage + FlutterSecureStorage  

---

## Table of Contents

1. [Directory Structure](#1-directory-structure)
2. [Entry Point & App Setup](#2-entry-point--app-setup)
3. [State Management (Riverpod)](#3-state-management-riverpod)
4. [Routing / Navigation (GoRouter)](#4-routing--navigation-gorouter)
5. [Screens & Pages](#5-screens--pages)
6. [Components / Widgets](#6-components--widgets)
7. [Services / Core Layer](#7-services--core-layer)
8. [Models / Domain Layer](#8-models--domain-layer)
9. [Theme / Design System](#9-theme--design-system)
10. [Key Dependencies](#10-key-dependencies)
11. [Assets](#11-assets)
12. [Build Status](#12-build-status)

---

## 1. Directory Structure

```
lib/
├── main.dart                          # Entry point — DI init, Hive, orientation lock, ProviderScope
├── app.dart                           # VoteSecureApp — MaterialApp.router + ConnectivityToast overlay
├── injection_container.dart           # GetIt DI bootstrap (TODO: register repos + use cases)
│
├── app/
│   ├── bottom_navigation.dart         # Bottom nav shell (tab routing)
│   │
│   ├── components/
│   │   ├── nav/                       # Nav-specific components
│   │   ├── onboarding/                # Onboarding component widgets
│   │   ├── shapes/
│   │   │   ├── shapes.dart            # Barrel export
│   │   │   ├── bg_patterns.dart       # Background pattern painters
│   │   │   ├── curved_clippers.dart   # Custom ClipPath shapes
│   │   │   └── decorative_painters.dart
│   │   ├── splash/                    # Splash component widgets
│   │   ├── ui/
│   │   │   ├── activity_indicator.dart
│   │   │   ├── bottom_sheet.dart
│   │   │   ├── button.dart
│   │   │   ├── card.dart
│   │   │   ├── connectivity_toast.dart  # Auto offline/online toast
│   │   │   ├── dense_widgets.dart
│   │   │   ├── input.dart
│   │   │   ├── modal.dart
│   │   │   ├── skeleton.dart
│   │   │   └── toast_notifier.dart
│   │   └── widgets/
│   │       ├── app_bar.dart
│   │       ├── date_time_picker.dart
│   │       ├── fab.dart
│   │       ├── input_fields.dart
│   │       └── spinners.dart
│   │
│   ├── domain/
│   │   ├── models/
│   │   │   ├── candidate_model.dart   # TODO
│   │   │   ├── election_model.dart    # TODO
│   │   │   ├── forum_model.dart       # TODO
│   │   │   ├── party_model.dart       # TODO
│   │   │   ├── region_model.dart      # TODO
│   │   │   ├── user_model.dart        # TODO
│   │   │   ├── verification_model.dart # TODO
│   │   │   ├── vote_model.dart        # TODO
│   │   │   └── wallet_model.dart      # TODO
│   │   └── repositories/
│   │       ├── analytics_repository.dart
│   │       ├── auth_repository.dart
│   │       ├── candidate_repository.dart
│   │       ├── election_repository.dart
│   │       ├── forum_repository.dart
│   │       ├── region_repository.dart
│   │       ├── verification_repository.dart
│   │       ├── vote_repository.dart
│   │       └── wallet_repository.dart
│   │
│   ├── features/
│   │   ├── admins/
│   │   │   ├── create_candidates_form.dart
│   │   │   └── forms/
│   │   │
│   │   ├── ai_checks/presentation/
│   │   │   ├── age_verification_screen.dart
│   │   │   ├── face_verification_screen.dart  # Live face check via flutter_face_api
│   │   │   ├── id_scan_screen.dart            # Government ID OCR scan
│   │   │   ├── liveness_check_screen.dart     # Anti-spoofing liveness detection
│   │   │   └── widgets/
│   │   │
│   │   ├── analytics/presentation/
│   │   │   ├── analytics_dashboard_screen.dart
│   │   │   └── widgets/
│   │   │
│   │   ├── auth/presentation/
│   │   │   ├── candidate_signup_screen.dart   # Candidate-specific registration
│   │   │   ├── login_screen.dart
│   │   │   ├── option_screen.dart             # Auth entry — voter vs candidate
│   │   │   ├── signup_screen.dart
│   │   │   ├── wallet_connect_screen.dart     # WalletConnect onboarding
│   │   │   └── widgets/
│   │   │
│   │   ├── candidate/presentation/
│   │   │   ├── candidate_list_screen.dart
│   │   │   ├── candidate_profile_screen.dart
│   │   │   ├── candidate_qa_screen.dart       # Public Q&A per candidate
│   │   │   └── manifesto_screen.dart          # Manifesto viewer
│   │   │
│   │   ├── candidates/presentation/screens/
│   │   │   ├── candidate_profile_screen.dart
│   │   │   └── candidates_screen.dart
│   │   │
│   │   ├── election/presentation/
│   │   │   ├── create_election_screen.dart
│   │   │   ├── election_detail_screen.dart
│   │   │   └── elections_list_screen.dart
│   │   │
│   │   ├── elections/presentation/screens/
│   │   │   ├── election_detail_screen.dart
│   │   │   └── elections_screen.dart
│   │   │
│   │   ├── forum/presentation/
│   │   │   ├── ask_question_screen.dart
│   │   │   ├── forum_screen.dart
│   │   │   └── question_detail_screen.dart
│   │   │
│   │   ├── forums/presentation/screens/
│   │   │   ├── forums_screen.dart
│   │   │   └── question_detail_screen.dart
│   │   │
│   │   ├── global_dashboard/presentation/
│   │   │   └── global_dashboard_screen.dart   # Live elections worldwide
│   │   │
│   │   ├── home/presentation/screens/
│   │   │   └── home_screen.dart
│   │   │
│   │   ├── legal/presentation/
│   │   │   ├── privacy_policy_screen.dart
│   │   │   └── terms_of_service_screen.dart
│   │   │
│   │   ├── notification/presentation/
│   │   │   └── notifications_screen.dart
│   │   │
│   │   ├── offline_sync/presentation/
│   │   │   └── offline_sync_screen.dart       # Kiosk / offline vote queue
│   │   │
│   │   ├── profile/presentation/screens/
│   │   │   └── profile_screen.dart
│   │   │
│   │   ├── region/presentation/
│   │   │   ├── region_map_screen.dart         # Map-based region visualisation
│   │   │   └── region_selection_screen.dart
│   │   │
│   │   ├── search/presentation/
│   │   │   └── search_screen.dart
│   │   │
│   │   ├── settings/presentation/
│   │   │   └── settings_screen.dart
│   │   │
│   │   ├── voting/presentation/
│   │   │   ├── screens/
│   │   │   │   └── vote_casting_screen.dart   # Biometric confirm + fee deduction
│   │   │   ├── vote_confirmation_screen.dart
│   │   │   ├── vote_receipt_screen.dart       # On-chain tx hash receipt
│   │   │   └── widgets/
│   │   │
│   │   └── wallet/presentation/
│   │       ├── transaction_history_screen.dart
│   │       ├── wallet_connect_screen.dart
│   │       └── wallet_screen.dart             # USDT/USDC/BTC balance + send
│   │
│   └── screens/
│       ├── onbaording/
│       │   └── onboarding_screen.dart
│       └── splash/
│           └── splash_screen.dart
│
├── core/
│   ├── algo/                          # (reserved — consensus / ZK helpers)
│   ├── animations/
│   │   ├── animations.dart            # Barrel export
│   │   ├── page_transitions.dart      # GoRouter page transitions
│   │   ├── screen_animations.dart     # Reveal, pulse, shimmer, stagger
│   │   └── widget_animations.dart     # fadeIn, scaleIn, slideUp
│   │
│   ├── apis/
│   │   └── endpoints.dart             # ApiEndpoints — all REST paths (centralized)
│   │
│   ├── auth/
│   │   ├── google_signin.dart         # GoogleSignInService
│   │   └── local_auth.dart            # LocalAuthService — biometric prompt
│   │
│   ├── config/
│   │   ├── base_url.dart              # AppBaseUrl — resolves API URL per platform/env
│   │   └── environment.dart           # Environment — dotenv keys
│   │
│   ├── constants/
│   │   ├── colors.dart                # TColors — primary palette, dark/light surfaces
│   │   ├── icons.dart                 # SIcons — Iconsax icon mappings
│   │   ├── image_strings.dart         # SImages — asset paths
│   │   ├── responsive.dart            # SResponsive — breakpoints, ResponsiveLayout
│   │   ├── sizes.dart                 # SSizes — spacing, radius, component heights
│   │   └── text_strings.dart          # STexts — all static UI strings
│   │
│   ├── db/
│   │   └── hive.dart                  # HiveService — cache boxes, TTL, pruneExpired()
│   │
│   ├── errors/
│   │   ├── exceptions.dart            # ServerException, CacheException, NetworkException
│   │   └── failures.dart              # Failure types for Result pattern
│   │
│   ├── network/
│   │   ├── account_guard.dart         # Detects banned/suspended accounts, forces sign-out
│   │   ├── api_client.dart            # ApiClient (Dio singleton) — interceptors: connectivity,
│   │   │                              #   auth token injection, retry, debug logger
│   │   ├── api_exception.dart         # ApiException, ApiResult<T>
│   │   └── connectivity_service.dart  # ConnectivityService — isConnected, stream
│   │
│   ├── services/
│   │   ├── notification_service.dart  # FCM + flutter_local_notifications
│   │   ├── storage_service.dart       # SecureStorageService (tokens) +
│   │   │                              #   LocalStorageService (preferences, settings)
│   │   └── websocket.dart             # WebSocketService (Socket.IO singleton)
│   │
│   └── utils/
│       ├── file_picker.dart           # FilePickerWithPermissions
│       ├── formatters.dart            # SFormatters — date, time, duration, truncate
│       ├── helper_functions.dart      # SHelpers — platform checks, clipboard, URL open
│       ├── permission_handler.dart    # PermissionManager — camera, mic, location, storage
│       └── validators.dart            # validateEmail, Password, Name, etc.
│
├── router/
│   └── app_router.dart                # GoRouter config — all routes + deep link schemes
│
├── store/                             # Riverpod providers (most are TODO stubs)
│   ├── analytics_provider.dart        # TODO
│   ├── auth_provider.dart             # TODO
│   ├── candidate_provider.dart        # TODO
│   ├── connectivity_provider.dart     # TODO
│   ├── election_provider.dart         # TODO
│   ├── forum_provider.dart            # TODO
│   ├── region_provider.dart           # TODO
│   ├── theme_provider.dart            # DONE — ThemeModeNotifier (persisted)
│   ├── user_provider.dart             # TODO
│   ├── verification_provider.dart     # TODO
│   ├── vote_provider.dart             # TODO
│   └── wallet_provider.dart           # TODO
│
└── theme/
    ├── theme.dart                     # TAppTheme — lightTheme + darkTheme (Material 3)
    └── custom_themes/
        ├── app_bar_theme.dart
        ├── bottom_sheet_theme.dart
        ├── check_box_theme.dart
        ├── chip_theme.dart
        ├── elevated_button_theme.dart
        ├── outlined_button_theme.dart
        ├── text_field_theme.dart
        └── text_theme.dart
```

---

## 2. Entry Point & App Setup

### `lib/main.dart`

Boot sequence:
1. `WidgetsFlutterBinding.ensureInitialized()`
2. `initDependencies()` — GetIt DI registration
3. Parallel: `HiveService.init()` + `LocalStorageService.init()`
4. `HiveService.pruneExpired()` — clean stale cache
5. Lock orientation to portrait on mobile
6. `runApp(ProviderScope(child: VoteSecureApp()))`

### `lib/app.dart` — `VoteSecureApp`

- `ConsumerWidget` reads `themeModeProvider`
- `MaterialApp.router` with `TAppTheme.lightTheme / darkTheme` and `appRouter`
- `builder` wraps child in `Overlay` with `ConnectivityToast` pinned at top
- Applies `SystemUiOverlayStyle` (transparent status bar, adaptive icon brightness)

### `lib/injection_container.dart`

- GetIt singleton `sl`
- `initDependencies()` stub — awaiting repo + use case registration

---

## 3. State Management (Riverpod)

All providers live in `lib/store/`. Pattern is manual `StateNotifier` (no Riverpod code-gen).

### Implemented

| Provider | Type | Notes |
|---|---|---|
| `themeModeProvider` | `StateNotifierProvider<ThemeModeNotifier, ThemeMode>` | Persisted via `LocalStorageService`. Methods: `setThemeMode()`, `toggleDarkMode()` |

### Stubbed — Next to Implement

| Provider | File | Domain |
|---|---|---|
| `authProvider` | `auth_provider.dart` | Sign-in, sign-out, current user, biometric flag |
| `electionProvider` | `election_provider.dart` | Election list, detail, create, status |
| `voteProvider` | `vote_provider.dart` | Cast vote, receipt, on-chain confirmation |
| `candidateProvider` | `candidate_provider.dart` | Candidate list, profile, Q&A, manifesto |
| `forumProvider` | `forum_provider.dart` | Questions, upvotes, answers, 24hr SLA timer |
| `walletProvider` | `wallet_provider.dart` | Balance, WalletConnect session, tx history |
| `regionProvider` | `region_provider.dart` | Region lock, GPS/IP correlation |
| `verificationProvider` | `verification_provider.dart` | AI face check, liveness, ID scan state |
| `analyticsProvider` | `analytics_provider.dart` | Election stats, participation metrics |
| `userProvider` | `user_provider.dart` | Profile update, avatar, device binding |
| `connectivityProvider` | `connectivity_provider.dart` | Network state, offline queue |

---

## 4. Routing / Navigation (GoRouter)

**File**: `lib/router/app_router.dart`

Deep link schemes:
```
votesecure://election/:id     -> ElectionDetailScreen
votesecure://vote/:id         -> VoteCastingScreen
votesecure://candidate/:id    -> CandidateProfileScreen
```

### Full Route Table

| Path | Name | Screen |
|---|---|---|
| `/splash` | `splash` | `SplashScreen` |
| `/onboarding` | `onboarding` | `OnboardingScreen` |
| `/option` | `option` | `AuthOptionScreen` — voter vs candidate entry |
| `/login` | `login` | `LoginScreen` |
| `/signup` | `signup` | `SignUpScreen` |
| `/candidate-signup` | `candidate-signup` | `CandidateSignUpScreen` |
| `/home` | `home` | `BottomNavigation` shell |
| `/elections` | `elections` | `ElectionsScreen` |
| `/election/:id` | `election-detail` | `ElectionDetailScreen` |
| `/create-election` | `create-election` | `CreateElectionScreen` |
| `/vote/:electionId` | `cast-vote` | `VoteCastingScreen` |
| `/vote-confirmation` | `vote-confirmation` | `VoteConfirmationScreen` |
| `/vote-receipt/:txHash` | `vote-receipt` | `VoteReceiptScreen` |
| `/candidates` | `candidates` | `CandidatesScreen` |
| `/candidate/:id` | `candidate-profile` | `CandidateProfileScreen` |
| `/candidate/:id/qa` | `candidate-qa` | `CandidateQAScreen` |
| `/candidate/:id/manifesto` | `candidate-manifesto` | `ManifestoScreen` |
| `/verify/face` | `face-verification` | `FaceVerificationScreen` |
| `/verify/liveness` | `liveness-check` | `LivenessCheckScreen` |
| `/verify/id` | `id-scan` | `IdScanScreen` |
| `/wallet` | `wallet` | `WalletScreen` |
| `/transactions` | `transactions` | `TransactionHistoryScreen` |
| `/forum` | `forum` | `ForumScreen` |
| `/forum/question/:id` | `question-detail` | `QuestionDetailScreen` |
| `/region-map` | `region-map` | `RegionMapScreen` |
| `/analytics` | `analytics` | `AnalyticsDashboardScreen` |
| `/global` | `global-dashboard` | `GlobalDashboardScreen` |
| `/settings` | `settings` | `SettingsScreen` |
| `/search` | `search` | `SearchScreen` |
| `/notifications` | `notifications` | `NotificationsScreen` |
| `/terms` | `terms` | `TermsOfServiceScreen` |
| `/privacy` | `privacy` | `PrivacyPolicyScreen` |

**404**: Custom error page with icon, path display, "Go Home" -> `/option`.

---

## 5. Screens & Pages

### Onboarding & Auth Flow

| Screen | File | Notes |
|---|---|---|
| `SplashScreen` | `app/screens/splash/splash_screen.dart` | Brand reveal animation |
| `OnboardingScreen` | `app/screens/onbaording/onboarding_screen.dart` | Multi-step slides |
| `AuthOptionScreen` | `app/features/auth/presentation/option_screen.dart` | Voter vs Candidate picker |
| `LoginScreen` | `app/features/auth/presentation/login_screen.dart` | Firebase Auth + biometric |
| `SignUpScreen` | `app/features/auth/presentation/signup_screen.dart` | Voter registration |
| `CandidateSignUpScreen` | `app/features/auth/presentation/candidate_signup_screen.dart` | Candidate-specific registration |
| `WalletConnectScreen` (auth) | `app/features/auth/presentation/wallet_connect_screen.dart` | WalletConnect flow at onboarding |

### AI Identity Verification Flow

| Screen | File | Notes |
|---|---|---|
| `AgeVerificationScreen` | `app/features/ai_checks/presentation/age_verification_screen.dart` | AI-inferred age check |
| `FaceVerificationScreen` | `app/features/ai_checks/presentation/face_verification_screen.dart` | `flutter_face_api` live face match |
| `LivenessCheckScreen` | `app/features/ai_checks/presentation/liveness_check_screen.dart` | Anti-spoofing liveness |
| `IdScanScreen` | `app/features/ai_checks/presentation/id_scan_screen.dart` | Government ID OCR |

### Elections & Voting

| Screen | File | Notes |
|---|---|---|
| `ElectionsScreen` | `app/features/elections/presentation/screens/elections_screen.dart` | Browse all elections |
| `ElectionDetailScreen` | `app/features/elections/presentation/screens/election_detail_screen.dart` | Info, candidates, status |
| `CreateElectionScreen` | `app/features/election/presentation/create_election_screen.dart` | Admin: create election |
| `VoteCastingScreen` | `app/features/voting/presentation/screens/vote_casting_screen.dart` | Biometric confirm + $1 fee deduction |
| `VoteConfirmationScreen` | `app/features/voting/presentation/vote_confirmation_screen.dart` | Pre-submit review |
| `VoteReceiptScreen` | `app/features/voting/presentation/vote_receipt_screen.dart` | On-chain tx hash receipt |

### Candidates & Manifestos

| Screen | File | Notes |
|---|---|---|
| `CandidatesScreen` | `app/features/candidates/presentation/screens/candidates_screen.dart` | All candidates for an election |
| `CandidateProfileScreen` | `app/features/candidates/presentation/screens/candidate_profile_screen.dart` | Bio, history, milestones |
| `CandidateQAScreen` | `app/features/candidate/presentation/candidate_qa_screen.dart` | Public Q&A, upvote, 24hr SLA timer |
| `ManifestoScreen` | `app/features/candidate/presentation/manifesto_screen.dart` | Manifesto + verified achievements |

### Forum & Community

| Screen | File | Notes |
|---|---|---|
| `ForumScreen` | `app/features/forums/presentation/screens/forums_screen.dart` | All forum questions |
| `QuestionDetailScreen` | `app/features/forums/presentation/screens/question_detail_screen.dart` | Answers, upvotes/downvotes |
| `AskQuestionScreen` | `app/features/forum/presentation/ask_question_screen.dart` | Submit question to a candidate |

### Wallet & Payments

| Screen | File | Notes |
|---|---|---|
| `WalletScreen` | `app/features/wallet/presentation/wallet_screen.dart` | USDT/USDC/BTC balance, connect wallet |
| `WalletConnectScreen` | `app/features/wallet/presentation/wallet_connect_screen.dart` | WalletConnect session management |
| `TransactionHistoryScreen` | `app/features/wallet/presentation/transaction_history_screen.dart` | Voting fee + transfer history |

### Region & Global

| Screen | File | Notes |
|---|---|---|
| `RegionMapScreen` | `app/features/region/presentation/region_map_screen.dart` | Map visualisation of regions |
| `RegionSelectionScreen` | `app/features/region/presentation/region_selection_screen.dart` | Region lock selection |
| `GlobalDashboardScreen` | `app/features/global_dashboard/presentation/global_dashboard_screen.dart` | Live worldwide elections |

### Utility Screens

| Screen | File |
|---|---|
| `AnalyticsDashboardScreen` | `app/features/analytics/presentation/analytics_dashboard_screen.dart` |
| `SettingsScreen` | `app/features/settings/presentation/settings_screen.dart` |
| `NotificationsScreen` | `app/features/notification/presentation/notifications_screen.dart` |
| `SearchScreen` | `app/features/search/presentation/search_screen.dart` |
| `OfflineSyncScreen` | `app/features/offline_sync/presentation/offline_sync_screen.dart` |
| `ProfileScreen` | `app/features/profile/presentation/screens/profile_screen.dart` |
| `TermsOfServiceScreen` | `app/features/legal/presentation/terms_of_service_screen.dart` |
| `PrivacyPolicyScreen` | `app/features/legal/presentation/privacy_policy_screen.dart` |

---

## 6. Components / Widgets

### `app/components/ui/`

| File | Exports |
|---|---|
| `activity_indicator.dart` | Loading indicator, loading overlay |
| `bottom_sheet.dart` | Reusable bottom sheet |
| `button.dart` | Button variants, icon button |
| `card.dart` | Card, election card |
| `connectivity_toast.dart` | Auto offline / online banner |
| `dense_widgets.dart` | Section headers, dense tiles, compact list items |
| `input.dart` | Text input, search bar |
| `modal.dart` | Alert / confirm dialog |
| `skeleton.dart` | Skeleton loaders for cards, avatars |
| `toast_notifier.dart` | Toast wrapper |

### `app/components/widgets/`

| File | Purpose |
|---|---|
| `app_bar.dart` | Custom app bar |
| `date_time_picker.dart` | Date/time picker |
| `fab.dart` | Floating action button |
| `input_fields.dart` | Specialised form inputs |
| `spinners.dart` | Loading spinner variants |

### `app/components/shapes/`

`bg_patterns.dart`, `curved_clippers.dart`, `decorative_painters.dart` — background and decorative painting utilities.

---

## 7. Services / Core Layer

### Network — `core/network/`

| File | Purpose |
|---|---|
| `api_client.dart` | `ApiClient` (Dio singleton). Interceptors: `ConnectivityInterceptor` (blocks offline requests), `AuthInterceptor` (injects Firebase ID token), `RetryInterceptor` (3 retries, exponential backoff), `LogInterceptor` (debug only). Methods: `get`, `post`, `put`, `patch`, `delete`, `upload`. |
| `api_exception.dart` | `ApiException`, `ApiResult<T>` success/failure wrapper |
| `connectivity_service.dart` | `ConnectivityService` — `isConnected`, `onConnectivityChanged` stream |
| `account_guard.dart` | Detects banned/suspended accounts, forces sign-out and redirect |

### Storage — `core/services/`

| File | Purpose |
|---|---|
| `storage_service.dart` | `SecureStorageService` (`flutter_secure_storage`) for tokens/user ID. `LocalStorageService` (`get_storage`) for preferences: onboarding flag, theme mode, biometric, AI feature toggles. |
| `notification_service.dart` | FCM + `flutter_local_notifications` integration |
| `websocket.dart` | `WebSocketService` — Socket.IO singleton, connect/disconnect, emit/on/off, event stream |

### Auth — `core/auth/`

| File | Purpose |
|---|---|
| `google_signin.dart` | `GoogleSignInService` — init, sign in, sign out |
| `local_auth.dart` | `LocalAuthService` — biometric availability check, authenticate prompt |

### Cache — `core/db/`

| File | Purpose |
|---|---|
| `hive.dart` | `HiveService` — named cache boxes (user, election, candidate, etc.), TTL-aware reads/writes, `pruneExpired()` |

### Utils — `core/utils/`

| File | Exports |
|---|---|
| `formatters.dart` | `SFormatters` — date, time, relative time, duration, truncate |
| `helper_functions.dart` | `SHelpers` — `isWeb/isMobile/isDesktop`, `isDarkMode`, clipboard, URL open, snack bar |
| `permission_handler.dart` | `PermissionManager` — camera, microphone, location, storage, photos |
| `validators.dart` | `validateEmail`, `validatePassword`, `validateName`, `validateRequired` |
| `file_picker.dart` | `FilePickerWithPermissions` — image from gallery/camera, file, multiple images |

---

## 8. Models / Domain Layer

All domain models are in `app/domain/models/`. All are currently TODO stubs.

| Model | File | Planned Fields |
|---|---|---|
| `UserModel` | `user_model.dart` | id, name, email, region, walletAddress, verificationStatus, role, deviceId |
| `ElectionModel` | `election_model.dart` | id, title, type, regionId, startDate, endDate, status, candidateIds, voteCount |
| `CandidateModel` | `candidate_model.dart` | id, userId, partyId, manifesto, achievements, milestones, qaThreadId, popularityScore |
| `VoteModel` | `vote_model.dart` | id, electionId, candidateId, voterId, txHash, timestamp, feePaid |
| `ForumModel` | `forum_model.dart` | questionId, electionId, candidateId, content, upvotes, answeredAt, deadline |
| `PartyModel` | `party_model.dart` | id, name, logo, ideology, members |
| `RegionModel` | `region_model.dart` | id, name, country, coordinates, allowedElectionTypes |
| `VerificationModel` | `verification_model.dart` | userId, faceScore, livenessScore, idVerified, ageVerified, status |
| `WalletModel` | `wallet_model.dart` | address, balanceUSDT, balanceUSDC, balanceBTC, connectedAt |

Repository interfaces in `app/domain/repositories/`: `auth_repository.dart`, `election_repository.dart`, `vote_repository.dart`, `candidate_repository.dart`, `forum_repository.dart`, `region_repository.dart`, `verification_repository.dart`, `wallet_repository.dart`, `analytics_repository.dart`.

---

## 9. Theme / Design System

**File**: `lib/theme/theme.dart` — `TAppTheme`

- `lightTheme` / `darkTheme` using Material 3
- Sub-themes in `theme/custom_themes/`: `app_bar_theme`, `bottom_sheet_theme`, `check_box_theme`, `chip_theme`, `elevated_button_theme`, `outlined_button_theme`, `text_field_theme`, `text_theme`

Color constants: `core/constants/colors.dart` — `TColors` (primary palette, surface variants, semantic colors).  
Icons: `iconsax` package — mapped in `core/constants/icons.dart`.  
Typography: `google_fonts` package.

---

## 10. Key Dependencies

| Package | Version | Purpose |
|---|---|---|
| `flutter_riverpod` | ^2.6.1 | State management |
| `go_router` | ^16.0.0 | Navigation + deep links |
| `dio` | ^5.8.0 | HTTP client |
| `firebase_core` | ^3.10.1 | Firebase bootstrap |
| `firebase_auth` | ^5.4.4 | Authentication |
| `firebase_messaging` | ^15.2.10 | Push notifications |
| `flutter_face_api` | ^7.1.298 | Face recognition + liveness |
| `local_auth` | ^2.3.0 | Biometric (fingerprint/face) |
| `web3dart` | ^2.7.0 | Ethereum JSON-RPC, contract calls |
| `walletconnect_dart` | ^0.0.11 | WalletConnect session |
| `socket_io_client` | ^3.1.4 | Real-time WebSocket |
| `hive_flutter` | ^1.1.0 | Local cache |
| `flutter_secure_storage` | ^9.2.4 | Encrypted token storage |
| `get_storage` | ^2.1.1 | Key-value preferences |
| `get_it` | ^8.0.3 | Dependency injection |
| `fl_chart` | ^1.0.0 | Charts (election results, analytics) |
| `syncfusion_flutter_charts` | ^30.1.41 | Advanced chart widgets |
| `camera` | ^0.11.2 | Camera access for face/ID scans |
| `image_picker` | ^1.1.2 | Gallery/camera image picker |
| `file_picker` | ^10.2.0 | Document upload |
| `permission_handler` | ^12.0.1 | Runtime permissions |
| `flutter_animate` | ^4.5.2 | Animation helpers |
| `shimmer` | ^3.0.0 | Skeleton loading shimmer |
| `cached_network_image` | ^3.2.1 | Image caching |
| `smooth_page_indicator` | ^1.2.0 | Onboarding page dots |
| `connectivity_plus` | ^6.1.1 | Network state detection |
| `flutter_dotenv` | ^6.0.0 | .env config loading |
| `google_fonts` | ^8.0.2 | Typography |
| `iconsax` | ^0.0.8 | Icon library |
| `intl` | ^0.20.2 | Date/number formatting |
| `logger` | ^2.5.0 | Structured debug logging |
| `freezed_annotation` | ^3.1.0 | Immutable model codegen (wired) |
| `json_serializable` | ^6.10.0 | JSON serialisation codegen (wired) |

---

## 11. Assets

```
assets/
├── images/         # General UI images
├── fonts/          # Custom typefaces
├── icons/          # Custom icon assets
├── logo/
│   ├── emblem_launcher_android.png   # Android adaptive icon foreground
│   └── emblem_launcher_ios.png       # iOS launcher icon
└── translations/   # (reserved for i18n)
```

App name: **VoteSecure**  
Android adaptive background: `#F8F7F4`  
iOS background: `#F8F7F4`

---

## 12. Build Status

| Layer | Status |
|---|---|
| App scaffold + routing | Done |
| Theme (light/dark, Material 3) | Done |
| `ThemeModeNotifier` | Done |
| `ApiClient` (Dio + interceptors) | Done |
| `StorageService` (secure + local) | Done |
| `HiveService` (TTL cache) | Done |
| `WebSocketService` (Socket.IO) | Done |
| `NotificationService` (FCM) | Done |
| Screen files (all routes scaffolded) | Done |
| Domain models | TODO stubs |
| Riverpod providers (11 of 12) | TODO stubs |
| GetIt DI registrations | TODO |
| Repository implementations | TODO |
| Use case implementations | TODO |
| Blockchain / web3dart integration | TODO |
| AI identity verification flows | TODO |
