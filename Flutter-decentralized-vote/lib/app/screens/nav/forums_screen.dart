import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_frontend_vote/core/constants/colors.dart';
import 'package:flutter_frontend_vote/core/constants/sizes.dart';
import 'package:flutter_frontend_vote/core/animations/screen_animations.dart';
import 'package:flutter_frontend_vote/core/utils/helper_functions.dart';

// ── Extracted widgets ─────────────────────────────────────────
import 'widgets/forums/data_models.dart';
import 'widgets/forums/painters.dart';
import 'widgets/forums/atomic_widgets.dart';
import 'widgets/forums/sheets.dart';
import 'widgets/forums/forum_question_card.dart';
import 'widgets/forums/scoreboard_row.dart';
import 'widgets/forums/sticky_header.dart';
import 'widgets/forums/scoreboard_strip.dart';
import 'widgets/forums/forum_empty_state.dart';
import 'widgets/forums/forum_background.dart';
import 'widgets/forums/ask_question_fab.dart';

/// VoteSecure — Forum Screen (Tab 4)
///
/// The public accountability chamber. Citizens ask questions.
/// Candidates must respond within 24 hours or face automatic
/// popularity penalties enforced by smart contract.
class ForumScreen extends StatefulWidget {
  const ForumScreen({super.key});

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen>
    with TickerProviderStateMixin {
  bool get isDark => THelperFunctions.isDarkMode(context);

  // ── Animation Bundle (refactored from local controllers) ──
  late AnimationController _entranceController;
  late AnimationController _shimmerController;
  late AnimationController _pulseController;
  late AnimationController _fabController;
  late AnimationController _countdownController;

  late ForumScreenAnimations _animations;

  // ── Scroll ───────────────────────────────────────────────────────────────
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  // ── State ────────────────────────────────────────────────────────────────
  int _tabIndex = 0; // 0=Hot 1=New 2=Unanswered 3=My Questions
  bool _searchOpen = false;
  String _searchQuery = '';
  String _filterCandidate = 'All';

  final _searchFocus = FocusNode();
  final _searchCtrl = TextEditingController();

  // Upvote state per question
  final Map<int, bool> _upvoted = {};
  final Map<int, int> _upvoteCounts = {};

  @override
  void initState() {
    super.initState();

    // Seed upvote counts from data
    for (final q in allQuestions) {
      _upvoteCounts[q.id] = q.upvotes;
      _upvoted[q.id] = false;
    }

    _buildControllers();
    _animations = ForumScreenAnimations(
      entranceController: _entranceController,
      shimmerController: _shimmerController,
      pulseController: _pulseController,
      fabController: _fabController,
    );
    _runEntrance();

    _scrollController.addListener(
      () => setState(() => _scrollOffset = _scrollController.offset),
    );

    _countdownController.addListener(() {
      if (_countdownController.value >= 1.0) {
        setState(() {}); // rebuild timer arcs each second
      }
    });
  }

  void _buildControllers() {
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _countdownController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  Future<void> _runEntrance() async {
    await Future.delayed(const Duration(milliseconds: 60));
    _entranceController.forward();
    await Future.delayed(const Duration(milliseconds: 700));
    _shimmerController.forward();
  }

  void _toggleSearch() {
    setState(() => _searchOpen = !_searchOpen);
    if (_searchOpen) {
      Future.delayed(
        const Duration(milliseconds: 250),
        () => _searchFocus.requestFocus(),
      );
    } else {
      _searchFocus.unfocus();
      _searchCtrl.clear();
      setState(() => _searchQuery = '');
    }
  }

  void _toggleUpvote(int id) {
    setState(() {
      final wasUpvoted = _upvoted[id] ?? false;
      _upvoted[id] = !wasUpvoted;
      _upvoteCounts[id] = (_upvoteCounts[id] ?? 0) + (wasUpvoted ? -1 : 1);
    });
  }

  List<ForumQuestion> get _visibleQuestions {
    var list = List<ForumQuestion>.from(allQuestions);

    // Tab filter
    switch (_tabIndex) {
      case 1: // New
        list.sort((a, b) => b.postedAgo.compareTo(a.postedAgo));
        break;
      case 2: // Unanswered
        list = list.where((q) => q.isUnanswered).toList();
        break;
      case 3: // My Questions
        list = list.where((q) => q.isOwn).toList();
        break;
      default: // Hot
        list.sort((a, b) => b.upvotes.compareTo(a.upvotes));
    }

    // Search filter
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list
          .where(
            (item) =>
                item.question.toLowerCase().contains(q) ||
                item.candidateName.toLowerCase().contains(q) ||
                item.election.toLowerCase().contains(q),
          )
          .toList();
    }

    // Candidate filter
    if (_filterCandidate != 'All') {
      list = list.where((q) => q.candidateName == _filterCandidate).toList();
    }

    return list;
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _shimmerController.dispose();
    _pulseController.dispose();
    _countdownController.dispose();
    _fabController.dispose();
    _scrollController.dispose();
    _searchFocus.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
    );
    return Scaffold(
      backgroundColor: isDark
          ? TColors.darkBackground
          : TColors.lightBackground,
      floatingActionButton: AskQuestionFAB(
        entrance: _animations.fabEntrance,
        float: _animations.fabFloat,
        pulse: _animations.pulseAnim,
        onTap: () => _showAskSheet(context),
      ),
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _entranceController,
          _shimmerController,
          _pulseController,
        ]),
        builder: (context, _) {
          return Stack(
            children: [
              ForumBackground(
                scrollOffset: _scrollOffset,
                shimmerPos: _animations.shimmerPos,
              ),
              _buildBody(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final questions = _visibleQuestions;

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: StickyHeaderDelegate(
              minHeight: 108,
              maxHeight: 108,
              child: ForumStickyHeader(
                scrollOffset: _scrollOffset,
                headerFade: _animations.headerFade,
                headerSlide: _animations.headerSlide,
                searchOpen: _searchOpen,
                searchCtrl: _searchCtrl,
                searchFocus: _searchFocus,
                filterCandidate: _filterCandidate,
                onToggleSearch: _toggleSearch,
                onShowFilter: () => _showFilterSheet(context),
                onSearchChanged: (v) => setState(() => _searchQuery = v),
                tabIndex: _tabIndex,
                onTabChanged: (i) => setState(() => _tabIndex = i),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: TSizes.md)),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: TSizes.pagePadding,
              ),
              child: ScoreboardStrip(
                scoreboardFade: _animations.scoreboardFade,
                scoreboardSlide: _animations.scoreboardSlide,
                pulseAnim: _animations.pulseAnim,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 22)),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: TSizes.pagePadding,
              ),
              child: ForumSectionLabel(
                label: [
                  'HOT QUESTIONS',
                  'NEW QUESTIONS',
                  'UNANSWERED',
                  'MY QUESTIONS',
                ][_tabIndex],
                count: questions.length,
                opacity: _animations.listFade,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: TSizes.md)),

