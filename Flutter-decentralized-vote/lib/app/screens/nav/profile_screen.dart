import 'package:flutter/material.dart';
import 'package:flutter_frontend_vote/app/components/nav/nav_placeholder_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const NavPlaceholderScreen(
      title: 'Citizen Profile',
      subtitle: 'Secure management of your digital voting identity.',
      icon: Icons.account_circle_outlined,
    );
  }
}