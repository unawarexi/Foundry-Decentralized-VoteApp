import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_frontend_vote/core/constants/colors.dart';
import 'package:flutter_frontend_vote/core/constants/sizes.dart';
import 'package:flutter_frontend_vote/core/animations/animations.dart';
import 'package:flutter_frontend_vote/core/constants/responsive.dart';

class VoteScreen extends StatefulWidget {
  const VoteScreen({super.key});

  @override
  State<VoteScreen> createState() => _VoteScreenState();
}

class _VoteScreenState extends State<VoteScreen> with TickerProviderStateMixin {
  int selectedElectionIndex = -1;
  String selectedFilter = 'All';

  final List<Election> elections = [
    Election(
      id: "1",
      title: "Lagos State Gubernatorial Election 2024",
      description: "Institutional election for the Governor of Lagos State. Encrypted and verifiable blockchain ballots.",
      endTime: DateTime.now().add(const Duration(days: 15)),
      totalVotes: 2847593,
      isActive: true,
      category: "National",
      location: "Lagos State, Nigeria",
      candidatesCount: 18,
      voterTurnout: 67.8,
    ),
    Election(
      id: "2",
      title: "Federal Senate - Abuja District",
      description: "Parliamentary representation election. Multi-signature validation required for results finalization.",
      endTime: DateTime.now().add(const Duration(days: 3)),
      totalVotes: 12456,
      isActive: true,
      category: "National",
      location: "Abuja FCT",
      candidatesCount: 5,
      voterTurnout: 45.2,
    ),
  ];

  final List<String> filters = ['All', 'National', 'Local', 'Corporate', 'Institutional'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? TColors.darkBackground : TColors.lightBackground,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(isDark),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(SResponsive.pagePadding(context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsOverview(isDark),
                  const SizedBox(height: TSizes.sectionSpacing),
                  _buildSectionHeader(isDark),
                  const SizedBox(height: TSizes.md),
                  _buildFilterChips(isDark),
                  const SizedBox(height: TSizes.lg),
                  _buildElectionsList(isDark),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(bool isDark) {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: TColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [TColors.primary, TColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Icon(Icons.shield_rounded, color: TColors.secondary, size: 28),
                  const SizedBox(width: 12),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'VOTESECURE',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'IBMPlexSerif',
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                        ),
                      ),
                      Text(
                        'Institutional Governance Infrastructure',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontFamily: 'Inter',
                          fontSize: 10,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsOverview(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(TSizes.md),
      decoration: BoxDecoration(
        color: isDark ? TColors.darkCard : TColors.lightCard,
        borderRadius: BorderRadius.circular(TSizes.radiusLg),
        border: Border.all(
          color: isDark ? TColors.darkBorder : TColors.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: TColors.primary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('3.2M+', 'VERIFIED VOTERS', Icons.verified_user_outlined, TColors.secondary, isDark),
          _buildStatItem('14', 'OPEN BALLOTS', Icons.ballot_outlined, TColors.primary, isDark),
          _buildStatItem('99.9%', 'UPTIME', Icons.speed_outlined, TColors.accent, isDark),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon, Color color, bool isDark) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            fontFamily: 'Inter',
            color: isDark ? TColors.textDarkPrimary : TColors.textLightPrimary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: isDark ? TColors.textDarkTertiary : TColors.textLightTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ACTIVE ELECTIONS',
          style: TextStyle(
            fontFamily: 'IBMPlexSerif',
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: isDark ? TColors.textDarkPrimary : TColors.textLightPrimary,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Select an authorized ballot to participate in the democratic process.',
          style: TextStyle(
            fontSize: 14,
            color: isDark ? TColors.textDarkSecondary : TColors.textLightSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips(bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final isSelected = selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filter.toUpperCase()),
              selected: isSelected,
              onSelected: (val) => setState(() => selectedFilter = filter),
              selectedColor: TColors.primary,
              backgroundColor: isDark ? TColors.darkElevated : TColors.lightElevated,
              labelStyle: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : (isDark ? TColors.textDarkSecondary : TColors.textLightSecondary),
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildElectionsList(bool isDark) {
    return StaggeredListAnimation(
      children: elections.map((e) => _buildElectionCard(e, isDark)).toList(),
    );
  }

  Widget _buildElectionCard(Election election, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? TColors.darkCard : TColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? TColors.darkBorder : TColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: TColors.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  election.category.toUpperCase(),
                  style: const TextStyle(color: TColors.secondary, fontSize: 10, fontWeight: FontWeight.w700),
                ),
              ),
              const Spacer(),
              const Icon(Icons.circle, color: TColors.success, size: 8),
              const SizedBox(width: 4),
              const Text('LIVE', style: TextStyle(color: TColors.success, fontSize: 10, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            election.title,
            style: TextStyle(
              fontFamily: 'IBMPlexSerif',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? TColors.textDarkPrimary : TColors.textLightPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            election.description,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? TColors.textDarkSecondary : TColors.textLightSecondary,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.access_time, size: 14, color: TColors.primary),
              const SizedBox(width: 6),
              Text(
                'CLOSES IN 12 DAYS',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: TColors.primary),
              ),
              const Spacer(),
              Text(
                '${election.totalVotes} VOTES CAST',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isDark ? TColors.textDarkTertiary : TColors.textLightTertiary),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: TColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('CAST AUTHORIZED VOTE', style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1.0)),
            ),
          ),
        ],
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
