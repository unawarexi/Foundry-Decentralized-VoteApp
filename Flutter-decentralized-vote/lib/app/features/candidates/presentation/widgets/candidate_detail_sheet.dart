import 'package:flutter/material.dart';
import 'package:flutter_frontend_vote/core/utils/helper_functions.dart';
import 'package:flutter_frontend_vote/core/constants/colors.dart';
import 'package:flutter_frontend_vote/app/components/shapes/decorative_painters.dart';
import 'candidate_models.dart';
import 'candidate_atomic_widgets.dart';
import 'candidate_tabs.dart';

class CandidateDetailSheet extends StatefulWidget {
  final CandidateData candidate;
  final Animation<double> pulseAnim;

  const CandidateDetailSheet({
    super.key,
    required this.candidate,
    required this.pulseAnim,
  });

  @override
  State<CandidateDetailSheet> createState() => _CandidateDetailSheetState();
}

class _CandidateDetailSheetState extends State<CandidateDetailSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _sheetCtrl;
  late Animation<double> _sheetFade;
  late Animation<Offset> _sheetSlide;

  int _tabIndex = 0; // 0=Profile, 1=Manifesto, 2=Forum, 3=History

  @override
  void initState() {
    super.initState();
    _sheetCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _sheetFade = CurvedAnimation(parent: _sheetCtrl, curve: Curves.easeOut);
    _sheetSlide = Tween(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _sheetCtrl, curve: Curves.easeOut));
    _sheetCtrl.forward();
  }

  @override
  void dispose() {
    _sheetCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);
    final c = widget.candidate;
    return FadeTransition(
      opacity: _sheetFade,
      child: SlideTransition(
        position: _sheetSlide,
        child: DraggableScrollableSheet(
          initialChildSize: 0.88,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, ctrl) => Container(
            decoration: BoxDecoration(
              color: (isDark
                  ? TColors.darkSurface
                  : TColors.lightSurface),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(
                top: BorderSide(
                  color: (isDark
                      ? TColors.darkBorder
                      : TColors.lightBorder),
                ),
                left: BorderSide(
                  color: (isDark
                      ? TColors.darkBorder
                      : TColors.lightBorder),
                ),
                right: BorderSide(
                  color: (isDark
                      ? TColors.darkBorder
                      : TColors.lightBorder),
                ),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: (isDark
                          ? TColors.darkBorder
                          : TColors.lightBorder),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      CandidateAvatar(initials: c.initials, size: 52),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c.name,
                              style: TextStyle(
                                fontFamily: 'IBMPlexSerif',
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: (isDark
                                    ? TColors.white
                                    : TColors.black),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                PartyBadge(
                                  code: c.partyCode,
                                  color: c.partyColor,
                                ),
                                const SizedBox(width: 8),
                                if (c.isVerified)
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CustomPaint(
                                      painter: MiniLogoPainter(),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: (isDark
                                ? TColors.darkElevated
                                : TColors.lightElevated),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: (isDark
                                  ? TColors.darkBorder
                                  : TColors.lightBorder),
                            ),
                          ),
                          child: Icon(
                            Icons.close,
                            color: (isDark
                                ? TColors.textDarkTertiary
                                : TColors.textLightTertiary),
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                SheetTabBar(
                  tabs: const ['Profile', 'Manifesto', 'Forum', 'History'],
                  current: _tabIndex,
                  onTap: (i) => setState(() => _tabIndex = i),
                ),

                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: SlideTransition(
                        position: Tween(
                          begin: const Offset(0.05, 0),
                          end: Offset.zero,
                        ).animate(anim),
                        child: child,
                      ),
                    ),
                    child: _buildTabContent(_tabIndex, c, ctrl),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(int tab, CandidateData c, ScrollController ctrl) {
    switch (tab) {
      case 0:
        return ProfileTab(key: const ValueKey(0), candidate: c, ctrl: ctrl);
      case 1:
        return ManifestoTab(key: const ValueKey(1), candidate: c, ctrl: ctrl);
      case 2:
        return ForumTab(key: const ValueKey(2), candidate: c, ctrl: ctrl);
      case 3:
        return HistoryTab(key: const ValueKey(3), candidate: c, ctrl: ctrl);
      default:
        return const SizedBox.shrink();
    }
  }
}
