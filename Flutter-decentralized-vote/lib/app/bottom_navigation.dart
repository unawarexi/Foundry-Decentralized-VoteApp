import 'package:flutter/material.dart';
import 'package:flutter_frontend_vote/core/constants/colors.dart';
import 'package:flutter_frontend_vote/core/utils/helper_functions.dart';
import 'package:flutter_frontend_vote/app/screens/nav/elections_screen.dart';
import 'package:flutter_frontend_vote/app/screens/nav/candidates_screen.dart';
import 'package:flutter_frontend_vote/app/screens/nav/profile_screen.dart';
import 'package:flutter_frontend_vote/app/screens/nav/forums_screen.dart';
import 'package:flutter_frontend_vote/app/screens/nav/home_screen.dart';

// Main Bottom Navigation Widget
class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation>
    with SingleTickerProviderStateMixin {
  int _navIndex = 0;
  late AnimationController _entranceController;
  late Animation<double> _fadeAnim;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ElectionsScreen(),
    const CandidatesScreen(),
    const ForumScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );
    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);
    return Scaffold(
      body: _screens[_navIndex],
      backgroundColor: isDark
          ? TColors.darkBackground
          : TColors.lightBackground,
      extendBody: true,
      bottomNavigationBar: FadeTransition(
        opacity: _fadeAnim,
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          decoration: BoxDecoration(
            color: (isDark ? TColors.darkSurface : TColors.lightSurface)
                .withOpacity(0.95),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? TColors.darkBorder : TColors.lightBorder,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.4 : 0.1),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                index: 0,
                selected: _navIndex == 0,
                onTap: (i) => setState(() => _navIndex = i),
              ),
              _NavItem(
                icon: Icons.how_to_vote_outlined,
                label: 'Elections',
                index: 1,
                selected: _navIndex == 1,
                onTap: (i) => setState(() => _navIndex = i),
              ),
              _NavItem(
                icon: Icons.person_search_outlined,
                label: 'Candidates',
                index: 2,
                selected: _navIndex == 2,
                onTap: (i) => setState(() => _navIndex = i),
              ),
              _NavItem(
                icon: Icons.forum_outlined,
                label: 'Forum',
                index: 3,
                selected: _navIndex == 3,
                onTap: (i) => setState(() => _navIndex = i),
              ),
              _NavItem(
                icon: Icons.person_outline_rounded,
                label: 'Profile',
                index: 4,
                selected: _navIndex == 4,
                onTap: (i) => setState(() => _navIndex = i),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Bottom nav item (design from vote_screen.dart) ─────────────
// Gold accent, secondary-colored selected state, border highlight.
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final bool selected;
  final void Function(int) onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);
    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected
              ? TColors.primary.withOpacity(isDark ? 0.5 : 1.0)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: selected
              ? Border.all(color: TColors.secondary.withOpacity(0.3))
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected
                  ? TColors.secondary
                  : (isDark
                        ? TColors.textDarkTertiary
                        : TColors.textLightTertiary),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 8.5,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected
                    ? TColors.secondary
                    : (isDark
                          ? TColors.textDarkTertiary
                          : TColors.textLightTertiary),
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
