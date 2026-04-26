import 'package:flutter/material.dart';
import 'package:flutter_frontend_vote/app/components/nav/nav_placeholder_screen.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const NavPlaceholderScreen(
      title: 'Electoral Analytics',
      subtitle: 'Real-time data processing and transparency visualization.',
      icon: Icons.analytics_outlined,
    );
  }
}
