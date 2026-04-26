import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_frontend_vote/core/constants/colors.dart';
import 'package:flutter_frontend_vote/core/constants/sizes.dart';

class SSkeleton extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SSkeleton({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = TSizes.radiusSm,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? TColors.darkElevated : TColors.lightElevated,
      highlightColor: isDark ? TColors.darkHover : TColors.lightHover,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// Skeleton for meeting card list.
class SMeetingCardSkeleton extends StatelessWidget {
  const SMeetingCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: TSizes.sm),
      child: Row(
        children: [
          SSkeleton(width: 4, height: 48, borderRadius: 2),
          SizedBox(width: TSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SSkeleton(height: 16, width: 180),
                SizedBox(height: TSizes.sm),
                SSkeleton(height: 12, width: 120),
                SizedBox(height: TSizes.sm),
                SSkeleton(height: 12, width: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton for avatar row.
class SAvatarSkeleton extends StatelessWidget {
  final double size;
  const SAvatarSkeleton({super.key, this.size = TSizes.avatarMd});

  @override
  Widget build(BuildContext context) {
    return SSkeleton(
      width: size,
      height: size,
      borderRadius: size / 2,
    );
  }
}
