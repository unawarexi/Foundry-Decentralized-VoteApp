import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_frontend_vote/core/constants/colors.dart';
import 'package:flutter_frontend_vote/core/utils/validators.dart';
import 'package:flutter_frontend_vote/core/utils/helper_functions.dart';
import 'package:flutter_frontend_vote/core/constants/sizes.dart';
import 'package:flutter_frontend_vote/core/constants/responsive.dart';
import 'package:flutter_frontend_vote/app/components/shapes/decorative_painters.dart';
import 'package:flutter_frontend_vote/app/features/auth/presentation/widgets/auth_widgets.dart';
import 'package:flutter_frontend_vote/core/animations/screen_animations.dart';

/// VoteSecure Login Screen
/// Pattern: "Modern infrastructure with institutional weight"
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  // ── Form ─────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  // ── Focus nodes ───────────────────────────────────────────
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  // ── Orchestrator ──────────────────────────────────────────
  late final LoginOrchestrator _orchestrator;

  // Field focus state
  bool _emailFocused = false;
  bool _passwordFocused = false;

  @override
  void initState() {
    super.initState();
    _orchestrator = LoginOrchestrator(vsync: this);
    _runEntrance();

    _emailFocus.addListener(
      () => setState(() => _emailFocused = _emailFocus.hasFocus),
    );
    _passwordFocus.addListener(
      () => setState(() => _passwordFocused = _passwordFocus.hasFocus),
    );
  }

  Future<void> _runEntrance() async {
    await Future.delayed(const Duration(milliseconds: 80));
    _orchestrator.forward();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    // Simulate network call
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isLoading = false);
    if (mounted) {
      context.go('/home');
    }
  }

  @override
  void dispose() {
    _orchestrator.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

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
    return Scaffold(
      backgroundColor: isDark
          ? TColors.darkBackground
          : TColors.lightBackground,
      resizeToAvoidBottomInset: true,
      body: AnimatedBuilder(
        animation: _orchestrator.entranceController,
        builder: (context, _) {
          return Stack(
            children: [
              // --- Gold Patterned Background ---
              CustomPaint(
                size: MediaQuery.sizeOf(context),
                painter: AuthGridPainter(
                  color: TColors.secondary.withOpacity(isDark ? 0.10 : 0.13),
                ),
              ),
              if (isDark)
                Container(
                  width: MediaQuery.sizeOf(context).width,
                  height: MediaQuery.sizeOf(context).height,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        TColors.darkBackground.withOpacity(0.92),
                        Colors.transparent,
                        TColors.secondary.withOpacity(0.10),
                        Colors.transparent,
                        TColors.darkBackground.withOpacity(0.85),
                      ],
                      stops: const [0.0, 0.18, 0.5, 0.82, 1.0],
                    ),
                  ),
                ),
              _buildCornerAccent(),
              _buildShimmer(context),

              SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight:
                          MediaQuery.sizeOf(context).height -
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
                          _buildForm(),
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

  Widget _buildCornerAccent() {
    return Positioned(
      top: -60,
      right: -60,
      child: Opacity(
        opacity: (0.07 * _orchestrator.logoAnim.value).clamp(0.0, 1.0),
        child: CustomPaint(
          size: const Size(220, 220),
          painter: HexRingPainter(),
        ),
      ),
    );
  }

  Widget _buildShimmer(BuildContext context) {
    return AnimatedBuilder(
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
    );
  }

  Widget _buildTopBar(bool isDark) {
    return FadeTransition(
      opacity: _orchestrator.logoAnim,
      child: Row(
        children: [
          SizedBox(
            width: 32,
            height: 32,
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

  Widget _buildHeader(bool isDark) {
    return FadeTransition(
      opacity: _orchestrator.headerAnim,
      child: SlideTransition(
        position: _orchestrator.headerSlide,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AuthAccentTag(label: 'SECURE SESSION'),
            const SizedBox(height: 18),
            Text(
              'Welcome\nBack.',
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
              'Your identity is verified. Your vote is private.',
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

  Widget _buildForm() {
    return FadeTransition(
      opacity: _orchestrator.formAnim,
      child: SlideTransition(
        position: _orchestrator.formSlide,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              VSTextField(
                controller: _emailController,
                focusNode: _emailFocus,
                label: 'Email Address',
                hint: 'registered@email.com',
                isFocused: _emailFocused,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: FieldIcon(
                  icon: Icons.alternate_email,
                  active: _emailFocused,
                ),
                validator: validateEmail,
              ),
              const SizedBox(height: 20),
              VSTextField(
                controller: _passwordController,
                focusNode: _passwordFocus,
                label: 'Password',
                hint: '••••••••••••',
                isFocused: _passwordFocused,
                obscureText: _obscurePassword,
                prefixIcon: FieldIcon(
                  icon: Icons.lock_outline_rounded,
                  active: _passwordFocused,
                ),
                suffixIcon: GestureDetector(
                  onTap: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  child: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: _passwordFocused
                        ? TColors.secondary
                        : TColors.textDarkTertiary,
                    size: 18,
                  ),
                ),
                validator: validatePassword,
              ),
              const SizedBox(height: TSizes.sm),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {},
                  child: const Text(
                    'Forgot password?',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: TColors.secondary,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: TSizes.xl),
              _buildLoginButton(),
              const SizedBox(height: TSizes.lg),
              const AuthDivider(),
              const SizedBox(height: TSizes.lg),
              const WalletConnectButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return AnimatedBuilder(
      animation: _orchestrator.pulseAnim,
      builder: (_, __) => GestureDetector(
        onTap: _isLoading ? null : _handleLogin,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          height: 58,
          decoration: BoxDecoration(
            color: TColors.primary,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: TColors.secondary.withValues(
                alpha: (0.18 + 0.18 * _orchestrator.pulseAnim.value).clamp(
                  0.0,
                  1.0,
                ),
              ),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: TColors.primary.withValues(
                  alpha: (0.4 + 0.15 * _orchestrator.pulseAnim.value).clamp(
                    0.0,
                    1.0,
                  ),
                ),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: _isLoading
                ? const LoadingDots()
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Access Secure Vault',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: TColors.white,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(
                        Icons.shield_outlined,
                        color: TColors.white,
                        size: 17,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(bool isDark) {
    return FadeTransition(
      opacity: _orchestrator.footerAnim,
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SecurityBadge(label: 'ZK-PROOF'),
              SizedBox(width: 12),
              SecurityBadge(label: 'AES-256'),
              SizedBox(width: 12),
              SecurityBadge(label: 'BIOMETRIC'),
            ],
          ),
          const SizedBox(height: TSizes.sectionSpacing),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'No account? ',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: isDark
                      ? TColors.textDarkTertiary
                      : TColors.textLightTertiary,
                ),
              ),
              GestureDetector(
                onTap: () => context.push('/signup'),
                child: const Text(
                  'Register as Voter',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: TColors.secondary,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
