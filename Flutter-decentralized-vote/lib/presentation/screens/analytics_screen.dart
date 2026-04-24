import 'package:flutter/material.dart';
import 'package:flutter_frontend_vote/core/constants/animations.dart';
import 'package:flutter_frontend_vote/core/constants/colors.dart';
import 'package:flutter_frontend_vote/presentation/widgets/Analytics_charts.dart';
import 'package:flutter_frontend_vote/presentation/widgets/Analytics_widget.dart';


class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // State variables
  String selectedElection = 'Presidential 2025';
  bool isLiveMode = true;
  bool autoRefresh = true;
  bool isDarkTheme = false;
  String selectedTimeRange = '24h';
  String selectedRegion = 'All Regions';
  double timeSliderValue = 12.0; // 12 hours

  // Filter states
  bool showAdvancedFilters = false;
  Set<String> selectedGenderFilters = {'All'};
  Set<String> selectedAgeFilters = {'All'};
  Set<String> selectedWalletFilters = {'All'};
  Set<String> selectedMethodFilters = {'All'};

  // Mock data
  final List<String> elections = [
    'Presidential 2025',
    'Governorship 2025',
    'Senate 2025',
    'House of Reps 2025',
  ];

  final List<String> regions = [
    'All Regions',
    'Lagos State',
    'Abuja FCT',
    'Kano State',
    'Rivers State',
    'Oyo State',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkTheme
          ? TColors.darkBackground
          : TColors.lightBackground,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: isDarkTheme ? TColors.darkCard : TColors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: GradientAnimation(
                child: Text(
                  'Vote Analytics',
                  style: TextStyle(
                    color: isDarkTheme ? TColors.textDark : TColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              background: Container(
                decoration: BoxDecoration(gradient: TColors.primaryGradient),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 60),
                        _buildTopControls(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Tab Bar
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverTabBarDelegate(
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
                  Tab(text: 'Charts', icon: Icon(Icons.bar_chart)),
                  Tab(text: 'Map', icon: Icon(Icons.map)),
                  Tab(text: 'Live Feed', icon: Icon(Icons.feed)),
                ],
                labelColor: TColors.primaryBlue,
                unselectedLabelColor: TColors.textSecondary,
                indicatorColor: TColors.primaryBlue,
              ),
            ),
          ),

          // Filters Section
          SliverToBoxAdapter(
            child: AnimatedContainer(
              duration: TAnimations.normal,
              height: showAdvancedFilters ? 180 : 80,
              child: _buildFiltersSection(),
            ),
          ),

          // Content
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildChartsTab(),
                _buildMapTab(),
                _buildLiveFeedTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActions(),
    );
  }

  Widget _buildTopControls() {
    return Row(
      children: [
        Expanded(
          child: CustomDropdown(
            value: selectedElection,
            items: elections,
            onChanged: (value) => setState(() => selectedElection = value!),
            isDark: true,
          ),
        ),
        const SizedBox(width: 12),
        CustomToggleButton(
          isActive: isLiveMode,
          onToggle: (value) => setState(() => isLiveMode = value),
          activeText: 'Live',
          inactiveText: 'Historical',
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () => setState(() => isDarkTheme = !isDarkTheme),
          icon: Icon(
            isDarkTheme ? Icons.light_mode : Icons.dark_mode,
            color: TColors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkTheme ? TColors.darkCard : TColors.white,
        boxShadow: [
          BoxShadow(
            color: isDarkTheme ? TColors.shadowDark : TColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: CustomDropdown(
                  value: selectedRegion,
                  items: regions,
                  onChanged: (value) => setState(() => selectedRegion = value!),
                  label: 'Region',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TimeRangeSlider(
                  value: timeSliderValue,
                  onChanged: (value) => setState(() => timeSliderValue = value),
                ),
              ),
              IconButton(
                onPressed: () =>
                    setState(() => showAdvancedFilters = !showAdvancedFilters),
                icon: AnimatedRotation(
                  turns: showAdvancedFilters ? 0.5 : 0,
                  duration: TAnimations.normal,
                  child: const Icon(Icons.expand_more),
                ),
              ),
            ],
          ),
          if (showAdvancedFilters) ...[
            const SizedBox(height: 16),
            _buildAdvancedFilters(),
          ],
        ],
      ),
    );
  }

  Widget _buildAdvancedFilters() {
    return SlideInAnimation(
      child: Column(
        children: [
          FilterChipGroup(
            title: 'Gender',
            options: const ['All', 'Male', 'Female', 'Non-binary'],
            selectedOptions: selectedGenderFilters,
            onSelectionChanged: (selected) =>
                setState(() => selectedGenderFilters = selected),
          ),
          const SizedBox(height: 8),
          FilterChipGroup(
            title: 'Age Groups',
            options: const ['All', '18-25', '26-35', '36-50', '51+'],
            selectedOptions: selectedAgeFilters,
            onSelectionChanged: (selected) =>
                setState(() => selectedAgeFilters = selected),
          ),
          const SizedBox(height: 8),
          FilterChipGroup(
            title: 'Wallet Balance',
            options: const [
              'All',
              'Low (<₦10k)',
              'Medium (₦10k-100k)',
              'High (>₦100k)',
            ],
            selectedOptions: selectedWalletFilters,
            onSelectionChanged: (selected) =>
                setState(() => selectedWalletFilters = selected),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return FadeInAnimation(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Stats Cards
            StaggeredListAnimation(
              children: [
                StatsCard(
                  title: 'Total Votes',
                  value: '2,547,832',
                  change: '+12.5%',
                  isPositive: true,
                  icon: Icons.how_to_vote,
                ),
                StatsCard(
                  title: 'Registered Voters',
                  value: '4,892,156',
                  change: '+2.1%',
                  isPositive: true,
                  icon: Icons.people,
                ),
                StatsCard(
                  title: 'Turnout Rate',
                  value: '52.1%',
                  change: '+8.2%',
                  isPositive: true,
                  icon: Icons.trending_up,
                ),
                StatsCard(
                  title: 'Disqualified',
                  value: '1,247',
                  change: '-15.3%',
                  isPositive: false,
                  icon: Icons.block,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Winner Tracker
            WinnerTracker(
              leadingCandidate: CandidateData(
                name: 'Dr. Amina Kano',
                party: 'Progressive Party',
                votes: 1247832,
                percentage: 48.9,
                avatar: 'assets/candidates/amina.jpg',
                regions: ['Lagos', 'Abuja', 'Kano'],
              ),
            ),

            const SizedBox(height: 24),

            // Top 5 Leaderboard
            LeaderboardWidget(candidates: _getMockCandidates()),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsTab() {
    return FadeInAnimation(
      delay: const Duration(milliseconds: 100),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            VoteChartsSection(
              isLiveMode: isLiveMode,
              selectedTimeRange: selectedTimeRange, selectedRegion: '',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapTab() {
    return FadeInAnimation(
      delay: const Duration(milliseconds: 200),
      child: const InteractiveMapWidget(),
    );
  }

  Widget _buildLiveFeedTab() {
    return FadeInAnimation(
      delay: const Duration(milliseconds: 300),
      child: LiveFeedWidget(isLiveMode: isLiveMode, autoRefresh: autoRefresh),
    );
  }

  Widget _buildFloatingActions() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PulseAnimation(
          child: FloatingActionButton(
            onPressed: () => _showExportOptions(),
            backgroundColor: TColors.primaryBlue,
            child: const Icon(Icons.download),
          ),
        ),
        const SizedBox(height: 12),
        FloatingActionButton(
          onPressed: () => setState(() => autoRefresh = !autoRefresh),
          backgroundColor: autoRefresh
              ? TColors.success
              : TColors.textSecondary,
          child: Icon(autoRefresh ? Icons.sync : Icons.sync_disabled),
        ),
      ],
    );
  }

  void _showExportOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => ExportOptionsSheet(
        onExportPDF: () => _exportData('PDF'),
        onExportCSV: () => _exportData('CSV'),
        onShareLink: () => _shareAnalytics(),
      ),
    );
  }

  void _exportData(String format) {
    Navigator.pop(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Exporting data as $format...')));
  }

  void _shareAnalytics() {
    Navigator.pop(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Sharing analytics link...')));
  }

  List<CandidateData> _getMockCandidates() {
    return [
      CandidateData(
        name: 'Dr. Amina Kano',
        party: 'Progressive Party',
        votes: 1247832,
        percentage: 48.9,
        avatar: '',
        regions: ['Lagos', 'Abuja'],
      ),
      CandidateData(
        name: 'Prof. John Okafor',
        party: 'Unity Party',
        votes: 832147,
        percentage: 32.7,
        avatar: '',
        regions: ['Rivers', 'Delta'],
      ),
      CandidateData(
        name: 'Hajiya Fatima Bello',
        party: 'Reform Party',
        votes: 467823,
        percentage: 18.4,
        avatar: '',
        regions: ['Kano', 'Kaduna'],
      ),
    ];
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}
