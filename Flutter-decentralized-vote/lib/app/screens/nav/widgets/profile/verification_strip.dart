import 'package:flutter/material.dart';
import 'verify_chip.dart';

class VerificationStrip extends StatelessWidget {
  final Animation<double> verifyFade;
  final Animation<Offset> verifySlide;
  final Animation<double> pulseAnim;

  const VerificationStrip({
    super.key,
    required this.verifyFade,
    required this.verifySlide,
    required this.pulseAnim,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: verifyFade,
      child: SlideTransition(
        position: verifySlide,
        child: Row(
          children: [
            Expanded(
              child: VerifyChip(
                icon: Icons.fingerprint,
                label: 'Biometric',
                status: 'Verified',
                active: true,
                pulseAnim: pulseAnim,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: VerifyChip(
                icon: Icons.shield_outlined,
                label: 'ZK Proof',
                status: 'Active',
                active: true,
                pulseAnim: pulseAnim,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: VerifyChip(
                icon: Icons.account_balance_wallet_outlined,
                label: 'Wallet',
                status: 'Linked',
                active: true,
                pulseAnim: pulseAnim,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: VerifyChip(
                icon: Icons.location_on_outlined,
                label: 'Region',
                status: 'Locked',
                active: true,
                pulseAnim: pulseAnim,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
