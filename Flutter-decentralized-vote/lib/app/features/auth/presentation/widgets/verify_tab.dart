import 'package:flutter/material.dart';
import 'package:flutter_frontend_vote/core/constants/colors.dart';
import 'package:flutter_frontend_vote/core/constants/sizes.dart';
import 'auth_widgets.dart';

/// Tab for AI Liveness & Face Verification
class VerifyTab extends StatelessWidget {
  final bool isDark;
  final bool isVerifying;
  final bool isVerified;
  final VoidCallback onStartLiveness;

  const VerifyTab({
    super.key,
    required this.isDark,
    this.isVerifying = false,
    this.isVerified = false,
    required this.onStartLiveness,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: AuthAccentTag(label: 'AI IDENTITY VALIDATION'),
        ),
        const SizedBox(height: 32),
        
        // Face Scan Circle UI
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer Ring
              Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isVerified ? TColors.success : TColors.secondary.withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
              ),
              
              // Scanning Animation / Face Placeholder
              Container(
                width: 190,
                height: 190,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? TColors.darkCard : TColors.lightCard,
                  image: const DecorationImage(
                    image: AssetImage('assets/images/face_id_placeholder.png'), // Placeholder
                    opacity: 0.1,
                  ),
                ),
                child: isVerifying 
                  ? const Center(child: CircularProgressIndicator(color: TColors.secondary, strokeWidth: 2))
                  : isVerified 
                    ? const Icon(Icons.verified_user_rounded, color: TColors.success, size: 64)
                    : const Icon(Icons.face_unlock_rounded, color: TColors.secondary, size: 64),
              ),
              
              // Scanning Line (if verifying)
              if (isVerifying)
                const _ScanningLine(),
            ],
          ),
        ),
        
        const SizedBox(height: 40),
        
        Text(
          isVerified ? 'AI IDENTIFICATION SUCCESSFUL' : 'LIVENESS DETECTION REQUIRED',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'IBMPlexSerif',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isVerified ? TColors.success : (isDark ? TColors.white : TColors.primary),
            letterSpacing: 0.5,
          ),
        ),
        
        const SizedBox(height: 12),
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            isVerified 
              ? 'Your biometric profile matches your government records. Access is authorized.'
              : 'Our AI engine requires a 3D liveness check to prevent spoofing and ensure one-person-one-vote integrity.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: isDark ? TColors.textDarkSecondary : TColors.textLightSecondary,
              height: 1.5,
            ),
          ),
        ),
        
        const SizedBox(height: 48),
        
        if (!isVerified)
          GestureDetector(
            onTap: onStartLiveness,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: isVerifying ? Colors.transparent : TColors.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(TSizes.radiusSm),
                border: Border.all(color: TColors.secondary, width: 1),
              ),
              child: Center(
                child: Text(
                  isVerifying ? 'Scanning Biometrics...' : 'START LIVENESS CHECK',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: TColors.secondary,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ScanningLine extends StatefulWidget {
  const _ScanningLine();

  @override
  State<_ScanningLine> createState() => _ScanningLineState();
}

class _ScanningLineState extends State<_ScanningLine>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        return Positioned(
          top: 30 + (160 * _ctrl.value),
          child: Container(
            width: 180,
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  TColors.secondary.withValues(alpha: 0),
                  TColors.secondary,
                  TColors.secondary.withValues(alpha: 0),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: TColors.secondary.withValues(alpha: 0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
