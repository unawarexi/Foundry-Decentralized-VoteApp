import 'package:flutter/material.dart';
import 'package:flutter_frontend_vote/core/constants/animations.dart';
import 'package:flutter_frontend_vote/core/constants/colors.dart';
import 'package:flutter_slidable/flutter_slidable.dart';


// Data Models
class CandidateData {
  final String name;
  final String party;
  final int votes;
  final double percentage;
  final String avatar;
  final List<String> regions;
  final int? rankChange;

  CandidateData({
    required this.name,
    required this.party,
    required this.votes,
    required this.percentage,
    required this.avatar,
    required this.regions,
    this.rankChange,
  });
}

class VoteEvent {
  final String type;
  final String description;
  final DateTime timestamp;
  final String region;
  final bool isVerified;

  VoteEvent({
    required this.type,
    required this.description,
    required this.timestamp,
    required this.region,
    this.isVerified = true,
  });
}

// Custom Dropdown Widget
class CustomDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String? label;
  final bool isDark;

  const CustomDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.label,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? TColors.borderDark : TColors.borderLight,
        ),
        gradient: isDark ? null : TColors.primaryGradient.scale(0.1),
        color: isDark ? TColors.darkCard.withOpacity(0.3) : null,
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items
            .map(
              (item) => DropdownMenuItem(
                value: item,
                child: Text(
                  item,
                  style: TextStyle(
                    color: isDark ? TColors.textDark : TColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            )
            .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: isDark ? TColors.textDarkSecondary : TColors.textSecondary,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        dropdownColor: isDark ? TColors.darkCard : TColors.white,
        icon: Icon(
          Icons.keyboard_arrow_down,
          color: isDark ? TColors.textDark : TColors.textPrimary,
        ),
      ),
    );
  }
}

// Custom Toggle Button
class CustomToggleButton extends StatelessWidget {
  final bool isActive;
  final ValueChanged<bool> onToggle;
  final String activeText;
  final String inactiveText;

