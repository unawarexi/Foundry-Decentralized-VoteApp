import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reown_appkit/reown_appkit.dart';
import 'package:flutter_frontend_vote/core/auth/wallet_service.dart';
import 'package:flutter_frontend_vote/store/auth_provider.dart';
import 'package:flutter_frontend_vote/core/constants/colors.dart';
import 'package:flutter_frontend_vote/core/constants/sizes.dart';
import 'package:flutter_frontend_vote/core/constants/responsive.dart';
import 'package:flutter_frontend_vote/core/utils/helper_functions.dart';
import 'package:flutter_frontend_vote/core/animations/screen_animations.dart';
import 'package:flutter_frontend_vote/app/components/shapes/decorative_painters.dart';
import 'package:flutter_frontend_vote/app/features/auth/presentation/widgets/auth_widgets.dart';

// ── Screen ──────────────────────────────────────────────────────────────────

class WalletConnectScreen extends ConsumerStatefulWidget {
  const WalletConnectScreen({super.key});

  @override
  ConsumerState<WalletConnectScreen> createState() =>
      _WalletConnectScreenState();
}

class _WalletConnectScreenState extends ConsumerState<WalletConnectScreen>
    with TickerProviderStateMixin {
  bool _isSigning = false;
  bool _initialized = false;
  String? _errorMessage;

  late final LoginOrchestrator _orchestrator;

  // ── Lifecycle ───────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _orchestrator = LoginOrchestrator(vsync: this);
    _runEntrance();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initAndOpen());
  }

  Future<void> _runEntrance() async {
    await Future.delayed(const Duration(milliseconds: 80));
    _orchestrator.forward();
  }

  @override
  void dispose() {
    _orchestrator.dispose();
    WalletService.instance.modal?.onModalDisconnect.unsubscribeAll();
    super.dispose();
  }

  // ── Init ────────────────────────────────────────────────────────────────────

  Future<void> _initAndOpen() async {
    try {
      await WalletService.instance.init(context);
      if (mounted) setState(() => _initialized = true);
      _attachListeners();
      await WalletService.instance.openModal();
    } catch (e) {
      if (mounted) setState(() => _errorMessage = e.toString());
    }
  }

  void _attachListeners() {
    final modal = WalletService.instance.modal;
    if (modal == null) return;
    modal.onModalConnect.subscribe((_) async {
      if (!mounted) return;
      await _handleWalletConnected();
    });
  }

  // ── Connect → sign → auth ──────────────────────────────────────────────────

  Future<void> _handleWalletConnected() async {
    if (_isSigning) return;
    setState(() {
      _isSigning = true;
      _errorMessage = null;
    });

    try {
      final (:message, :signature) =
          await WalletService.instance.requestSignature();
      final address = WalletService.instance.address!;

      await ref.read(currentUserProvider.notifier).signInWithWallet(
            walletAddress: address,
            signature: signature,
            message: message,
          );

      final authState = ref.read(currentUserProvider);
      if (authState.hasValue && authState.valueOrNull != null && mounted) {
        context.go('/home');
      } else if (authState.hasError && mounted) {
        setState(() {
          _errorMessage = authState.error.toString().contains('E4001') ||
                  authState.error.toString().contains('wallet not linked')
              ? 'No verified account is linked to this wallet.\n'
                  'Please sign up or link your wallet in Settings.'
              : 'Authentication failed. Please try again.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Signing failed: ${e.toString()}');
      }
    } finally {
      if (mounted) setState(() => _isSigning = false);
    }
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
    );

    ref.listen(currentUserProvider, (_, next) {
      if (next.hasValue && next.valueOrNull != null && mounted) {
        context.go('/home');
      }
    });

    return Scaffold(
      backgroundColor:
          isDark ? TColors.darkBackground : TColors.lightBackground,
      resizeToAvoidBottomInset: true,
      body: AnimatedBuilder(
        animation: _orchestrator.entranceController,
        builder: (context, _) {
          return Stack(
            children: [
              // ── Gold grid background (matches login) ──────────────────────
              CustomPaint(
                size: MediaQuery.sizeOf(context),
                painter: AuthGridPainter(
                  color:
                      TColors.secondary.withValues(alpha: isDark ? 0.10 : 0.13),
                ),
              ),

              // ── Dark mode gradient overlay ─────────────────────────────────
              if (isDark)
                Container(
                  width: MediaQuery.sizeOf(context).width,
                  height: MediaQuery.sizeOf(context).height,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        TColors.darkBackground.withValues(alpha: 0.92),
                        Colors.transparent,
                        TColors.secondary.withValues(alpha: 0.10),
                        Colors.transparent,
                        TColors.darkBackground.withValues(alpha: 0.85),
                      ],
                      stops: const [0.0, 0.18, 0.5, 0.82, 1.0],
                    ),
                  ),
                ),

              // ── Corner hex ring accent ─────────────────────────────────────
              Positioned(
                top: -60,
                right: -60,
                child: Opacity(
                  opacity:
                      (0.07 * _orchestrator.logoAnim.value).clamp(0.0, 1.0),
                  child: CustomPaint(
                    size: const Size(220, 220),
                    painter: HexRingPainter(),
                  ),
                ),
              ),

              // ── Horizontal shimmer sweep ───────────────────────────────────
              AnimatedBuilder(
                animation: _orchestrator.shimmerPos,
                builder: (_, __) => Positioned.fill(
                  child: IgnorePointer(
                    child: Transform.translate(
                      offset: Offset(
                        SResponsive.width(context) *
                            (_orchestrator.shimmerPos.value - 0.5) *
                            2,
                        0,
                      ),
                      child: Container(
                        width: 100,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              TColors.secondary.withValues(alpha: 0.05),
                              TColors.secondary.withValues(alpha: 0.09),
                              TColors.secondary.withValues(alpha: 0.05),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ── Main scrollable content ────────────────────────────────────
              SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.sizeOf(context).height -
                          MediaQuery.paddingOf(context).top -
                          MediaQuery.paddingOf(context).bottom,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: TSizes.lg),
                          _buildTopBar(isDark),
                          const SizedBox(height: 40),
                          _buildHeader(isDark),
                          const SizedBox(height: 40),
                          _buildBody(isDark),
                          const Spacer(),
                          const SizedBox(height: TSizes.xl),
                          _buildFooter(isDark),
                          const SizedBox(height: TSizes.xl),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Top bar ────────────────────────────────────────────────────────────────

  Widget _buildTopBar(bool isDark) {
    return FadeTransition(
      opacity: _orchestrator.logoAnim,
      child: Row(
        children: [
          // Back chevron
          GestureDetector(
            onTap: () => context.pop(),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: isDark ? TColors.textDarkSecondary : TColors.textLightSecondary,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 28,
            height: 28,
            child: CustomPaint(painter: MiniLogoPainter()),
          ),
          const SizedBox(width: 10),
          Text(
            'VOTESECURE',
            style: TextStyle(
              fontFamily: 'IBMPlexSerif',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isDark ? TColors.white : TColors.primary,
              letterSpacing: 2.5,
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(bool isDark) {
    return FadeTransition(
      opacity: _orchestrator.headerAnim,
      child: SlideTransition(
        position: _orchestrator.headerSlide,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AuthAccentTag(label: 'WALLET AUTH'),
            const SizedBox(height: 18),
            Text(
              'Connect\nWallet.',
              style: TextStyle(
                fontFamily: 'IBMPlexSerif',
                fontSize: 40,
                fontWeight: FontWeight.w700,
                color: isDark ? TColors.white : TColors.primary,
                height: 1.1,
              ),
            ),
            const SizedBox(height: TSizes.md),
            Container(width: 40, height: 2, color: TColors.secondary),
            const SizedBox(height: 14),
            Text(
              'WalletConnect v2 auto-detects all\nwallets installed on your device.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: isDark
                    ? TColors.textDarkSecondary
                    : TColors.textLightSecondary,
                height: 1.5,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Body (connect button + states) ─────────────────────────────────────────

  Widget _buildBody(bool isDark) {
    return FadeTransition(
      opacity: _orchestrator.formAnim,
      child: SlideTransition(
        position: _orchestrator.formSlide,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Error banner
            if (_errorMessage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: TColors.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(TSizes.radiusSm),
                  border: Border.all(
                    color: TColors.error.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        color: TColors.error, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: TColors.error,
                          height: 1.4,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _errorMessage = null),
                      child: const Icon(Icons.close,
                          color: TColors.error, size: 16),
                    ),
                  ],
                ),
              ),

            // Signing status
            if (_isSigning) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: TColors.secondary,
                      strokeWidth: 2,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Sign the message in your wallet…',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: isDark
                          ? TColors.textDarkSecondary
                          : TColors.textLightSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],

            // Primary connect button
            AnimatedBuilder(
              animation: _orchestrator.pulseAnim,
              builder: (_, __) {
                if (!_initialized) {
                  return Container(
                    height: 58,
                    decoration: BoxDecoration(
                      color: TColors.primary,
                      borderRadius: BorderRadius.circular(TSizes.radiusSm),
                      border: Border.all(
                        color: TColors.secondary.withValues(
                          alpha: (0.18 +
                                  0.18 * _orchestrator.pulseAnim.value)
                              .clamp(0.0, 1.0),
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: TColors.primary.withValues(
                            alpha: (0.4 +
                                    0.15 * _orchestrator.pulseAnim.value)
                                .clamp(0.0, 1.0),
                          ),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Center(child: LoadingDots()),
                  );
                }
                return AppKitModalConnectButton(
                  appKit: WalletService.instance.modal!,
                );
              },
            ),
            const SizedBox(height: TSizes.lg),

            // QR fallback
            const AuthDivider(),
            const SizedBox(height: TSizes.lg),
            GestureDetector(
              onTap: () async {
                setState(() => _errorMessage = null);
                try {
                  await WalletService.instance.openModal();
                } catch (e) {
                  if (mounted) setState(() => _errorMessage = e.toString());
                }
              },
              child: Container(
                height: TSizes.inputHeight,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(TSizes.radiusSm),
                  border: Border.all(
                    color: isDark ? TColors.darkBorder : TColors.lightBorder,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.qr_code_rounded,
                      size: 18,
                      color: isDark
                          ? TColors.textDarkSecondary
                          : TColors.textLightSecondary,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Open wallet picker / scan QR',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? TColors.textDarkSecondary
                            : TColors.textLightSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Footer ─────────────────────────────────────────────────────────────────

  Widget _buildFooter(bool isDark) {
    return FadeTransition(
      opacity: _orchestrator.footerAnim,
      child: const Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SecurityBadge(label: 'SIWE'),
              SizedBox(width: 12),
              SecurityBadge(label: 'WC-V2'),
              SizedBox(width: 12),
              SecurityBadge(label: 'NON-CUSTODIAL'),
            ],
          ),
        ],
      ),
    );
  }
}

