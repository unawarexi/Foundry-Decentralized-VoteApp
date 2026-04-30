import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_frontend_vote/core/constants/colors.dart';
import 'package:flutter_frontend_vote/core/utils/helper_functions.dart';
import 'package:flutter_frontend_vote/app/components/shapes/decorative_painters.dart';

class VoteCastingScreen extends StatelessWidget {
  const VoteCastingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);
    
    return Scaffold(
      backgroundColor: isDark ? TColors.darkBackground : TColors.lightBackground,
      body: Stack(
        children: [
          CustomPaint(
            size: MediaQuery.of(context).size,
            painter: AuthGridPainter(
              color: TColors.secondary.withOpacity(isDark ? 0.04 : 0.12),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context, isDark),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(24),
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: isDark ? TColors.darkCard : TColors.lightCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: TColors.secondary.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.security_rounded, size: 48, color: TColors.secondary),
                      const SizedBox(height: 16),
                      Text(
                        'Secure Voting Booth',
                        style: TextStyle(
                          fontFamily: 'IBMPlexSerif',
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: isDark ? TColors.white : TColors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Biometric verification and zero-knowledge proofs will be applied during vote casting.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          color: TColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? TColors.darkCard : TColors.lightCard,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isDark ? TColors.darkBorder : TColors.lightBorder),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: isDark ? TColors.white : TColors.black,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'Cast Your Vote',
            style: TextStyle(
              fontFamily: 'IBMPlexSerif',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? TColors.white : TColors.black,
            ),
          ),
        ],
      ),
    );
  }
}