  const CustomToggleButton({
    super.key,
    required this.isActive,
    required this.onToggle,
    required this.activeText,
    required this.inactiveText,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onToggle(!isActive),
      child: AnimatedContainer(
        duration: TAnimations.normal,
        curve: TAnimations.smoothCurve,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isActive ? TColors.success : TColors.textSecondary,
          boxShadow: [
            BoxShadow(
              color: (isActive ? TColors.success : TColors.textSecondary)
                  .withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? Icons.live_tv : Icons.history,
              color: TColors.white,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              isActive ? activeText : inactiveText,
              style: const TextStyle(
                color: TColors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Time Range Slider
class TimeRangeSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const TimeRangeSlider({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Time Range: ${value.toInt()}h',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: TColors.primaryBlue,
            inactiveTrackColor: TColors.primaryBlue.withOpacity(0.3),
            thumbColor: TColors.primaryBlue,
            overlayColor: TColors.primaryBlue.withOpacity(0.2),
          ),
          child: Slider(
            value: value,
            min: 1,
            max: 24,
            divisions: 23,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

// Filter Chip Group
class FilterChipGroup extends StatelessWidget {
  final String title;
  final List<String> options;
  final Set<String> selectedOptions;
  final ValueChanged<Set<String>> onSelectionChanged;

  const FilterChipGroup({
    super.key,
    required this.title,
    required this.options,
    required this.selectedOptions,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: TColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: options.map((option) {
            final isSelected = selectedOptions.contains(option);
            return GestureDetector(
              onTap: () {
                final newSelection = Set<String>.from(selectedOptions);
                if (option == 'All') {
                  newSelection.clear();
                  newSelection.add('All');
                } else {
                  newSelection.remove('All');
                  if (isSelected) {
                    newSelection.remove(option);
                    if (newSelection.isEmpty) {
                      newSelection.add('All');
                    }
                  } else {
                    newSelection.add(option);
                  }
                }
                onSelectionChanged(newSelection);
              },
              child: AnimatedContainer(
                duration: TAnimations.fast,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: isSelected ? TColors.primaryBlue : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? TColors.primaryBlue
                        : TColors.borderLight,
                  ),
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? TColors.white : TColors.textSecondary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// Stats Card
class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final String change;
  final bool isPositive;
  final IconData icon;

  const StatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.change,
    required this.isPositive,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleAnimation(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [TColors.white, TColors.primaryBlue.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: TColors.shadowLight,
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
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: TColors.primaryGradient,
                  ),
                  child: Icon(icon, color: TColors.white, size: 24),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: (isPositive ? TColors.success : TColors.error)
                        .withOpacity(0.1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPositive ? Icons.trending_up : Icons.trending_down,
                        size: 16,
                        color: isPositive ? TColors.success : TColors.error,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        change,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isPositive ? TColors.success : TColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: TColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: TColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Winner Tracker
class WinnerTracker extends StatelessWidget {
  final CandidateData leadingCandidate;

  const WinnerTracker({super.key, required this.leadingCandidate});

  @override
  Widget build(BuildContext context) {
    return PulseAnimation(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: TColors.primaryGradient,
          boxShadow: [
            BoxShadow(
              color: TColors.primaryBlue.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            const Text(
              '🏆 CURRENTLY LEADING',
              style: TextStyle(
                color: TColors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: TColors.white,
                  child: Text(
                    leadingCandidate.name.split(' ').map((n) => n[0]).join(''),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: TColors.primaryBlue,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        leadingCandidate.name,
                        style: const TextStyle(
                          color: TColors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        leadingCandidate.party,
                        style: TextStyle(
                          color: TColors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${leadingCandidate.percentage.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        color: TColors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${leadingCandidate.votes.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} votes',
                      style: TextStyle(
                        color: TColors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: TColors.white.withOpacity(0.2),
              ),
              child: Text(
                'Leading in: ${leadingCandidate.regions.join(', ')}',
                style: TextStyle(
                  color: TColors.white.withOpacity(0.9),
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Leaderboard Widget
class LeaderboardWidget extends StatelessWidget {
  final List<CandidateData> candidates;

  const LeaderboardWidget({super.key, required this.candidates});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: TColors.white,
        boxShadow: [
          BoxShadow(
            color: TColors.shadowLight,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Top Candidates',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: TColors.textPrimary,
              ),
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: candidates.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final candidate = candidates[index];
              return Slidable(
                key: ValueKey(candidate.name),
                startActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (context) =>
                          _showCandidateDetails(context, candidate),
                      backgroundColor: TColors.info,
                      foregroundColor: TColors.white,
                      icon: Icons.info,
                      label: 'Details',
                    ),
                  ],
                ),
                endActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (context) =>
                          _shareCandidateStats(context, candidate),
                      backgroundColor: TColors.success,
                      foregroundColor: TColors.white,
                      icon: Icons.share,
                      label: 'Share',
                    ),
                  ],
                ),
                child: VotingCardAnimation(
                  isSelected: index == 0,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: index == 0 ? TColors.primaryGradient : null,
                        color: index == 0 ? null : TColors.lightCard,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: index == 0
                                ? TColors.white
                                : TColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      candidate.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: TColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      candidate.party,
                      style: const TextStyle(
                        color: TColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${candidate.percentage.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: index == 0
                                ? TColors.primaryBlue
                                : TColors.textPrimary,
                          ),
                        ),
                        Text(
                          '${candidate.votes.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                          style: const TextStyle(
                            color: TColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                        if (candidate.rankChange != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                candidate.rankChange! > 0
                                    ? Icons.arrow_upward
                                    : Icons.arrow_downward,
                                size: 12,
                                color: candidate.rankChange! > 0
                                    ? TColors.success
                                    : TColors.error,
                              ),
                              Text(
                                '${candidate.rankChange!.abs()}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: candidate.rankChange! > 0
                                      ? TColors.success
                                      : TColors.error,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showCandidateDetails(BuildContext context, CandidateData candidate) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CandidateDetailsSheet(candidate: candidate),
    );
  }

  void _shareCandidateStats(BuildContext context, CandidateData candidate) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sharing ${candidate.name}\'s stats...')),
    );
  }
}

// Live Feed Widget
class LiveFeedWidget extends StatefulWidget {
  final bool isLiveMode;
  final bool autoRefresh;

  const LiveFeedWidget({
    super.key,
    required this.isLiveMode,
    required this.autoRefresh,
  });

  @override
  State<LiveFeedWidget> createState() => _LiveFeedWidgetState();
}

class _LiveFeedWidgetState extends State<LiveFeedWidget> {
  final List<VoteEvent> events = [
    VoteEvent(
      type: 'VoteCast',
      description: 'New vote cast in Lagos State',
      timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
      region: 'Lagos',
    ),
    VoteEvent(
      type: 'RegionDeclared',
      description: 'Abuja FCT declared results',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      region: 'Abuja',
    ),
    VoteEvent(
      type: 'LeadingChanged',
      description: 'Dr. Amina Kano takes the lead',
      timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
      region: 'National',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PulseAnimation(
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.isLiveMode
                        ? TColors.success
                        : TColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Onchain Events Feed',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: TColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                'Onchain Verified',
                style: TextStyle(
                  fontSize: 12,
                  color: TColors.blockchain,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return Slidable(
                  key: ValueKey(event.timestamp),
                  startActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) => _viewEventDetails(event),
                        backgroundColor: TColors.info,
                        foregroundColor: TColors.white,
                        icon: Icons.visibility,
                        label: 'View',
                      ),
                    ],
                  ),
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) => _shareEvent(event),
                        backgroundColor: TColors.primaryBlue,
                        foregroundColor: TColors.white,
                        icon: Icons.share,
                        label: 'Share',
                      ),
                    ],
                  ),
                  child: SlideInAnimation(
                    delay: Duration(milliseconds: index * 100),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: TColors.white,
                        border: Border.all(
                          color: _getEventColor(event.type).withOpacity(0.3),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: TColors.shadowLight,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: _getEventColor(
                                event.type,
                              ).withOpacity(0.1),
                            ),
                            child: Icon(
                              _getEventIcon(event.type),
                              color: _getEventColor(event.type),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event.description,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: TColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 12,
                                      color: TColors.textSecondary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      event.region,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: TColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Icon(
                                      Icons.access_time,
                                      size: 12,
                                      color: TColors.textSecondary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _formatTimestamp(event.timestamp),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: TColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (event.isVerified)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: TColors.success.withOpacity(0.1),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.verified,
                                    size: 12,
                                    color: TColors.success,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Verified',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: TColors.success,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getEventColor(String type) {
    switch (type) {
      case 'VoteCast':
        return TColors.primaryBlue;
      case 'RegionDeclared':
        return TColors.success;
      case 'LeadingChanged':
        return TColors.warning;
      default:
        return TColors.textSecondary;
    }
  }

  IconData _getEventIcon(String type) {
    switch (type) {
      case 'VoteCast':
        return Icons.how_to_vote;
      case 'RegionDeclared':
        return Icons.flag;
      case 'LeadingChanged':
        return Icons.trending_up;
      default:
        return Icons.event;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  void _viewEventDetails(VoteEvent event) {
    // Implementation for viewing event details
  }

  void _shareEvent(VoteEvent event) {
    // Implementation for sharing event
  }
}

// Interactive Map Widget
class InteractiveMapWidget extends StatefulWidget {
  const InteractiveMapWidget({super.key});

  @override
  State<InteractiveMapWidget> createState() => _InteractiveMapWidgetState();
}

class _InteractiveMapWidgetState extends State<InteractiveMapWidget> {
  String selectedRegion = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: TColors.primaryGradient,
            ),
            child: const Row(
              children: [
                Icon(Icons.map, color: TColors.white),
                SizedBox(width: 8),
                Text(
                  'Interactive Vote Distribution Map',
                  style: TextStyle(
                    color: TColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: TColors.lightCard,
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.map_outlined,
                      size: 64,
                      color: TColors.textSecondary,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Map integration would be implemented here',
                      style: TextStyle(
                        color: TColors.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Using flutter_map, Mapbox, or similar',
                      style: TextStyle(
                        color: TColors.textSecondary,
                        fontSize: 12,
                      ),
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

// Candidate Details Sheet
class CandidateDetailsSheet extends StatelessWidget {
  final CandidateData candidate;

  const CandidateDetailsSheet({super.key, required this.candidate});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: TColors.textSecondary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: TColors.primaryBlue,
                    child: Text(
                      candidate.name.split(' ').map((n) => n[0]).join(''),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: TColors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    candidate.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: TColors.textPrimary,
                    ),
                  ),
                  Text(
                    candidate.party,
                    style: const TextStyle(
                      fontSize: 16,
                      color: TColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem('Votes', candidate.votes.toString()),
                      _buildStatItem('Percentage', '${candidate.percentage}%'),
                      _buildStatItem(
                        'Regions',
                        candidate.regions.length.toString(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: TColors.primaryBlue,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: TColors.textSecondary),
        ),
      ],
    );
  }
}

// Export Options Sheet
class ExportOptionsSheet extends StatelessWidget {
  final VoidCallback onExportPDF;
  final VoidCallback onExportCSV;
  final VoidCallback onShareLink;

  const ExportOptionsSheet({
    super.key,
    required this.onExportPDF,
    required this.onExportCSV,
    required this.onShareLink,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: TColors.textSecondary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Export Options',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: TColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          _buildExportOption(
            icon: Icons.picture_as_pdf,
            title: 'Export as PDF',
            subtitle: 'Save analytics report as PDF',
            onTap: onExportPDF,
          ),
          _buildExportOption(
            icon: Icons.table_chart,
            title: 'Export as CSV',
            subtitle: 'Download raw data as CSV',
            onTap: onExportCSV,
          ),
          _buildExportOption(
            icon: Icons.share,
            title: 'Share Link',
            subtitle: 'Share analytics dashboard link',
            onTap: onShareLink,
          ),
        ],
      ),
    );
  }

  Widget _buildExportOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: TColors.primaryBlue.withOpacity(0.1),
        ),
        child: Icon(icon, color: TColors.primaryBlue),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: TColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: TColors.textSecondary, fontSize: 12),
      ),
      onTap: onTap,
    );
  }
}
