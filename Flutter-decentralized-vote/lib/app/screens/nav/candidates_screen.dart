import 'package:flutter/material.dart';
import 'package:flutter_frontend_vote/core/utils/helper_functions.dart';
import 'package:flutter/services.dart';
import 'package:flutter_frontend_vote/core/constants/colors.dart';
import 'package:flutter_frontend_vote/core/animations/screen_animations.dart';
import 'package:flutter_frontend_vote/app/components/shapes/decorative_painters.dart';

import 'widgets/home/accent_tag.dart';
import 'widgets/candidates/candidate_models.dart';
import 'widgets/candidates/candidates_header.dart';
import 'widgets/candidates/spotlight_card.dart';
import 'widgets/candidates/candidate_list_card.dart';
import 'widgets/candidates/candidate_grid_card.dart';
import 'widgets/candidates/candidate_detail_sheet.dart';

class CandidatesScreen extends StatefulWidget {
  const CandidatesScreen({super.key});

  @override
  State<CandidatesScreen> createState() => _CandidatesScreenState();
}

class _CandidatesScreenState extends State<CandidatesScreen>
    with TickerProviderStateMixin {
  bool get isDark => THelperFunctions.isDarkMode(context);

  late AnimationController _entranceController;
  late AnimationController _shimmerController;
  late AnimationController _pulseController;
  late AnimationController _viewToggleController;
  late AnimationController _spotlightController;

  late CandidatesScreenAnimations _anims;

  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  bool _isGridView = false;
  bool _searchOpen = false;
  String _searchQuery = '';
  int _sortIndex = 0; // 0=Popularity 1=AZ 2=Region 3=Party
  int _filterParty = 0; // 0=All
  String _filterElection = 'All';

  final _searchFocus = FocusNode();
  final _searchCtrl = TextEditingController();

  static const _sortLabels = ['Popularity', 'A–Z', 'Region', 'Party'];

  @override
  void initState() {
    super.initState();
    _buildControllers();

    _anims = CandidatesScreenAnimations(
      entranceController: _entranceController,
      shimmerController: _shimmerController,
      pulseController: _pulseController,
      viewToggleController: _viewToggleController,
      spotlightController: _spotlightController,
    );

    _runEntrance();
    _scrollController.addListener(
      () => setState(() => _scrollOffset = _scrollController.offset),
    );
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
    _viewToggleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _spotlightController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
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

  void _toggleView() {
    setState(() => _isGridView = !_isGridView);
    _viewToggleController.forward(from: 0);
  }

  List<CandidateData> get _visibleCandidates {
    var list = List<CandidateData>.from(allCandidates);
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list
          .where(
            (c) =>
                c.name.toLowerCase().contains(q) ||
                c.party.toLowerCase().contains(q) ||
                c.region.toLowerCase().contains(q) ||
                c.election.toLowerCase().contains(q),
          )
          .toList();
    }
    if (_filterParty > 0) {
      final parties = ['All', 'APC', 'PDP', 'LP', 'IND', 'NNPP'];
      list = list.where((c) => c.partyCode == parties[_filterParty]).toList();
    }
    if (_filterElection != 'All') {
      list = list.where((c) => c.election.contains(_filterElection)).toList();
    }
    switch (_sortIndex) {
      case 1:
        list.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 2:
        list.sort((a, b) => a.region.compareTo(b.region));
        break;
      case 3:
        list.sort((a, b) => a.partyCode.compareTo(b.partyCode));
        break;
      default:
        list.sort((a, b) => b.approvalPct.compareTo(a.approvalPct));
    }
    return list;
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _shimmerController.dispose();
    _pulseController.dispose();
    _viewToggleController.dispose();
    _spotlightController.dispose();
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
      backgroundColor: (isDark
          ? TColors.darkBackground
          : TColors.lightBackground),
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _entranceController,
          _shimmerController,
          _pulseController,
          _spotlightController,
        ]),
        builder: (context, _) {
          return Stack(
            children: [
              _buildBackground(),

              CustomPaint(
                size: MediaQuery.of(context).size,
                painter: AuthGridPainter(
                  color: TColors.secondary.withOpacity(isDark ? 0.04 : 0.12),
                ),
              ),

              Positioned(
                top: -55,
                right: -55,
                child: Opacity(
                  opacity: isDark ? 0.055 : 0.2,
                  child: CustomPaint(
                    size: const Size(240, 240),
                    painter: HexRingPainter(
                      color: isDark ? TColors.secondary : TColors.primary.withOpacity(0.4),
                    ),
                  ),
                ),
              ),

              _buildShimmer(context),

              _buildBody(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBackground() {
    final p = (_scrollOffset * 0.00018).clamp(0.0, 0.12);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(1 - p, -1),
          end: const Alignment(-1, 1),
          colors: isDark
              ? const [
                  Color(0xFF08120A),
                  TColors.darkBackground,
                  Color(0xFF0A0A15),
                ]
              : const [
                  Color(0xFFE5F0ED),
                  TColors.lightBackground,
                  Color(0xFFE9E9F4),
                ],
          stops: const [0.0, 0.55, 1.0],
        ),
      ),
    );
  }

  Widget _buildShimmer(BuildContext context) {
    return AnimatedBuilder(
      animation: _anims.shimmerPos,
      builder: (_, __) => Positioned.fill(
        child: IgnorePointer(
          child: Transform.translate(
            offset: Offset(
              MediaQuery.of(context).size.width *
                  (_anims.shimmerPos.value - 0.5) *
                  2,
              0,
            ),
            child: Container(
              width: 140,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    TColors.secondary.withOpacity(isDark ? 0.04 : 0.1),
                    TColors.secondary.withOpacity(isDark ? 0.08 : 0.2),
                    TColors.secondary.withOpacity(isDark ? 0.04 : 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final candidates = _visibleCandidates;

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: StickyHeaderDelegate(
              minHeight: 62,
              maxHeight: 62,
              child: _buildStickyHeader(),
            ),
          ),

          SliverToBoxAdapter(child: _buildPartyFilter()),

          const SliverToBoxAdapter(child: SizedBox(height: 14)),

          if (candidates.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SpotlightCard(
                  candidate: candidates.first,
                  spotlightFade: _anims.spotlightFade,
                  spotlightSlide: _anims.spotlightSlide,
                  spotlightScale: _anims.spotlightScale,
                  spotlightGlow: _anims.spotlightGlow,
                  onTap: () => _showCandidateDetail(context, candidates.first),
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 18)),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CandidatesHeader(
                count: candidates.length,
                listFade: _anims.listFade,
                currentSortLabel: _sortLabels[_sortIndex],
                onTapSort: () => _showSortSheet(context),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 10)),

          if (_isGridView)
            _buildGridSliver(candidates)
          else
            _buildListSliver(candidates),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildStickyHeader() {
    final collapsed = (_scrollOffset / 54).clamp(0.0, 1.0);

    return FadeTransition(
      opacity: _anims.headerFade,
      child: SlideTransition(
        position: _anims.headerSlide,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          color: (isDark ? const Color(0xFF0A0F0B) : const Color(0xFFE8F0ED))
              .withOpacity(collapsed > 0.85 ? 1.0 : collapsed),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Center(
            child: Row(
              children: [
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: _searchOpen
                        ? SearchField(
                            key: const ValueKey('search'),
                            ctrl: _searchCtrl,
                            focus: _searchFocus,
                            onChanged: (v) => setState(() => _searchQuery = v),
                          )
                        : Row(
                            key: const ValueKey('title'),
                            children: [
                              Flexible(
                                child: Text(
                                  'Candidates',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'IBMPlexSerif',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: (isDark
                                        ? TColors.white
                                        : TColors.black),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Flexible(
                                child: AccentTag(label: 'ALL ELECTIONS'),
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(width: 10),

                GestureDetector(
                  onTap: _toggleSearch,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _searchOpen
                          ? TColors.secondary.withOpacity(0.12)
                          : (isDark ? TColors.darkCard : TColors.lightCard),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _searchOpen
                            ? TColors.secondary.withOpacity(0.5)
                            : (isDark ? TColors.darkBorder : TColors.lightBorder),
                      ),
                    ),
                    child: AnimatedRotation(
                      turns: _searchOpen ? 0.125 : 0,
                      duration: const Duration(milliseconds: 220),
                      child: Icon(
                        _searchOpen ? Icons.close : Icons.search_rounded,
                        color: _searchOpen
                            ? TColors.secondary
                            : (isDark
                                  ? TColors.textDarkSecondary
                                  : TColors.textLightSecondary),
                        size: 16,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

              GestureDetector(
                onTap: _toggleView,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: (isDark ? TColors.darkCard : TColors.lightCard),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: (isDark
                          ? TColors.darkBorder
                          : TColors.lightBorder),
                    ),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, anim) => ScaleTransition(
                      scale: Tween(begin: 0.7, end: 1.0).animate(anim),
                      child: child,
                    ),
                    child: Icon(
                      _isGridView
                          ? Icons.view_list_rounded
                          : Icons.grid_view_rounded,
                      key: ValueKey(_isGridView),
                      color: (isDark
                          ? TColors.textDarkSecondary
                          : TColors.textLightSecondary),
                      size: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              GestureDetector(
                onTap: () => _showSortSheet(context),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: (isDark ? TColors.darkCard : TColors.lightCard),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: (isDark
                          ? TColors.darkBorder
                          : TColors.lightBorder),
                    ),
                  ),
                  child: Icon(
                    Icons.tune_rounded,
                    color: (isDark
                        ? TColors.textDarkSecondary
                        : TColors.textLightSecondary),
                    size: 16,
                  ),
                ),
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPartyFilter() {
    final parties = ['All', 'APC', 'PDP', 'LP', 'IND', 'NNPP'];
    return FadeTransition(
      opacity: _anims.filterRowFade,
      child: SizedBox(
        height: 30,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: parties.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final on = _filterParty == i;
            return GestureDetector(
              onTap: () => setState(() => _filterParty = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 0,
                ),
                decoration: BoxDecoration(
                  color: on
                      ? TColors.primary
                      : (isDark ? TColors.darkCard : TColors.lightCard),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: on
                        ? TColors.secondary.withOpacity(0.55)
                        : (isDark ? TColors.darkBorder : TColors.lightBorder),
                    width: on ? 1.0 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      parties[i],
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        fontWeight: on ? FontWeight.w600 : FontWeight.w400,
                        color: on
                            ? TColors.secondary
                            : (isDark
                                  ? TColors.textDarkTertiary
                                  : TColors.textLightTertiary),
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: on ? 18 : 0,
                      height: 2,
                      decoration: BoxDecoration(
                        color: TColors.secondary,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  SliverList _buildListSliver(List<CandidateData> candidates) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, i) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: CandidateListCard(
            data: candidates[i],
            index: i,
            listAnim: _anims.listFade,
            pulseAnim: _anims.pulseAnim,
            onTap: () => _showCandidateDetail(context, candidates[i]),
          ),
        ),
        childCount: candidates.length,
      ),
    );
  }

  SliverPadding _buildGridSliver(List<CandidateData> candidates) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, i) => CandidateGridCard(
            data: candidates[i],
            index: i,
            listAnim: _anims.listFade,
            pulseAnim: _anims.pulseAnim,
            onTap: () => _showCandidateDetail(context, candidates[i]),
          ),
          childCount: candidates.length,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.82,
        ),
      ),
    );
  }

  void _showCandidateDetail(BuildContext context, CandidateData c) {
    showModalBottomSheet(
      context: context,
      showDragHandle: false,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) =>
          CandidateDetailSheet(candidate: c, pulseAnim: _anims.pulseAnim),
    );
  }

  void _showSortSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: false,
      backgroundColor: Colors.transparent,
      builder: (_) => SortSheet(
        currentSort: _sortIndex,
        onSelect: (i) {
          setState(() => _sortIndex = i);
          Navigator.pop(context);
        },
      ),
    );
  }
}
