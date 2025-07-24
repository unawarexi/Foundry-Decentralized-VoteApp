import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_frontend_vote/core/constants/colors.dart';
import 'package:flutter_frontend_vote/core/constants/animations.dart';

class VoteScreen extends StatefulWidget {
  const VoteScreen({super.key});

  @override
  State<VoteScreen> createState() => _VoteScreenState();
}

class _VoteScreenState extends State<VoteScreen> with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _pulseController;
  int selectedElectionIndex = -1;
  bool isConnected = true;
  String selectedFilter = 'All';

  // Mock data for real-world elections
  final List<Election> elections = [
    Election(
      id: "1",
      title: "Lagos State Gubernatorial Election 2024",
      description:
          "Election for the Governor of Lagos State Nigeria. Choose your preferred candidate to lead for the next 4 years.",
      endTime: DateTime.now().add(const Duration(days: 15, hours: 8)),
      totalVotes: 2847593,
      isActive: true,
      category: "State",
      location: "Lagos State, Nigeria",
      candidatesCount: 18,
      voterTurnout: 67.8,
    ),
    Election(
      id: "2",
      title: "Student Union President - University of Ibadan",
      description:
          "Election for the Student Union President to represent student interests and welfare.",
      endTime: DateTime.now().add(const Duration(days: 3, hours: 12)),
      totalVotes: 12456,
      isActive: true,
      category: "Student",
      location: "University of Ibadan",
      candidatesCount: 5,
      voterTurnout: 45.2,
    ),
    Election(
      id: "3",
      title: "Oyo State House of Assembly - Ibadan North",
      description:
          "Representative election for Ibadan North Constituency in the Oyo State House of Assembly.",
      endTime: DateTime.now().add(const Duration(days: 8, hours: 4)),
      totalVotes: 89234,
      isActive: true,
      category: "Local",
      location: "Ibadan North, Oyo State",
      candidatesCount: 7,
      voterTurnout: 52.3,
    ),
    Election(
      id: "4",
      title: "Municipal Council Chairman - Ibadan",
      description:
          "Election for the Chairman of Ibadan Municipal Council to oversee local government affairs.",
      endTime: DateTime.now().add(const Duration(days: 22, hours: 16)),
      totalVotes: 156789,
      isActive: true,
      category: "Municipal",
      location: "Ibadan Municipality",
      candidatesCount: 12,
      voterTurnout: 38.9,
    ),
  ];

  final List<String> filters = [
    'All',
    'State',
    'Local',
    'Municipal',
    'Student',
  ];

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _headerController.repeat(reverse: true);
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _headerController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  List<Election> get filteredElections {
    if (selectedFilter == 'All') return elections;
    return elections.where((e) => e.category == selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: isDark
            ? TColors
                  .darkBackground // Dark background in dark mode
            : TColors.lightBackground, // Light background in light mode
        statusBarIconBrightness: isDark
            ? Brightness
                  .light // Light icons for dark background
            : Brightness.dark, // Dark icons for light background
        statusBarBrightness: isDark
            ? Brightness
                  .dark // For iOS: text/icon color on status bar
            : Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: isDark
            ? TColors.darkBackground
            : TColors.lightBackground,
        body: CustomScrollView(
          slivers: [
            // Animated App Bar
            SliverAppBar(
              expandedHeight: 70,
              floating: false,
              pinned: true,
              backgroundColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                background: GradientAnimation(
                  colors: const [
                    TColors.primaryBlue,
                    TColors.primaryPurple,
                    TColors.primaryIndigo,
                  ],
                  duration: const Duration(seconds: 4),
                  child: Container(
                    decoration: BoxDecoration(gradient: TColors.primaryGradient),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FadeInAnimation(
                              delay: const Duration(milliseconds: 200),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.how_to_vote_rounded,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'VoteSecure',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Transparent Democratic Elections',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.8),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  _buildConnectionStatus(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
      
            // Main Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats Overview
                    FadeInAnimation(
                      delay: const Duration(milliseconds: 400),
                      child: _buildStatsOverview(isDark),
                    ),
      
                    const SizedBox(height: 30),
      
                    // Election Information Banner
                    FadeInAnimation(
                      delay: const Duration(milliseconds: 500),
                      child: _buildElectionInfoBanner(isDark),
                    ),
      
                    const SizedBox(height: 30),
      
               // Section Title, Subtitle and Filter
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        SlideInAnimation(
                          delay: const Duration(milliseconds: 600),
                          beginOffset: const Offset(-0.3, 0),
                          child: Text(
                            'Active Elections',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? TColors.textDark
                                  : TColors.textPrimary,
                            ),
                          ),
                        ),
      
                        const SizedBox(height: 4),
      
                        // Subtitle
                        SlideInAnimation(
                          delay: const Duration(milliseconds: 700),
                          beginOffset: const Offset(-0.3, 0),
                          child: Text(
                            'Your voice matters in democracy',
                            style: TextStyle(
                              fontSize: 16,
                              color: isDark
                                  ? TColors.textDarkSecondary
                                  : TColors.textSecondary,
                            ),
                          ),
                        ),
      
                        const SizedBox(height: 12),
      
                        // Filter Chips below the texts
                        SlideInAnimation(
                          delay: const Duration(milliseconds: 800),
                          beginOffset: const Offset(0.3, 0),
                          child: _buildFilterChips(isDark),
                        ),
                      ],
                    ),
      
                    const SizedBox(height: 30),
      
                    // Elections List
                    StaggeredListAnimation(
                      staggerDelay: const Duration(milliseconds: 200),
                      children: filteredElections.asMap().entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: _buildElectionCard(
                            entry.value,
                            entry.key,
                            isDark,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionStatus() {
    return PulseAnimation(
      duration: const Duration(milliseconds: 1500),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isConnected
              ? TColors.success.withOpacity(0.2)
              : TColors.error.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isConnected ? TColors.success : TColors.error,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isConnected ? TColors.success : TColors.error,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              isConnected ? 'Verified' : 'Offline',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

Widget _buildStatsOverview(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            TColors.primaryBlue.withOpacity(isDark ? 0.08 : 0.04),
            TColors.primaryPurple.withOpacity(isDark ? 0.08 : 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: TColors.primaryBlue.withOpacity(isDark ? 0.25 : 0.15),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              '3.2M+',
              'Registered Voters',
              Icons.people_alt_rounded,
              TColors.primaryBlue,
              isDark,
            ),
          ),
          _verticalDivider(isDark),
          Expanded(
            child: _buildStatItem(
              '${elections.length}',
              'Active Elections',
              Icons.ballot_outlined,
              TColors.primaryPurple,
              isDark,
            ),
          ),
          _verticalDivider(isDark),
          Expanded(
            child: _buildStatItem(
              '99.8%',
              'System Integrity',
              Icons.verified_user_rounded,
              TColors.success,
              isDark,
            ),
          ),
        ],
      ),
    );
  }
Widget _verticalDivider(bool isDark) {
    return Container(
      width: 1,
      height: 36,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: (isDark ? TColors.borderLight : Colors.grey.shade300).withOpacity(
        0.5,
      ),
    );
  }


  Widget _buildElectionInfoBanner(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? TColors.warning.withOpacity(0.1)
            : TColors.warning.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TColors.warning.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: TColors.warning.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.info_outline_rounded,
              color: TColors.warning,
              size: 18,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Election Security Notice',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isDark ? TColors.textDark : TColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'All votes are encrypted and verifiable. Your identity remains anonymous while ensuring vote integrity.',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? TColors.textDarkSecondary
                        : TColors.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(bool isDark) {
    return Wrap(
      spacing: 8,
      children: filters.map((filter) {
        final isSelected = selectedFilter == filter;
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedFilter = filter;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected
                  ? TColors.primaryBlue
                  : (isDark ? Colors.grey.shade800 : Colors.grey.shade100),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? TColors.primaryBlue
                    : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                width: 1,
              ),
            ),
            child: Text(
              filter,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : (isDark ? TColors.textDark : TColors.textPrimary),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatItem(
    String value,
    String label,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Column(
      children: [
        ScaleAnimation(
          delay: const Duration(milliseconds: 300),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? TColors.textDark : TColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isDark ? TColors.textDarkSecondary : TColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildElectionCard(Election election, int index, bool isDark) {
    final isSelected = selectedElectionIndex == index;

    return VotingCardAnimation(
      isSelected: isSelected,
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedElectionIndex = isSelected ? -1 : index;
          });
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? TColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? TColors.primaryBlue.withOpacity(0.5)
                  : (isDark
                        ? TColors.borderLight.withOpacity(0.2)
                        : Colors.grey.shade200),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: _getCategoryGradient(election.category),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      election.category,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  PulseAnimation(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: TColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.circle,
                        color: TColors.success,
                        size: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'ACTIVE',
                    style: TextStyle(
                      color: TColors.success,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Text(
                election.title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? TColors.textDark : TColors.textPrimary,
                ),
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: isDark
                        ? TColors.textDarkSecondary
                        : TColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    election.location,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? TColors.textDarkSecondary
                          : TColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Text(
                election.description,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? TColors.textDarkSecondary
                      : TColors.textSecondary,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 20),

              // Election Stats Row
              Row(
                children: [
                  _buildElectionStat(
                    Icons.people_outline,
                    '${election.candidatesCount}',
                    'Candidates',
                    isDark,
                  ),
                  const SizedBox(width: 20),
                  _buildElectionStat(
                    Icons.trending_up,
                    '${election.voterTurnout.toStringAsFixed(1)}%',
                    'Turnout',
                    isDark,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Timer and Vote Count
              Row(
                children: [
                  Expanded(
                    child: _buildTimeRemaining(election.endTime, isDark),
                  ),
                  const SizedBox(width: 20),
                  _buildVoteCount(election.totalVotes, isDark),
                ],
              ),

              const SizedBox(height: 20),

              // Vote Button
              BlockchainAnimation(
                isProcessing: false,
                child: SizedBox(
                    child: GestureDetector(
                      onTap: () => _handleVote(election),
                      child: Container(
                         width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: TColors.primaryGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.how_to_vote_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Cast Your Vote',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
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
        ),
      ),
    );
  }

  Widget _buildElectionStat(
    IconData icon,
    String value,
    String label,
    bool isDark,
  ) {
    return Row(
      children: [
        Icon(icon, size: 16, color: TColors.primaryBlue),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? TColors.textDark : TColors.textPrimary,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? TColors.textDarkSecondary
                    : TColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeRemaining(DateTime endTime, bool isDark) {
    final remaining = endTime.difference(DateTime.now());
    final days = remaining.inDays;
    final hours = remaining.inHours % 24;
    final minutes = remaining.inMinutes % 60;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Voting Ends In',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? TColors.textDarkSecondary : TColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${days}d ${hours}h ${minutes}m',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: TColors.warning,
          ),
        ),
      ],
    );
  }

  Widget _buildVoteCount(int totalVotes, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'Votes Cast',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? TColors.textDarkSecondary : TColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _formatNumber(totalVotes),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? TColors.textDark : TColors.textPrimary,
          ),
        ),
      ],
    );
  }

  LinearGradient _getCategoryGradient(String category) {
    switch (category) {
      case 'State':
        return const LinearGradient(
          colors: [TColors.primaryBlue, TColors.primaryPurple],
        );
      case 'Local':
        return const LinearGradient(
          colors: [TColors.success, Color(0xFF10B981)],
        );
      case 'Municipal':
        return const LinearGradient(
          colors: [TColors.warning, Color(0xFFF59E0B)],
        );
      case 'Student':
        return const LinearGradient(
          colors: [TColors.primaryPurple, TColors.primaryIndigo],
        );
      default:
        return TColors.primaryGradient;
    }
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  void _handleVote(Election election) {
    // Handle vote logic here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening secure voting interface for ${election.title}'),
        backgroundColor: TColors.success,
      ),
    );
  }
}

class Election {
  final String id;
  final String title;
  final String description;
  final DateTime endTime;
  final int totalVotes;
  final bool isActive;
  final String category;
  final String location;
  final int candidatesCount;
  final double voterTurnout;

  Election({
    required this.id,
    required this.title,
    required this.description,
    required this.endTime,
    required this.totalVotes,
    required this.isActive,
    required this.category,
    required this.location,
    required this.candidatesCount,
    required this.voterTurnout,
  });
}
