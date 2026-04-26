import 'package:flutter/material.dart';
import 'package:flutter_frontend_vote/app/components/nav/nav_placeholder_screen.dart';

class CandidatesScreen extends StatelessWidget {
  const CandidatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const NavPlaceholderScreen(
      title: 'Candidate Profiles',
      subtitle: 'Transparent auditing of candidate credentials and manifestos.',
      icon: Icons.people_outline_rounded,
    );
  }
}
