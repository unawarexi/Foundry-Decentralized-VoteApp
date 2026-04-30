import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_frontend_vote/core/constants/colors.dart';
import 'package:flutter_frontend_vote/core/utils/helper_functions.dart';
import 'package:flutter_frontend_vote/core/constants/sizes.dart';
import 'package:flutter_frontend_vote/core/constants/responsive.dart';
import 'package:flutter_frontend_vote/app/components/shapes/decorative_painters.dart';
import 'package:flutter_frontend_vote/app/features/auth/presentation/widgets/auth_widgets.dart';
import 'package:flutter_frontend_vote/core/animations/screen_animations.dart';

// Tabs
import 'package:flutter_frontend_vote/app/features/auth/presentation/widgets/personal_tab.dart';
import 'package:flutter_frontend_vote/app/features/auth/presentation/widgets/security_tab.dart';
import 'package:flutter_frontend_vote/app/features/auth/presentation/widgets/candidate_tab.dart';
import 'package:flutter_frontend_vote/app/features/auth/presentation/widgets/verify_tab.dart';

class CandidateSignUpScreen extends StatefulWidget {
  const CandidateSignUpScreen({super.key});

  @override
  State<CandidateSignUpScreen> createState() => _CandidateSignUpScreenState();
}

class _CandidateSignUpScreenState extends State<CandidateSignUpScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Controllers (Reusable from Voter)
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _dobController = TextEditingController();
  final _occupationController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _idNumberController = TextEditingController();

  // New Leadership Controllers
  final _roleNameController = TextEditingController();
  final _rolePurposeController = TextEditingController();
  final _partyNameController = TextEditingController();
  final _achievementsController = TextEditingController();
  final _careerJourneyController = TextEditingController();
  final _biographyController = TextEditingController();
  String? _selectedRoleCategory;

  // Selection State
  String? _selectedMaritalStatus;
  String? _selectedGender;
  String? _selectedFamilyRole;
  String? _selectedCountry;
  String? _selectedState;
  String? _selectedLGA;
  String? _voterId = 'CAN-7721-NG-091'; // Candidate prefix
  bool _hasPassport = false;
  bool _isVerifying = false;
  bool _isVerified = false;

  // Candidate Specific State
  bool _hasManifesto = false;
  bool _hasVideoIntro = false;
  bool _hasQualifications = false;
  bool _hasPictures = false;

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  bool _agreedToTerms = false;

  int _step = 0;

  late final SignUpOrchestrator _orchestrator;

  @override
  void initState() {
    super.initState();

    _orchestrator = SignUpOrchestrator(vsync: this);
    _runEntrance();
  }

  Future<void> _runEntrance() async {
    await Future.delayed(const Duration(milliseconds: 80));
    _orchestrator.forward();
  }

  void _nextStep() {
    if (_step < 3) {
      setState(() => _step++);
    } else {
      _handleSubmit();
    }
  }

  void _prevStep() {
    if (_step > 0) {
      setState(() => _step--);
    } else {
      context.go('/option');
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isLoading = false);
    if (mounted) {
      context.go('/home');
    }
  }

  @override
  void dispose() {
    _orchestrator.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _occupationController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _idNumberController.dispose();
    _roleNameController.dispose();
    _rolePurposeController.dispose();
    _partyNameController.dispose();
    _achievementsController.dispose();
    _careerJourneyController.dispose();
    _biographyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);
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
              _buildBackground(isDark),
              Opacity(
                opacity: 0.04,
                child: CustomPaint(
                  size: MediaQuery.sizeOf(context),
                  painter: AuthGridPainter(color: TColors.secondary),
                ),
              ),
              _buildCornerAccent(),
              _buildShimmer(context),
              SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: TSizes.lg),
                      _buildTopBar(isDark),
                      const SizedBox(height: 36),
                      _buildHeader(isDark),
                      const SizedBox(height: 28),
                      _buildStepIndicator(isDark),
                      const SizedBox(height: 24),
                      _buildForm(isDark),
                      const SizedBox(height: 12),
                      _buildSubmitButton(),
                      const SizedBox(height: TSizes.lg),
                      _buildFooter(isDark),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBackground(bool isDark) {
    return AnimatedBuilder(
      animation: _orchestrator.bgAnim,
      builder: (_, __) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color.lerp(
                isDark ? TColors.darkBackground : TColors.lightBackground,
                isDark ? const Color(0xFF100E06) : const Color(0xFFFFFDE7),
                _orchestrator.bgAnim.value,
              )!,
              isDark ? TColors.darkBackground : TColors.lightBackground,
              Color.lerp(
                isDark ? TColors.darkBackground : TColors.lightBackground,
                isDark ? const Color(0xFF0B1A12) : const Color(0xFFE8F5E9),
                _orchestrator.bgAnim.value,
              )!,
            ],
            stops: const [0.0, 0.45, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildCornerAccent() {
    return Positioned(
      bottom: -80,
      left: -80,
      child: Opacity(
        opacity: (0.06 * _orchestrator.logoAnim.value).clamp(0.0, 1.0),
        child: CustomPaint(
          size: const Size(260, 260),
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
                    TColors.secondary.withValues(alpha: 0.04),
                    TColors.secondary.withValues(alpha: 0.08),
                    TColors.secondary.withValues(alpha: 0.04),
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
          GestureDetector(
            onTap: _prevStep,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                border: Border.all(
                  color: isDark ? TColors.darkBorder : TColors.lightBorder,
                ),
                borderRadius: BorderRadius.circular(TSizes.radiusSm),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: TColors.secondary,
                size: 14,
              ),
            ),
          ),
          const SizedBox(width: 14),
          SizedBox(
            width: 28,
            height: 28,
            child: CustomPaint(painter: MiniLogoPainter()),
          ),
          const SizedBox(width: 8),
          Text(
            'VOTESECURE',
            style: TextStyle(
              fontFamily: 'IBMPlexSerif',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isDark ? TColors.white : TColors.primary,
              letterSpacing: 3,
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
            const AuthAccentTag(label: 'CANDIDATE REGISTRATION'),
            const SizedBox(height: 18),
            Text(
              'Leadership\nApplication.',
              style: TextStyle(
                fontFamily: 'IBMPlexSerif',
                fontSize: 38,
                fontWeight: FontWeight.w700,
                color: isDark ? TColors.white : TColors.primary,
                height: 1.12,
              ),
            ),
            const SizedBox(height: TSizes.md),
            Container(width: 40, height: 2, color: TColors.secondary),
            const SizedBox(height: 14),
            Text(
              'Provide your qualifications and manifesto for transparency and immutable record keeping.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: isDark
                    ? TColors.textDarkSecondary
                    : TColors.textLightSecondary,
                height: 1.65,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator(bool isDark) {
    final steps = ['Personal', 'Security', 'Candidate', 'Verify'];
    return FadeTransition(
      opacity: _orchestrator.stepAnim,
      child: SlideTransition(
        position: _orchestrator.stepSlide,
        child: Row(
          children: List.generate(steps.length, (i) {
            final isActive = i == _step;
            final isDone = i < _step;
            return Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _step = i),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isDone
                                      ? TColors.secondary
                                      : (isActive
                                            ? TColors.primary
                                            : Colors.transparent),
                                  border: Border.all(
                                    color: isActive || isDone
                                        ? TColors.secondary
                                        : (isDark
                                              ? TColors.darkBorder
                                              : TColors.lightBorder),
                                    width: 1.5,
                                  ),
                                ),
                                child: Center(
                                  child: isDone
                                      ? Icon(
                                          Icons.check,
                                          color: isDark
                                              ? TColors.darkBackground
                                              : TColors.lightBackground,
                                          size: 11,
                                        )
                                      : Text(
                                          '${i + 1}',
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: isActive
                                                ? TColors.white
                                                : (isDark
                                                      ? TColors.textDarkTertiary
                                                      : TColors
                                                            .textLightTertiary),
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  steps[i],
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 10,
                                    color: isActive || isDone
                                        ? TColors.secondary
                                        : (isDark
                                              ? TColors.textDarkTertiary
                                              : TColors.textLightTertiary),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            height: 2,
                            decoration: BoxDecoration(
                              color: isDone || isActive
                                  ? TColors.secondary
                                  : (isDark
                                        ? TColors.darkBorder
                                        : TColors.lightBorder),
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (i < steps.length - 1) const SizedBox(width: 8),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildForm(bool isDark) {
    return FadeTransition(
      opacity: _orchestrator.formAnim,
      child: SlideTransition(
        position: _orchestrator.formSlide,
        child: Form(
          key: _formKey,
          child: AnimatedSize(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _buildTab(_step, isDark),
          ),
        ),
      ),
    );
  }

  Widget _buildTab(int index, bool isDark) {
    switch (index) {
      case 0:
        return PersonalTab(
          isDark: isDark,
          nameController: _nameController,
          emailController: _emailController,
          dobController: _dobController,
          occupationController: _occupationController,
          addressController: _addressController,
          passwordController: _passwordController,
          confirmController: _confirmController,
          obscurePassword: _obscurePassword,
          obscureConfirm: _obscureConfirm,
          onTogglePassword: () =>
              setState(() => _obscurePassword = !_obscurePassword),
          onToggleConfirm: () =>
              setState(() => _obscureConfirm = !_obscureConfirm),
          onMaritalStatusChanged: (v) =>
              setState(() => _selectedMaritalStatus = v),
          onGenderChanged: (v) => setState(() => _selectedGender = v),
          onFamilyRoleChanged: (v) => setState(() => _selectedFamilyRole = v),
          onCountryChanged: (v) => setState(() => _selectedCountry = v),
          onStateChanged: (v) => setState(() => _selectedState = v),
          onLGAChanged: (v) => setState(() => _selectedLGA = v),
        );
      case 1:
        return SecurityTab(
          isDark: isDark,
          idController: _idNumberController,
          voterId: _voterId,
          hasPassport: _hasPassport,
          onCapturePassport: () => setState(() => _hasPassport = true),
        );
      case 2:
        return CandidateTab(
          isDark: isDark,
          roleNameController: _roleNameController,
          rolePurposeController: _rolePurposeController,
          partyNameController: _partyNameController,
          achievementsController: _achievementsController,
          careerJourneyController: _careerJourneyController,
          biographyController: _biographyController,
          selectedRole: _selectedRoleCategory,
          onRoleChanged: (v) => setState(() => _selectedRoleCategory = v),
          hasManifesto: _hasManifesto,
          hasVideoIntro: _hasVideoIntro,
          hasQualifications: _hasQualifications,
          hasPictures: _hasPictures,
          onUploadManifesto: () => setState(() => _hasManifesto = true),
          onUploadVideo: () => setState(() => _hasVideoIntro = true),
          onUploadQualifications: () =>
              setState(() => _hasQualifications = true),
          onUploadPictures: () => setState(() => _hasPictures = true),
        );
      case 3:
        return Column(
          children: [
            VerifyTab(
              isDark: isDark,
              isVerifying: _isVerifying,
              isVerified: _isVerified,
              onStartLiveness: () async {
                setState(() => _isVerifying = true);
                await Future.delayed(const Duration(seconds: 3));
                setState(() {
                  _isVerifying = false;
                  _isVerified = true;
                });
              },
            ),
            const SizedBox(height: 28),
            _buildTermsCheckbox(isDark),
          ],
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildTermsCheckbox(bool isDark) {
    return GestureDetector(
      onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: _agreedToTerms
                  ? TColors.secondary.withOpacity(0.15)
                  : Colors.transparent,
              border: Border.all(
                color: _agreedToTerms
                    ? TColors.secondary
                    : (isDark ? TColors.darkBorder : TColors.lightBorder),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: _agreedToTerms
                ? const Icon(Icons.check, color: TColors.secondary, size: 13)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: isDark
                      ? TColors.textDarkSecondary
                      : TColors.textLightSecondary,
                  height: 1.5,
                ),
                children: [
                  const TextSpan(text: 'I agree to the VoteSecure '),
                  TextSpan(
                    text: 'Terms of Civic Use',
                    style: TextStyle(color: TColors.secondary),
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Charter',
                    style: TextStyle(color: TColors.secondary),
                  ),
                  const TextSpan(
                    text:
                        '. My data is protected under Zero-Knowledge standards.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    final isDark = THelperFunctions.isDarkMode(context);
    final isLast = _step == 3;
    final isFirst = _step == 0;
    return FadeTransition(
      opacity: _orchestrator.formAnim,
      child: Row(
        children: [
          if (!isFirst) ...[
            GestureDetector(
              onTap: _prevStep,
              child: Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: TColors.secondary.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: TColors.secondary,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: AnimatedBuilder(
              animation: _orchestrator.bgPulseController,
              builder: (_, __) => GestureDetector(
                onTap: _isLoading ? null : (isLast ? _handleSubmit : _nextStep),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 58,
                  decoration: BoxDecoration(
                    color: (isLast && !_agreedToTerms)
                        ? TColors.darkCard
                        : TColors.accent,
                    borderRadius: BorderRadius.circular(TSizes.radiusMd),
                    border: Border.all(
                      color: TColors.accent.withValues(
                        alpha:
                            (0.5 + 0.2 * _orchestrator.bgPulseController.value)
                                .clamp(0.0, 1.0),
                      ),
                      width: 1,
                    ),
                    boxShadow: (isLast && _agreedToTerms) || !isLast
                        ? [
                            BoxShadow(
                              color: TColors.accent.withValues(
                                alpha:
                                    (0.3 +
                                            0.15 *
                                                _orchestrator
                                                    .bgPulseController
                                                    .value)
                                        .clamp(0.0, 1.0),
                              ),
                              blurRadius: 22,
                              offset: const Offset(0, 8),
                            ),
                          ]
                        : [],
                  ),
                  child: Center(
                    child: _isLoading
                        ? const LoadingDots()
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  isLast
                                      ? 'Submit Application'
                                      : 'Continue to Next Phase',
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: TColors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Icon(
                                isLast
                                    ? Icons.how_to_reg
                                    : Icons.arrow_forward_rounded,
                                color: TColors.white,
                                size: 17,
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(bool isDark) {
    return FadeTransition(
      opacity: _orchestrator.footerAnim,
      child: Column(
        children: [
          const AuthDivider(),
          const SizedBox(height: TSizes.lg),
          const WalletConnectButton(),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Already registered? ',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: isDark
                      ? TColors.textDarkTertiary
                      : TColors.textLightTertiary,
                ),
              ),
              GestureDetector(
                onTap: () => context.goNamed('login'),
                child: const Text(
                  'Sign In',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: TColors.secondary,
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
