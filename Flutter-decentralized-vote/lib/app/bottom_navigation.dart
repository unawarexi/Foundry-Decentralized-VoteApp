import 'package:flutter/material.dart';
import 'package:flutter_frontend_vote/core/constants/colors.dart';
import 'package:flutter_frontend_vote/core/constants/sizes.dart';
import 'package:flutter_frontend_vote/core/animations/animations.dart';
import 'package:flutter_frontend_vote/core/constants/responsive.dart';
import 'package:flutter_frontend_vote/core/utils/helper_functions.dart';
import 'package:flutter_frontend_vote/app/screens/nav/analytics_screen.dart';
import 'package:flutter_frontend_vote/app/screens/nav/candidates_screen.dart';
import 'package:flutter_frontend_vote/app/screens/nav/profile_screen.dart';
import 'package:flutter_frontend_vote/app/screens/nav/verify_screen.dart';
import 'package:flutter_frontend_vote/app/screens/nav/vote_screen.dart';

// Main Bottom Navigation Widget
class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _scaleAnimations;

  final List<Widget> _screens = [
    const VoteScreen(),
    const CandidatesScreen(),
    const AnalyticsScreen(),
    const ProfileScreen(),
    const VerifyScreen(),
  ];

  final List<NavItem> _navItems = [
    NavItem(
      icon: Icons.how_to_vote_outlined,
      activeIcon: Icons.how_to_vote,
      label: 'Vote',
      gradientColors: [TColors.primary, TColors.primaryDark],
    ),
    NavItem(
      icon: Icons.people_outline_rounded,
      activeIcon: Icons.people_rounded,
      label: 'Candidates',
      gradientColors: [TColors.secondary, TColors.secondary],
    ),
    NavItem(
      icon: Icons.analytics_outlined,
      activeIcon: Icons.analytics,
      label: 'Analytics',
      gradientColors: [TColors.primary, TColors.secondaryAlt],
    ),
    NavItem(
      icon: Icons.account_circle_outlined,
      activeIcon: Icons.account_circle,
      label: 'Profile',
      gradientColors: [TColors.secondaryAlt, TColors.primary],
    ),
    NavItem(
      icon: Icons.verified_user_outlined,
      activeIcon: Icons.verified_user,
      label: 'Verify',
      gradientColors: [TColors.accent, TColors.accent],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationControllers = List.generate(
      _navItems.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      ),
    );

    _scaleAnimations = _animationControllers
        .map(
          (controller) => Tween<double>(begin: 0.8, end: 1.0).animate(
            CurvedAnimation(parent: controller, curve: Curves.elasticOut),
          ),
        )
        .toList();

    // Animate the initially selected item
    _animationControllers[0].forward();
  }

  @override
  void dispose() {
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        height: TSizes.bottomNavHeight,
        decoration: BoxDecoration(
          color: isDark ? TColors.darkSurface : TColors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: (isDark ? Colors.black : TColors.primary.withOpacity(0.1)),
              blurRadius: 25,
              spreadRadius: 0,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: isDark ? TColors.darkBorder : TColors.lightBorder,
                width: 1,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              _navItems.length,
              (index) => _buildModernNavItem(
                index: index,
                navItem: _navItems[index],
                isDark: isDark,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernNavItem({
    required int index,
    required NavItem navItem,
    required bool isDark,
  }) {
    final isActive = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        if (_currentIndex != index) {
          setState(() {
            // Reset previous animation
            _animationControllers[_currentIndex].reverse();
            _currentIndex = index;
            // Start new animation
            _animationControllers[index].forward();
          });
        }
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _scaleAnimations[index],
        builder: (context, child) {
          return Transform.scale(
            scale: isActive ? _scaleAnimations[index].value : 0.9,
            child: Container(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon Container with gradient background for active state
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: isActive
                          ? LinearGradient(
                              colors: navItem.gradientColors,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: !isActive
                          ? (isDark
                                ? TColors.darkElevated
                                : TColors.lightElevated)
                          : null,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: navItem.gradientColors[0].withOpacity(
                                  0.4,
                                ),
                                blurRadius: 15,
                                spreadRadius: 1,
                                offset: const Offset(0, 8),
                              ),
                              BoxShadow(
                                color: navItem.gradientColors[1].withOpacity(
                                  0.2,
                                ),
                                blurRadius: 8,
                                spreadRadius: -2,
                                offset: const Offset(0, -2),
                              ),
                            ]
                          : [],
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        isActive ? navItem.activeIcon : navItem.icon,
                        key: ValueKey(isActive),
                        color: isActive
                            ? TColors.white
                            : (isDark
                                  ? TColors.textDarkTertiary
                                  : TColors.textLightTertiary),
                        size: 20,
                      ),
                    ),
                  ),

                  const SizedBox(height: 2),

                  // Label with gradient text for active state
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      color: isActive
                          ? (isDark ? TColors.white : TColors.primary)
                          : (isDark
                                ? TColors.textDarkTertiary
                                : TColors.textLightTertiary),
                      letterSpacing: isActive ? 0.4 : 0,
                    ),
                    child: Text(navItem.label),
                  ),

                  // Active indicator dot
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(top: 2),
                    width: isActive ? 16 : 0,
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: isActive
                          ? LinearGradient(colors: navItem.gradientColors)
                          : null,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final List<Color> gradientColors;

  NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.gradientColors,
  });
}
