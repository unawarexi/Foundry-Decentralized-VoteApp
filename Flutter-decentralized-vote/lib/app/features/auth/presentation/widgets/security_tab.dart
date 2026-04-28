import 'package:flutter/material.dart';
import 'package:flutter_frontend_vote/core/constants/colors.dart';
import 'package:flutter_frontend_vote/core/constants/sizes.dart';
import 'auth_widgets.dart';

/// Tab for Security & Official Documents
class SecurityTab extends StatelessWidget {
  final bool isDark;
  final TextEditingController idController;
  final String? voterId;
  final VoidCallback onCapturePassport;
  final bool hasPassport;

  const SecurityTab({
    super.key,
    required this.isDark,
    required this.idController,
    this.voterId,
    required this.onCapturePassport,
    this.hasPassport = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SecurityBadge(label: 'ENCRYPTED DATA STORAGE'),
        const SizedBox(height: 24),
        
        // Auto-generated Voter ID
        Text(
          'VOTER ID (SYSTEM GENERATED)',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isDark ? TColors.textDarkTertiary : TColors.textLightTertiary,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: isDark ? TColors.darkCard.withValues(alpha: 0.5) : TColors.lightCard,
            borderRadius: BorderRadius.circular(TSizes.radiusSm),
            border: Border.all(
              color: TColors.secondary.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.qr_code_2_rounded, color: TColors.secondary, size: 20),
              const SizedBox(width: 12),
              Text(
                voterId ?? 'PENDING GENERATION',
                style: TextStyle(
                  fontFamily: 'IBM Plex Mono',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isDark ? TColors.white : TColors.primary,
                  letterSpacing: 1.5,
                ),
              ),
              const Spacer(),
              const Icon(Icons.info_outline, color: TColors.secondary, size: 16),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        VSTextField(
          controller: idController,
          focusNode: FocusNode(),
          label: 'NIN / SSN / National ID',
          hint: 'Enter your unique identity number',
          isFocused: false,
          prefixIcon: const Icon(Icons.badge_outlined, size: 18),
        ),
        
        const SizedBox(height: 28),
        
        // Passport Capture UI
        Text(
          'BIOMETRIC PASSPORT CAPTURE',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isDark ? TColors.textDarkTertiary : TColors.textLightTertiary,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: onCapturePassport,
          child: Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: isDark ? TColors.darkCard : TColors.lightCard,
              borderRadius: BorderRadius.circular(TSizes.radiusSm),
              border: Border.all(
                color: hasPassport ? TColors.success : TColors.secondary.withValues(alpha: 0.3),
                style: BorderStyle.solid,
                width: hasPassport ? 2 : 1,
              ),
            ),
            child: hasPassport 
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(TSizes.radiusSm),
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.1),
                        child: const Icon(Icons.check_circle_outline_rounded, color: TColors.success, size: 48),
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: TColors.darkCard,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.refresh, color: Colors.white, size: 12),
                            SizedBox(width: 4),
                            Text('Retake', style: TextStyle(color: Colors.white, fontSize: 10)),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt_outlined, size: 40, color: TColors.secondary),
                    const SizedBox(height: 12),
                    const Text(
                      'Capture Official ID',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Hold passport/ID in front of camera',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: isDark ? TColors.textDarkTertiary : TColors.textLightTertiary,
                      ),
                    ),
                  ],
                ),
          ),
        ),
      ],
    );
  }
}