          if (questions.isEmpty)
            SliverToBoxAdapter(
              child: ForumEmptyState(listAnim: _animations.listFade),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => Padding(
                  padding: const EdgeInsets.fromLTRB(
                    TSizes.pagePadding,
                    0,
                    TSizes.pagePadding,
                    12,
                  ),
                  child: ForumQuestionCard(
                    question: questions[i],
                    index: i,
                    listAnim: _animations.listFade,
                    pulseAnim: _animations.pulseAnim,
                    isUpvoted: _upvoted[questions[i].id] ?? false,
                    upvoteCount:
                        _upvoteCounts[questions[i].id] ?? questions[i].upvotes,
                    onUpvote: () => _toggleUpvote(questions[i].id),
                    onTap: () => _showQuestionDetail(context, questions[i]),
                  ),
                ),
                childCount: questions.length,
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  void _showAskSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: false,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const AskQuestionSheet(),
    );
  }

  void _showQuestionDetail(BuildContext context, ForumQuestion q) {
    showModalBottomSheet(
      context: context,
      showDragHandle: false,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) =>
          QuestionDetailSheet(question: q, pulseAnim: _animations.pulseAnim),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: false,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterSheet(
        currentCandidate: _filterCandidate,
        onSelect: (c) {
          setState(() => _filterCandidate = c);
          Navigator.pop(context);
        },
      ),
    );
  }
}
