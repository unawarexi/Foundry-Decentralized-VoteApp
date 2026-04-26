import 'package:flutter/material.dart';
import 'package:flutter_frontend_vote/app/components/nav/nav_placeholder_screen.dart';

class VerifyScreen extends StatelessWidget {
  const VerifyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const NavPlaceholderScreen(
      title: 'Identity Verification',
      subtitle: 'Multi-factor biometric and cryptographic validation.',
      icon: Icons.verified_user_outlined,
    );
  }
}