import 'package:flutter/material.dart';
import 'package:flutter_frontend_vote/core/constants/colors.dart';
import 'package:flutter_frontend_vote/core/constants/image_strings.dart';
import 'package:flutter_frontend_vote/core/utils/helper_functions.dart';
import 'package:flutter_frontend_vote/core/constants/animations.dart';
import 'package:flutter_frontend_vote/presentation/shared/bottom_navigation.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'dart:async';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _logoController;
  late Animation<double> _logoAnimation;
  Timer? _autoSlideTimer;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      icon: Icons.how_to_vote_outlined,
      title: "Decentralized Voting",
      description:
          "Experience the future of democracy with blockchain-powered voting. Your vote is secure, transparent, and immutable.",
      gradientColors: [TColors.primaryBlue, TColors.primaryPurple],
      features: [
        "Cryptographically secured",
        "Transparent process",
        "Immutable records",
      ],
    ),
    OnboardingPage(
      icon: Icons.security_outlined,
      title: "Blockchain Security",
      description:
          "Built on Web3 technology ensuring every vote is cryptographically secured and cannot be tampered with.",
      gradientColors: [TColors.primaryPurple, TColors.primaryIndigo],
      features: [
        "End-to-end encryption",
        "Decentralized storage",
        "Zero knowledge proofs",
      ],
    ),
    OnboardingPage(
      icon: Icons.verified_outlined,
      title: "Transparent Results",
      description:
          "Real-time vote counting with complete transparency. View results on the blockchain and verify your participation.",
      gradientColors: [TColors.primaryIndigo, TColors.defi],
      features: [
        "Real-time counting",
        "Public verification",
        "Audit trail available",
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _logoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoController.forward();

    // Start auto-slide timer
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_currentPage < _pages.length - 1) {
        _pageController.nextPage(
          duration: TAnimations.normal,
          curve: TAnimations.smoothCurve,
        );
      } else {
        _pageController.animateToPage(
          0,
          duration: TAnimations.normal,
          curve: TAnimations.smoothCurve,
        );
      }
    });
  }

  void _stopAutoSlide() {
    _autoSlideTimer?.cancel();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _autoSlideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    TColors.darkBackground,
                    TColors.darkSurface.withOpacity(0.8),
                    TColors.darkCard,
                  ]
                : [TColors.lightBackground, Colors.white, TColors.lightSurface],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Animated Header
              _buildAnimatedHeader(isDark),

              // PageView content with animations
              Expanded(
                child: GestureDetector(
                  onTap: _stopAutoSlide, // Stop auto-slide on user interaction
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                      // Restart auto-slide timer when user manually changes page
                      _stopAutoSlide();
                      _startAutoSlide();
                    },
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return FadeInAnimation(
                        delay: Duration(milliseconds: 200 * index),
                        child: SlideInAnimation(
                          delay: Duration(milliseconds: 100 * index),
                          beginOffset: const Offset(0.3, 0),
                          child: _buildPage(_pages[index], isDark),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Modern Bottom Navigation
              _buildModernBottomNav(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Animated Logo
          AnimatedBuilder(
            animation: _logoAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _logoAnimation.value,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Image.asset(width: 60, height: 60, TImages.logo2),
                ),
              );
            },
          ),

          // Skip button with animation
          ScaleAnimation(
            delay: const Duration(milliseconds: 500),
            child: TextButton(
              onPressed: () => {
                _stopAutoSlide(),
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const BottomNavigation(),
                  ),
                ),
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                "Skip",
                style: TextStyle(
                  color: isDark
                      ? TColors.textDarkSecondary
                      : TColors.textSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingPage page, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20), // Reduced from default spacing
          // Animated Icon Container - Reduced size and spacing
          ScaleAnimation(
            duration: TAnimations.slow,
            curve: TAnimations.bounceCurve,
            child: Container(
              width: 100, // Reduced from 140
              height: 100, // Reduced from 140
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: page.gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: page.gradientColors[0].withOpacity(0.4),
                    blurRadius: 20, // Reduced from 30
                    spreadRadius: 3, // Reduced from 5
                    offset: const Offset(0, 10), // Reduced from 15
                  ),
                  BoxShadow(
                    color: page.gradientColors[1].withOpacity(0.2),
                    blurRadius: 10, // Reduced from 15
                    spreadRadius: -3, // Reduced from -5
                    offset: const Offset(0, -3), // Reduced from -5
                  ),
                ],
              ),
              child: PulseAnimation(
                child: Icon(
                  page.icon,
                  size: 50,
                  color: TColors.white,
                ), // Reduced from 70
              ),
            ),
          ),

          const SizedBox(height: 30), // Reduced from 60
          // Animated Title
          FadeInAnimation(
            delay: const Duration(milliseconds: 300),
            child: Text(
              page.title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? TColors.textDark : TColors.textPrimary,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 16), // Reduced from 24
          // Animated Description
          SlideInAnimation(
            delay: const Duration(milliseconds: 400),
            beginOffset: const Offset(0, 0.3),
            child: Text(
              page.description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: isDark
                    ? TColors.textDarkSecondary
                    : TColors.textSecondary,
                height: 1.5, // Reduced from 1.7
                fontSize: 14, // Reduced from 16
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 24), // Reduced from 40
          // Feature List with Staggered Animation - Better wrapping
          Container(
            constraints: const BoxConstraints(maxWidth: 350),
            child: Wrap(
              spacing: 8, // Reduced from 12
              runSpacing: 8, // Reduced from 12
              alignment: WrapAlignment.center,
              children: List.generate(
                page.features.length,
                (index) => SlideInAnimation(
                  delay: Duration(milliseconds: 150 * index),
                  beginOffset: const Offset(0.2, 0),
                  child: _buildFeatureItem(page.features[index], isDark),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24), // Reduced from 40
          // Blockchain Badge - More compact
          FadeInAnimation(
            delay: const Duration(milliseconds: 800),
            child: _buildBlockchainBadge(isDark),
          ),

          const SizedBox(height: 20), // Added bottom spacing for scrollview
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String feature, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ), // Reduced padding
      decoration: BoxDecoration(
        color: isDark
            ? TColors.darkCard.withOpacity(0.6)
            : TColors.lightCard.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20), // Reduced from 25
        border: Border.all(
          color: TColors.primaryBlue.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? TColors.darkBackground : Colors.black).withOpacity(
              0.05,
            ),
            blurRadius: 8, // Reduced from 10
            offset: const Offset(0, 2), // Reduced from 4
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5, // Reduced from 6
            height: 5, // Reduced from 6
            decoration: BoxDecoration(
              gradient: TColors.primaryGradient,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6), // Reduced from 8
          Text(
            feature,
            style: TextStyle(
              color: isDark ? TColors.textDarkSecondary : TColors.textSecondary,
              fontSize: 12, // Reduced from 13
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlockchainBadge(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ), // Reduced padding
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            TColors.blockchain.withOpacity(0.1),
            TColors.defi.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16), // Reduced from 20
        border: Border.all(
          color: TColors.blockchain.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified_user,
            color: TColors.blockchain,
            size: 16,
          ), // Reduced from 20
          const SizedBox(width: 8), // Reduced from 12
          Text(
            "Powered by Blockchain Technology",
            style: TextStyle(
              color: isDark ? TColors.textDarkSecondary : TColors.textSecondary,
              fontSize: 11, // Reduced from 13
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernBottomNav(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark
            ? TColors.darkSurface.withOpacity(0.8)
            : Colors.white.withOpacity(0.9),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.grey).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Modern Page Indicators
          FadeInAnimation(
            delay: const Duration(milliseconds: 600),
            child: SmoothPageIndicator(
              controller: _pageController,
              count: _pages.length,
              effect: ExpandingDotsEffect(
                activeDotColor: TColors.primaryBlue,
                dotColor:
                    (isDark ? TColors.textDarkSecondary : TColors.textSecondary)
                        .withOpacity(0.3),
                dotHeight: 8,
                dotWidth: 8,
                expansionFactor: 4,
                spacing: 8,
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Action Buttons
          SlideInAnimation(
            delay: const Duration(milliseconds: 700),
            beginOffset: const Offset(0, 0.5),
            child: Row(
              children: [
                // Previous Button
                if (_currentPage > 0)
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: TColors.primaryBlue.withOpacity(0.3),
                        ),
                      ),
                      child: OutlinedButton(
                        onPressed: () {
                          _stopAutoSlide();
                          _pageController.previousPage(
                            duration: TAnimations.normal,
                            curve: TAnimations.smoothCurve,
                          );
                          _startAutoSlide();
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide.none,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          "Previous",
                          style: TextStyle(
                            color: TColors.primaryBlue,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),

                if (_currentPage > 0) const SizedBox(width: 16),

                // Next/Get Started Button
                Expanded(
                  flex: _currentPage == 0 ? 1 : 2,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: TColors.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        _stopAutoSlide();
                        if (_currentPage == _pages.length - 1) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const BottomNavigation(),
                            ),
                          );
                        } else {
                          _pageController.nextPage(
                            duration: TAnimations.normal,
                            curve: TAnimations.smoothCurve,
                          );
                          _startAutoSlide();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentPage == _pages.length - 1
                                ? "Get Started"
                                : "Next",
                            style: const TextStyle(
                              color: TColors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            _currentPage == _pages.length - 1
                                ? Icons.rocket_launch
                                : Icons.arrow_forward,
                            color: TColors.white,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  final List<Color> gradientColors;
  final List<String> features;

  OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.gradientColors,
    required this.features,
  });
}











// import 'package:flutter/material.dart';
// import 'package:flutter_frontend_vote/core/constants/colors.dart';
// import 'package:flutter_frontend_vote/core/constants/image_strings.dart';
// import 'package:flutter_frontend_vote/core/utils/helper_functions.dart';
// import 'package:flutter_frontend_vote/core/constants/animations.dart';
// import 'package:flutter_frontend_vote/presentation/shared/bottom_navigation.dart';
// import 'package:smooth_page_indicator/smooth_page_indicator.dart';

// class OnboardingScreen extends StatefulWidget {
//   const OnboardingScreen({super.key});

//   @override
//   State<OnboardingScreen> createState() => _OnboardingScreenState();
// }

// class _OnboardingScreenState extends State<OnboardingScreen>
//     with TickerProviderStateMixin {
//   final PageController _pageController = PageController();
//   int _currentPage = 0;
//   late AnimationController _logoController;
//   late Animation<double> _logoAnimation;

//   final List<OnboardingPage> _pages = [
//     OnboardingPage(
//       icon: Icons.how_to_vote_outlined,
//       title: "Decentralized Voting",
//       description:
//           "Experience the future of democracy with blockchain-powered voting. Your vote is secure, transparent, and immutable.",
//       gradientColors: [TColors.primaryBlue, TColors.primaryPurple],
//       features: [
//         "Cryptographically secured",
//         "Transparent process",
//         "Immutable records",
//       ],
//     ),
//     OnboardingPage(
//       icon: Icons.security_outlined,
//       title: "Blockchain Security",
//       description:
//           "Built on Web3 technology ensuring every vote is cryptographically secured and cannot be tampered with.",
//       gradientColors: [TColors.primaryPurple, TColors.primaryIndigo],
//       features: [
//         "End-to-end encryption",
//         "Decentralized storage",
//         "Zero knowledge proofs",
//       ],
//     ),
//     OnboardingPage(
//       icon: Icons.verified_outlined,
//       title: "Transparent Results",
//       description:
//           "Real-time vote counting with complete transparency. View results on the blockchain and verify your participation.",
//       gradientColors: [TColors.primaryIndigo, TColors.defi],
//       features: [
//         "Real-time counting",
//         "Public verification",
//         "Audit trail available",
//       ],
//     ),
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _logoController = AnimationController(
//       duration: const Duration(seconds: 2),
//       vsync: this,
//     );
//     _logoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
//     );
//     _logoController.forward();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDark = THelperFunctions.isDarkMode(context);

//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: isDark
//                 ? [
//                     TColors.darkBackground,
//                     TColors.darkSurface.withOpacity(0.8),
//                     TColors.darkCard,
//                   ]
//                 : [TColors.lightBackground, Colors.white, TColors.lightSurface],
//           ),
//         ),
//         child: SafeArea(
//           child: Column(
//             children: [
//               // Animated Header
//               _buildAnimatedHeader(isDark),

//               // PageView content with animations
//               Expanded(
//                 child: PageView.builder(
//                   controller: _pageController,
//                   onPageChanged: (index) {
//                     setState(() {
//                       _currentPage = index;
//                     });
//                   },
//                   itemCount: _pages.length,
//                   itemBuilder: (context, index) {
//                     return FadeInAnimation(
//                       delay: Duration(milliseconds: 200 * index),
//                       child: SlideInAnimation(
//                         delay: Duration(milliseconds: 100 * index),
//                         beginOffset: const Offset(0.3, 0),
//                         child: _buildPage(_pages[index], isDark),
//                       ),
//                     );
//                   },
//                 ),
//               ),

//               // Modern Bottom Navigation
//               _buildModernBottomNav(isDark),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildAnimatedHeader(bool isDark) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           // Animated Logo
//           AnimatedBuilder(
//             animation: _logoAnimation,
//             builder: (context, child) {
//               return Transform.scale(
//                 scale: _logoAnimation.value,

//                 child: Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 20,
//                     vertical: 12,
//                   ),

//                   child: Image.asset(width: 60, height: 60, TImages.logo2),
//                 ),
//               );
//             },
//           ),

//           // Skip button with animation
//           ScaleAnimation(
//             delay: const Duration(milliseconds: 500),
//             child: TextButton(
//               onPressed: () => {
//                 Navigator.of(context).pushReplacement(
//                   MaterialPageRoute(
//                     builder: (context) => const BottomNavigation(),
//                   ),
//                 ),
//               },
//               style: TextButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 8,
//                 ),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//               ),
//               child: Text(
//                 "Skip",
//                 style: TextStyle(
//                   color: isDark
//                       ? TColors.textDarkSecondary
//                       : TColors.textSecondary,
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPage(OnboardingPage page, bool isDark) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
//       child: Column(
       
//         children: [
//           // Animated Icon Container
//           ScaleAnimation(
//             duration: TAnimations.slow,
//             curve: TAnimations.bounceCurve,
//             child: Container(
//               width: 120,
//               height: 120,
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: page.gradientColors,
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 shape: BoxShape.circle,
//                 boxShadow: [
//                   BoxShadow(
//                     color: page.gradientColors[0].withOpacity(0.4),
//                     blurRadius: 30,
//                     spreadRadius: 5,
//                     offset: const Offset(0, 15),
//                   ),
//                   BoxShadow(
//                     color: page.gradientColors[1].withOpacity(0.2),
//                     blurRadius: 15,
//                     spreadRadius: -5,
//                     offset: const Offset(0, -5),
//                   ),
//                 ],
//               ),
//               child: PulseAnimation(
//                 child: Icon(page.icon, size: 70, color: TColors.white),
//               ),
//             ),
//           ),

//           const SizedBox(height: 40),

//           // Animated Title
//           FadeInAnimation(
//             delay: const Duration(milliseconds: 300),
//             child: Text(
//               page.title,
//               style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                 fontWeight: FontWeight.bold,
//                 color: isDark ? TColors.textDark : TColors.textPrimary,
//                 letterSpacing: -0.5,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ),

//           const SizedBox(height: 24),

//           // Animated Description
//           SlideInAnimation(
//             delay: const Duration(milliseconds: 400),
//             beginOffset: const Offset(0, 0.3),
//             child: Text(
//               page.description,
//               style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                 color: isDark
//                     ? TColors.textDarkSecondary
//                     : TColors.textSecondary,
//                 height: 1.7,
//                 fontSize: 14,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ),

//           const SizedBox(height: 40),

//           // Feature List with Staggered Animation
//           Wrap(
//             spacing: 12,
//             runSpacing: 12,
//             children: List.generate(
//               page.features.length,
//               (index) => SlideInAnimation(
//                 delay: Duration(milliseconds: 150 * index),
//                 beginOffset: const Offset(0.2, 0),
//                 child: _buildFeatureItem(page.features[index], isDark),
//               ),
//             ),
//           ),

//           const SizedBox(height: 40),

//           // Blockchain Badge
//           FadeInAnimation(
//             delay: const Duration(milliseconds: 800),
//             child: _buildBlockchainBadge(isDark),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFeatureItem(String feature, bool isDark) {
//     return Container(
//       margin: const EdgeInsets.only(right: 12), // Horizontal spacing for row
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//       decoration: BoxDecoration(
//         color: isDark
//             ? TColors.darkCard.withOpacity(0.6)
//             : TColors.lightCard.withOpacity(0.8),
//         borderRadius: BorderRadius.circular(25),
//         border: Border.all(
//           color: TColors.primaryBlue.withOpacity(0.2),
//           width: 1,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: (isDark ? TColors.darkBackground : Colors.black).withOpacity(
//               0.05,
//             ),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             width: 6,
//             height: 6,
//             decoration: BoxDecoration(
//               gradient: TColors.primaryGradient,
//               shape: BoxShape.circle,
//             ),
//           ),
//           const SizedBox(width: 8),
//           Text(
//             feature,
//             style: TextStyle(
//               color: isDark ? TColors.textDarkSecondary : TColors.textSecondary,
//               fontSize: 13,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBlockchainBadge(bool isDark) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             TColors.blockchain.withOpacity(0.1),
//             TColors.defi.withOpacity(0.1),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(
//           color: TColors.blockchain.withOpacity(0.3),
//           width: 1,
//         ),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(Icons.verified_user, color: TColors.blockchain, size: 20),
//           const SizedBox(width: 12),
//           Text(
//             "Powered by Blockchain Technology",
//             style: TextStyle(
//               color: isDark ? TColors.textDarkSecondary : TColors.textSecondary,
//               fontSize: 13,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildModernBottomNav(bool isDark) {
//     return Container(
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: isDark
//             ? TColors.darkCard
//             : Colors.white.withOpacity(0.9),
//         borderRadius: const BorderRadius.only(
//           topLeft: Radius.circular(30),
//           topRight: Radius.circular(30),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: (isDark ? Colors.black : Colors.grey).withOpacity(0.1),
//             blurRadius: 20,
//             offset: const Offset(0, -10),
//           ),
//         ],
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           // Modern Page Indicators
//           FadeInAnimation(
//             delay: const Duration(milliseconds: 600),
//             child: SmoothPageIndicator(
//               controller: _pageController,
//               count: _pages.length,
//               effect: ExpandingDotsEffect(
//                 activeDotColor: TColors.primaryBlue,
//                 dotColor:
//                     (isDark ? TColors.textDarkSecondary : TColors.textSecondary)
//                         .withOpacity(0.3),
//                 dotHeight: 8,
//                 dotWidth: 10,
//                 expansionFactor: 4,
//                 spacing: 8,
//               ),
//             ),
//           ),

//           const SizedBox(height: 32),

//           // Action Buttons
//           SlideInAnimation(
//             delay: const Duration(milliseconds: 700),
//             beginOffset: const Offset(0, 0.5),
//             child: Row(
//               children: [
//                 // Previous Button
//                 if (_currentPage > 0)
//                   Expanded(
//                     child: Container(
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(16),
//                         border: Border.all(
//                           color: TColors.primaryBlue.withOpacity(0.3),
//                         ),
//                       ),
//                       child: OutlinedButton(
//                         onPressed: () {
//                           _pageController.previousPage(
//                             duration: TAnimations.normal,
//                             curve: TAnimations.smoothCurve,
//                           );
//                         },
//                         style: OutlinedButton.styleFrom(
//                           side: BorderSide.none,
//                           padding: const EdgeInsets.symmetric(vertical: 18),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(16),
//                           ),
//                         ),
//                         child: Text(
//                           "Previous",
//                           style: TextStyle(
//                             color: TColors.primaryBlue,
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),

//                 if (_currentPage > 0) const SizedBox(width: 16),

//                 // Next/Get Started Button
//                 Expanded(
//                   flex: _currentPage == 0 ? 1 : 2,
//                   child: Container(
//                     decoration: BoxDecoration(
//                       gradient: TColors.primaryGradient,
//                       borderRadius: BorderRadius.circular(16),
//                       // boxShadow: [
//                       //   BoxShadow(
//                       //     color: TColors.primaryBlue.withOpacity(0.4),
//                       //     blurRadius: 15,
//                       //     offset: const Offset(0, 8),
//                       //   ),
//                       // ],
//                     ),
//                     child: ElevatedButton(
//                       onPressed: () {
//                         if (_currentPage == _pages.length - 1) {
//                           Navigator.of(context).pushReplacement(
//                             MaterialPageRoute(
//                               builder: (context) => const BottomNavigation(),
//                             ),
//                           );
//                         } else {
//                           _pageController.nextPage(
//                             duration: TAnimations.normal,
//                             curve: TAnimations.smoothCurve,
//                           );
//                         }
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.transparent,
//                         shadowColor: Colors.transparent,
//                         padding: const EdgeInsets.symmetric(vertical: 18),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(16),
//                         ),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text(
//                             _currentPage == _pages.length - 1
//                                 ? "Get Started"
//                                 : "Next",
//                             style: const TextStyle(
//                               color: TColors.white,
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                           const SizedBox(width: 8),
//                           Icon(
//                             _currentPage == _pages.length - 1
//                                 ? Icons.rocket_launch
//                                 : Icons.arrow_forward,
//                             color: TColors.white,
//                             size: 20,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class OnboardingPage {
//   final IconData icon;
//   final String title;
//   final String description;
//   final List<Color> gradientColors;
//   final List<String> features;

//   OnboardingPage({
//     required this.icon,
//     required this.title,
//     required this.description,
//     required this.gradientColors,
//     required this.features,
//   });
// }
