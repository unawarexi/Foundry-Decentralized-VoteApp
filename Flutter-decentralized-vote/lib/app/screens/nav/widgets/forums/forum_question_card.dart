import 'package:flutter/material.dart';
import 'package:flutter_frontend_vote/core/constants/colors.dart';
import 'package:flutter_frontend_vote/core/utils/helper_functions.dart';
import 'data_models.dart';
import 'atomic_widgets.dart';
import 'painters.dart';

class ForumQuestionCard extends StatefulWidget {
  final ForumQuestion question;
  final int index;
  final Animation<double> listAnim;
  final Animation<double> pulseAnim;
  final bool isUpvoted;
  final int upvoteCount;
  final VoidCallback onUpvote;
  final VoidCallback onTap;

  const ForumQuestionCard({
    super.key,
    required this.question,
    required this.index,
    required this.listAnim,
    required this.pulseAnim,
    required this.isUpvoted,
    required this.upvoteCount,
    required this.onUpvote,
    required this.onTap,
  });

  @override
  State<ForumQuestionCard> createState() => _ForumQuestionCardState();
}

class _ForumQuestionCardState extends State<ForumQuestionCard>
    with TickerProviderStateMixin {
  late AnimationController _pressCtrl;
  late AnimationController _upvoteCtrl;
  late Animation<double> _upvoteBounce;
  late AnimationController _burstCtrl;

  @override
  void initState() {
    super.initState();

    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.97,
      upperBound: 1.0,
    )..value = 1.0;

    _upvoteCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _upvoteBounce = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.35, end: 0.9), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0), weight: 30),
    ]).animate(CurvedAnimation(parent: _upvoteCtrl, curve: Curves.easeOut));

    _burstCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    _upvoteCtrl.dispose();
    _burstCtrl.dispose();
    super.dispose();
  }

  void _handleUpvote() {
    widget.onUpvote();
    _upvoteCtrl.forward(from: 0);
    if (!widget.isUpvoted) {
      _burstCtrl.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.question;
    final isDark = THelperFunctions.isDarkMode(context);

    final stagger = CurvedAnimation(
      parent: widget.listAnim,
      curve: Interval(
        (widget.index * 0.05).clamp(0.0, 0.65),
        1.0,
        curve: Curves.easeOut,
      ),
    );

    return FadeTransition(
      opacity: stagger,
      child: GestureDetector(
        onTapDown: (_) => _pressCtrl.reverse(),
        onTapUp: (_) {
          _pressCtrl.forward();
          widget.onTap();
        },
        onTapCancel: () => _pressCtrl.forward(),
        child: AnimatedBuilder(
          animation: _pressCtrl,
          builder: (_, child) =>
              Transform.scale(scale: _pressCtrl.value, child: child),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? TColors.darkCard : TColors.lightCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: q.isUnanswered
                    ? TColors.warning.withOpacity(
                        0.25 + 0.15 * widget.pulseAnim.value,
                      )
                    : (isDark ? TColors.darkBorder : TColors.lightBorder),
                width: q.isUnanswered ? 1.2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: (q.isUnanswered ? TColors.warning : TColors.primary)
                      .withOpacity(0.07),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CustomPaint(painter: MiniLogoPainter()),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        q.candidateName,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: TColors.secondary,
                          letterSpacing: 0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (q.isUnanswered)
                      AnimatedBuilder(
                        animation: widget.pulseAnim,
                        builder: (_, __) => SizedBox(
                          width: 54,
                          height: 20,
                          child: Stack(
                            alignment: Alignment.centerRight,
                            children: [
                              Positioned(
                                right: 0,
                                child: SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CustomPaint(
                                    painter: TimerArcPainter(
                                      progress: q.hoursRemaining / 24.0,
                                      color: q.hoursRemaining < 6
                                          ? TColors.error
                                          : TColors.warning,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 22,
                                child: Text(
                                  '${q.hoursRemaining.round()}h',
                                  style: TextStyle(
                                    fontFamily: 'IBMPlexMono',
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: q.hoursRemaining < 6
                                        ? TColors.error
                                        : TColors.warning,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: TColors.success.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: TColors.success.withOpacity(0.3),
                          ),
                        ),
                        child: const Text(
                          'ANSWERED',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: TColors.success,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                AccentTag(label: q.electionLevel),
                const SizedBox(height: 10),
                Text(
                  q.question,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: isDark
                        ? TColors.textDarkPrimary
                        : TColors.textLightPrimary,
                    height: 1.55,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                if (!q.isUnanswered && q.answerPreview.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark
                          ? TColors.darkElevated
                          : TColors.lightElevated,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark
                            ? TColors.darkBorder
                            : TColors.lightBorder,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 2,
                          height: 36,
                          decoration: BoxDecoration(
                            color: TColors.secondary,
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            q.answerPreview,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: isDark
                                  ? TColors.textDarkSecondary
                                  : TColors.textLightSecondary,
                              height: 1.5,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                Row(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        AnimatedBuilder(
                          animation: _burstCtrl,
                          builder: (_, __) {
                            if (_burstCtrl.value == 0 ||
                                _burstCtrl.value >= 1) {
                              return const SizedBox.shrink();
                            }
                            return Positioned.fill(
                              child: CustomPaint(
                                painter: UpvoteBurstPainter(
                                  progress: _burstCtrl.value,
                                  color: TColors.secondary,
                                ),
                              ),
                            );
                          },
                        ),
                        GestureDetector(
                          onTap: _handleUpvote,
                          child: AnimatedBuilder(
                            animation: _upvoteBounce,
                            builder: (_, __) => Transform.scale(
                              scale: _upvoteBounce.value,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: widget.isUpvoted
                                      ? TColors.secondary.withOpacity(0.12)
                                      : (isDark
                                            ? TColors.darkElevated
                                            : TColors.lightElevated),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: widget.isUpvoted
                                        ? TColors.secondary.withOpacity(0.5)
                                        : (isDark
                                              ? TColors.darkBorder
                                              : TColors.lightBorder),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.arrow_upward_rounded,
                                      size: 14,
                                      color: widget.isUpvoted
                                          ? TColors.secondary
                                          : (isDark
                                                ? TColors.textDarkTertiary
                                                : TColors.textLightTertiary),
                                    ),
                                    const SizedBox(width: 5),
                                    AnimatedSwitcher(
                                      duration: const Duration(
                                        milliseconds: 250,
                                      ),
                                      transitionBuilder: (child, anim) =>
                                          SlideTransition(
                                            position: Tween(
                                              begin: const Offset(0, -0.5),
                                              end: Offset.zero,
                                            ).animate(anim),
                                            child: FadeTransition(
                                              opacity: anim,
                                              child: child,
                                            ),
                                          ),
                                      child: Text(
                                        '${widget.upvoteCount}',
                                        key: ValueKey(widget.upvoteCount),
                                        style: TextStyle(
                                          fontFamily: 'IBMPlexMono',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: widget.isUpvoted
                                              ? TColors.secondary
                                              : (isDark
                                                    ? TColors.textDarkTertiary
                                                    : TColors
                                                          .textLightTertiary),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? TColors.darkElevated
                            : TColors.lightElevated,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark
                              ? TColors.darkBorder
                              : TColors.lightBorder,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.comment_outlined,
                            size: 13,
                            color: isDark
                                ? TColors.textDarkTertiary
                                : TColors.textLightTertiary,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '${q.answers}',
                            style: TextStyle(
                              fontFamily: 'IBMPlexMono',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? TColors.textDarkTertiary
                                  : TColors.textLightTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          q.election,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 9.5,
                            color: isDark
                                ? TColors.textDarkTertiary
                                : TColors.textLightTertiary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          q.postedDisplay,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 9.5,
                            color: isDark
                                ? TColors.textDarkTertiary
                                : TColors.textLightTertiary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
