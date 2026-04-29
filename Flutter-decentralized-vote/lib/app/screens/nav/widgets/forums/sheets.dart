import 'package:flutter/material.dart';
import 'package:flutter_frontend_vote/core/constants/colors.dart';
import 'package:flutter_frontend_vote/core/utils/helper_functions.dart';
import 'data_models.dart';
import 'atomic_widgets.dart';
import 'package:flutter_frontend_vote/app/components/shapes/decorative_painters.dart';

class AskQuestionSheet extends StatefulWidget {
  const AskQuestionSheet({super.key});

  @override
  State<AskQuestionSheet> createState() => _AskQuestionSheetState();
}

class _AskQuestionSheetState extends State<AskQuestionSheet>
    with SingleTickerProviderStateMixin {
  final _textCtrl = TextEditingController();
  String _selectedCandidate = 'Monday Okpebholo';
  String _selectedElection = 'Edo State Gubernatorial 2024';
  bool _isSubmitting = false;
  int get _charCount => _textCtrl.text.length;

  late AnimationController _sheetCtrl;
  late Animation<double> _sheetFade;
  late Animation<Offset> _sheetSlide;

  @override
  void initState() {
    super.initState();
    _sheetCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _sheetFade = CurvedAnimation(parent: _sheetCtrl, curve: Curves.easeOut);
    _sheetSlide = Tween(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _sheetCtrl, curve: Curves.easeOut));
    _sheetCtrl.forward();
    _textCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _sheetCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);
    return FadeTransition(
      opacity: _sheetFade,
      child: SlideTransition(
        position: _sheetSlide,
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? TColors.darkSurface : TColors.lightSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(
                color: isDark ? TColors.darkBorder : TColors.lightBorder,
              ),
              left: BorderSide(
                color: isDark ? TColors.darkBorder : TColors.lightBorder,
              ),
              right: BorderSide(
                color: isDark ? TColors.darkBorder : TColors.lightBorder,
              ),
            ),
          ),
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? TColors.darkBorder : TColors.lightBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Ask a Question',
                style: TextStyle(
                  fontFamily: 'IBMPlexSerif',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: isDark ? TColors.white : TColors.black,
                ),
              ),
              const SizedBox(height: 6),
              Container(width: 32, height: 2, color: TColors.secondary),
              const SizedBox(height: 6),
              Text(
                'Candidates have 24 hours to respond. Failure to answer '
                'reduces their popularity score on-chain.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: isDark
                      ? TColors.textDarkTertiary
                      : TColors.textLightTertiary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              SheetDropdown(
                label: 'CANDIDATE',
                value: _selectedCandidate,
                options: const [
                  'Monday Okpebholo',
                  'Asue Ighodalo',
                  'Olumide Akpata',
                  'Dr. Aisha Bukar',
                ],
                onChanged: (v) => setState(() => _selectedCandidate = v!),
              ),
              const SizedBox(height: 14),
              SheetDropdown(
                label: 'ELECTION',
                value: _selectedElection,
                options: const [
                  'Edo State Gubernatorial 2024',
                  'Abuja FCT Senatorial 2024',
                  'Lagos LGA Chairman 2024',
                ],
                onChanged: (v) => setState(() => _selectedElection = v!),
              ),
              const SizedBox(height: 14),
              const Text(
                'YOUR QUESTION',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: TColors.secondary,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isDark ? TColors.darkCard : TColors.lightCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _charCount > 0
                        ? TColors.secondary.withOpacity(0.5)
                        : (isDark ? TColors.darkBorder : TColors.lightBorder),
                  ),
                  boxShadow: _charCount > 0
                      ? [
                          BoxShadow(
                            color: TColors.secondary.withOpacity(0.06),
                            blurRadius: 10,
                          ),
                        ]
                      : [],
                ),
                child: TextField(
                  controller: _textCtrl,
                  maxLines: 4,
                  maxLength: 280,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: isDark
                        ? TColors.textDarkPrimary
                        : TColors.textLightPrimary,
                    height: 1.5,
                  ),
                  decoration: InputDecoration(
                    hintText:
                        'Be specific. Ask about policies, voting records, '
                        'or manifesto promises…',
                    hintStyle: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: isDark
                          ? TColors.textDarkTertiary
                          : TColors.textLightTertiary,
                      height: 1.5,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(14),
                    counterStyle: TextStyle(
                      fontFamily: 'IBMPlexMono',
                      fontSize: 10,
                      color: _charCount > 250
                          ? TColors.warning
                          : (isDark
                                ? TColors.textDarkTertiary
                                : TColors.textLightTertiary),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  color: _charCount > 15
                      ? TColors.accent
                      : (isDark ? TColors.darkCard : TColors.lightCard),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _charCount > 15
                        ? TColors.accent.withOpacity(0.5)
                        : (isDark ? TColors.darkBorder : TColors.lightBorder),
                  ),
                  boxShadow: _charCount > 15
                      ? [
                          BoxShadow(
                            color: TColors.accent.withOpacity(0.3),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : [],
                ),
                child: InkWell(
                  onTap: _charCount > 15 && !_isSubmitting
                      ? () async {
                          setState(() => _isSubmitting = true);
                          await Future.delayed(const Duration(seconds: 2));
                          Navigator.pop(context);
                        }
                      : null,
                  borderRadius: BorderRadius.circular(12),
                  child: Center(
                    child: _isSubmitting
                        ? const LoadingDots()
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.send_rounded,
                                color: TColors.white,
                                size: 16,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Submit to Blockchain',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: TColors.white,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QuestionDetailSheet extends StatefulWidget {
  final ForumQuestion question;
  final Animation<double> pulseAnim;

  const QuestionDetailSheet({
    super.key,
    required this.question,
    required this.pulseAnim,
  });

  @override
  State<QuestionDetailSheet> createState() => _QuestionDetailSheetState();
}

class _QuestionDetailSheetState extends State<QuestionDetailSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _sheetCtrl;
  late Animation<double> _sheetFade;
  late Animation<Offset> _sheetSlide;

  @override
  void initState() {
    super.initState();
    _sheetCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _sheetFade = CurvedAnimation(parent: _sheetCtrl, curve: Curves.easeOut);
    _sheetSlide = Tween(
      begin: const Offset(0, 0.06),
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
    final q = widget.question;
    final isDark = THelperFunctions.isDarkMode(context);
    return FadeTransition(
      opacity: _sheetFade,
      child: SlideTransition(
        position: _sheetSlide,
        child: DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, ctrl) => Container(
            decoration: BoxDecoration(
              color: isDark ? TColors.darkSurface : TColors.lightSurface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              border: Border(
                top: BorderSide(
                  color: isDark ? TColors.darkBorder : TColors.lightBorder,
                ),
                left: BorderSide(
                  color: isDark ? TColors.darkBorder : TColors.lightBorder,
                ),
                right: BorderSide(
                  color: isDark ? TColors.darkBorder : TColors.lightBorder,
                ),
              ),
            ),
            child: ListView(
              controller: ctrl,
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? TColors.darkBorder : TColors.lightBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CustomPaint(painter: MiniLogoPainter()),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      q.candidateName,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: TColors.secondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Spacer(),
                    AccentTag(label: q.electionLevel),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  q.question,
                  style: TextStyle(
                    fontFamily: 'IBMPlexSerif',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? TColors.white : TColors.black,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      q.postedDisplay,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        color: isDark
                            ? TColors.textDarkTertiary
                            : TColors.textLightTertiary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${q.upvotes} upvotes',
                      style: const TextStyle(
                        fontFamily: 'IBMPlexMono',
                        fontSize: 11,
                        color: TColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (q.isUnanswered) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: TColors.warning.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: TColors.warning.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: CustomPaint(
                            painter: TimerArcPainter(
                              progress: q.hoursRemaining / 24.0,
                              color: q.hoursRemaining < 6
                                  ? TColors.error
                                  : TColors.warning,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${q.hoursRemaining}h ${(q.hoursRemaining * 60 % 60).round()}m remaining',
                                style: TextStyle(
                                  fontFamily: 'IBMPlexMono',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: q.hoursRemaining < 6
                                      ? TColors.error
                                      : TColors.warning,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Candidate must respond or popularity score '
                                'is reduced on-chain.',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 11,
                                  color: isDark
                                      ? TColors.textDarkTertiary
                                      : TColors.textLightTertiary,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                Container(width: 32, height: 1.5, color: TColors.secondary),
                const SizedBox(height: 16),
                if (!q.isUnanswered) ...[
                  Text(
                    'Candidate\'s Response',
                    style: TextStyle(
                      fontFamily: 'IBMPlexSerif',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isDark ? TColors.white : TColors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? TColors.darkCard : TColors.lightCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? TColors.secondary.withOpacity(0.2)
                            : TColors.lightBorder,
                      ),
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
                            Text(
                              q.candidateName,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: TColors.secondary,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'Responded in ${q.responseTime}',
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 10,
                                color: TColors.success,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          q.answerFull.isNotEmpty
                              ? q.answerFull
                              : q.answerPreview,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            color: isDark
                                ? TColors.textDarkSecondary
                                : TColors.textLightSecondary,
                            height: 1.65,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text(
                              'Rate this answer:',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                color: isDark
                                    ? TColors.textDarkTertiary
                                    : TColors.textLightTertiary,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Row(
                              children: List.generate(5, (i) {
                                return GestureDetector(
                                  onTap: () {},
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 4),
                                    child: Icon(
                                      i < q.answerRating
                                          ? Icons.star_rounded
                                          : Icons.star_outline_rounded,
                                      size: 18,
                                      color: i < q.answerRating
                                          ? TColors.secondary
                                          : (isDark
                                                ? TColors.darkBorder
                                                : TColors.lightBorder),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Center(
                    child: Column(
                      children: [
                        SizedBox(
                          width: 60,
                          height: 60,
                          child: CustomPaint(painter: HexRingPainter()),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'No response yet',
                          style: TextStyle(
                            fontFamily: 'IBMPlexSerif',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isDark ? TColors.white : TColors.black,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'The candidate has ${q.hoursRemaining}h to respond\n'
                          'before their score is penalised.',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: isDark
                                ? TColors.textDarkTertiary
                                : TColors.textLightTertiary,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FilterSheet extends StatelessWidget {
  final String currentCandidate;
  final void Function(String) onSelect;

  const FilterSheet({
    super.key,
    required this.currentCandidate,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);
    final candidates = [
      'All',
      'Monday Okpebholo',
      'Asue Ighodalo',
      'Olumide Akpata',
      'Dr. Aisha Bukar',
    ];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? TColors.darkSurface : TColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(
            color: isDark ? TColors.darkBorder : TColors.lightBorder,
          ),
          left: BorderSide(
            color: isDark ? TColors.darkBorder : TColors.lightBorder,
          ),
          right: BorderSide(
            color: isDark ? TColors.darkBorder : TColors.lightBorder,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? TColors.darkBorder : TColors.lightBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Filter by Candidate',
            style: TextStyle(
              fontFamily: 'IBMPlexSerif',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? TColors.white : TColors.black,
            ),
          ),
          const SizedBox(height: 6),
          Container(width: 32, height: 2, color: TColors.secondary),
          const SizedBox(height: 20),
          ...candidates.map(
            (c) => GestureDetector(
              onTap: () => onSelect(c),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 13,
                  horizontal: 4,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: (isDark ? TColors.darkBorder : TColors.lightBorder)
                          .withOpacity(c != candidates.last ? 1 : 0),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    if (c != 'All')
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CustomPaint(painter: MiniLogoPainter()),
                      ),
                    if (c != 'All') const SizedBox(width: 10),
                    Text(
                      c,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: currentCandidate == c
                            ? TColors.secondary
                            : (isDark
                                  ? TColors.textDarkSecondary
                                  : TColors.textLightSecondary),
                        fontWeight: currentCandidate == c
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                    const Spacer(),
                    if (currentCandidate == c)
                      const Icon(
                        Icons.check_rounded,
                        color: TColors.secondary,
                        size: 16,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
