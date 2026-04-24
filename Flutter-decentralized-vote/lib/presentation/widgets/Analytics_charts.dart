import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_frontend_vote/core/constants/animations.dart';
import 'package:flutter_frontend_vote/core/constants/colors.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:fl_chart/fl_chart.dart';


// Data Models for Charts
class ChartData {
  final String category;
  double value;
  final Color color;

  ChartData({required this.category, required this.value, required this.color});
}

class TimeSeriesData {
  final DateTime time;
  final double votes;
  final String candidate;
  final Color color;

  TimeSeriesData({
    required this.time,
    required this.votes,
    required this.candidate,
    required this.color,
  });
}

class RegionalData {
  final String region;
  final double votes;
  final String leadingCandidate;
  final Color color;
  final double turnoutRate;

  RegionalData({
    required this.region,
    required this.votes,
    required this.leadingCandidate,
    required this.color,
    required this.turnoutRate,
  });
}

class EventMarker {
  final DateTime time;
  final String event;
  final String description;
  final Color color;

  EventMarker({
    required this.time,
    required this.event,
    required this.description,
    required this.color,
  });
}

class VoteChartsSection extends StatefulWidget {
  final bool isLiveMode;
  final String selectedTimeRange;
  final String selectedRegion;
  final Set<String> selectedFilters;

  const VoteChartsSection({
    super.key,
    required this.isLiveMode,
    required this.selectedTimeRange,
    required this.selectedRegion,
    this.selectedFilters = const {'All'},
  });

  @override
  State<VoteChartsSection> createState() => _VoteChartsSectionState();
}

class _VoteChartsSectionState extends State<VoteChartsSection>
    with TickerProviderStateMixin {
  late TabController _chartTabController;
  late AnimationController _pulseController;
  late Timer? _refreshTimer;

  String selectedChartType = 'Overview';
  bool showEventMarkers = true;
  double timelinePosition = 0.5;

  final List<String> chartTypes = [
    'Overview',
    'Trends',
    'Distribution',
    'Regional',
  ];

  // Mock data with enhanced structure
  final List<ChartData> pieChartData = [
    ChartData(
      category: 'Dr. Amina Kano',
      value: 48.9,
      color: TColors.primaryBlue,
    ),
    ChartData(
      category: 'Prof. John Okafor',
      value: 32.7,
      color: TColors.primaryPurple,
    ),
    ChartData(
      category: 'Hajiya Fatima Bello',
      value: 18.4,
      color: TColors.primaryIndigo,
    ),
  ];

  final List<RegionalData> regionalData = [
    RegionalData(
      region: 'Lagos State',
      votes: 2547832,
      leadingCandidate: 'Dr. Amina Kano',
      color: TColors.primaryBlue,
      turnoutRate: 67.8,
    ),
    RegionalData(
      region: 'Kano State',
      votes: 1892456,
      leadingCandidate: 'Hajiya Fatima Bello',
      color: TColors.primaryIndigo,
      turnoutRate: 78.9,
    ),
    RegionalData(
      region: 'Rivers State',
      votes: 1456789,
      leadingCandidate: 'Prof. John Okafor',
      color: TColors.primaryPurple,
      turnoutRate: 52.3,
    ),
    RegionalData(
      region: 'Abuja FCT',
      votes: 892345,
      leadingCandidate: 'Dr. Amina Kano',
      color: TColors.primaryBlue,
      turnoutRate: 71.2,
    ),
  ];

  final List<EventMarker> eventMarkers = [
    EventMarker(
      time: DateTime.now().subtract(const Duration(hours: 4)),
      event: 'Voting Halted',
      description: 'Technical issues in Lagos',
      color: TColors.error,
    ),
    EventMarker(
      time: DateTime.now().subtract(const Duration(hours: 2)),
      event: 'Ballot Drop',
      description: 'New votes from Rivers State',
      color: TColors.success,
    ),
    EventMarker(
      time: DateTime.now().subtract(const Duration(minutes: 30)),
      event: 'Leading Changed',
      description: 'Dr. Amina takes the lead',
      color: TColors.warning,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _chartTabController = TabController(length: chartTypes.length, vsync: this);
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    if (widget.isLiveMode) {
      _startLiveUpdates();
    }
  }

  void _startLiveUpdates() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted && widget.isLiveMode) {
        setState(() {
          // Simulate live data updates
          _updateMockData();
        });
      }
    });
  }

  void _updateMockData() {
    final random = Random();
    // Simulate vote count increases
    for (var data in pieChartData) {
      data.value += random.nextDouble() * 0.5;
    }
  }

  @override
  void dispose() {
    _chartTabController.dispose();
    _pulseController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(VoteChartsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLiveMode != oldWidget.isLiveMode) {
      if (widget.isLiveMode) {
        _startLiveUpdates();
      } else {
        _refreshTimer?.cancel();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Chart Controls Bar
        _buildChartControls(),

        // Chart Type Selector
        Container(
          height: 50,
          margin: const EdgeInsets.only(bottom: 20),
          child: TabBar(
            controller: _chartTabController,
            isScrollable: true,
            tabs: chartTypes
                .map(
                  (type) => Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_getChartIcon(type), size: 16),
                        const SizedBox(width: 4),
                        Text(type),
                      ],
                    ),
                  ),
                )
                .toList(),
            labelColor: TColors.primaryBlue,
            unselectedLabelColor: TColors.textSecondary,
            indicatorColor: TColors.primaryBlue,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),

        // Charts Content
        SizedBox(
          height: 700,
          child: TabBarView(
            controller: _chartTabController,
            children: [
              _buildOverviewCharts(),
              _buildTrendCharts(),
              _buildDistributionCharts(),
              _buildRegionalCharts(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChartControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: TColors.white,
        boxShadow: [
          BoxShadow(
            color: TColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Live Indicator
              if (widget.isLiveMode)
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: TColors.success.withOpacity(
                          0.1 + 0.1 * _pulseController.value,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: TColors.success,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'LIVE',
                            style: TextStyle(
                              color: TColors.success,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              const Spacer(),
              // Event Markers Toggle
              InkWell(
                onTap: () =>
                    setState(() => showEventMarkers = !showEventMarkers),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: showEventMarkers
                        ? TColors.primaryBlue.withOpacity(0.1)
                        : TColors.textSecondary.withOpacity(0.1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.event,
                        size: 14,
                        color: showEventMarkers
                            ? TColors.primaryBlue
                            : TColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Events',
                        style: TextStyle(
                          color: showEventMarkers
                              ? TColors.primaryBlue
                              : TColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Timeline Slider
          _buildTimelineSlider(),
        ],
      ),
    );
  }

  Widget _buildTimelineSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Timeline View',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: TColors.textSecondary,
              ),
            ),
            const Spacer(),
            Text(
              _getTimeRangeText(),
              style: const TextStyle(
                fontSize: 11,
                color: TColors.primaryBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: TColors.primaryBlue,
            inactiveTrackColor: TColors.primaryBlue.withOpacity(0.3),
            thumbColor: TColors.primaryBlue,
            overlayColor: TColors.primaryBlue.withOpacity(0.2),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            trackHeight: 4,
          ),
          child: Slider(
            value: timelinePosition,
            onChanged: (value) => setState(() => timelinePosition = value),
            divisions: 100,
          ),
        ),
      ],
    );
  }

  String _getTimeRangeText() {
    final totalHours = 24;
    final currentHour = (timelinePosition * totalHours).round();
    final startTime = DateTime.now().subtract(
      Duration(hours: totalHours - currentHour),
    );
    final endTime = DateTime.now();

    return '${_formatTime(startTime)} - ${_formatTime(endTime)}';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  IconData _getChartIcon(String type) {
    switch (type) {
      case 'Overview':
        return Icons.dashboard;
      case 'Trends':
        return Icons.trending_up;
      case 'Distribution':
        return Icons.pie_chart;
      case 'Regional':
        return Icons.map;
      default:
        return Icons.bar_chart;
    }
  }

  Widget _buildOverviewCharts() {
    return SingleChildScrollView(
      child: StaggeredListAnimation(
        children: [
          // Real-time Vote Count with Enhanced Features
          ScaleAnimation(
            child: ChartContainer(
              title: 'Real-time Vote Trends',
              subtitle: 'Live vote counting across all candidates',
              isLive: widget.isLiveMode,
              child: SizedBox(height: 300, child: _buildEnhancedLineChart()),
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              // Vote Distribution Pie Chart
              Expanded(
                child: ScaleAnimation(
                  delay: const Duration(milliseconds: 200),
                  child: ChartContainer(
                    title: 'Vote Share',
                    subtitle: 'Current distribution by candidate',
                    child: SizedBox(
                      height: 350,
                      child: _buildEnhancedPieChart(),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Top Candidates Bar Chart
              Expanded(
                child: ScaleAnimation(
                  delay: const Duration(milliseconds: 400),
                  child: ChartContainer(
                    title: 'Vote Comparison',
                    subtitle: 'Total votes by candidate',
                    child: SizedBox(height: 350, child: _buildBarChart()),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Fraud & Security Metrics
          ScaleAnimation(
            delay: const Duration(milliseconds: 600),
            child: ChartContainer(
              title: 'Security & Integrity Metrics',
              subtitle: 'Fraud detection and vote verification stats',
              child: SizedBox(height: 200, child: _buildSecurityMetrics()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedLineChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 500000,
          verticalInterval: 2,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: TColors.borderLight,
              strokeWidth: 1,
              dashArray: [5, 5],
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: TColors.borderLight,
              strokeWidth: 1,
              dashArray: [5, 5],
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 35,
              interval: 2,
              getTitlesWidget: (double value, TitleMeta meta) {
                const style = TextStyle(
                  color: TColors.textSecondary,
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                );
                final hours = ['8AM', '10AM', '12PM', '2PM', '4PM', '6PM'];
                final index = (value / 2).round();
                if (index >= 0 && index < hours.length) {
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(hours[index], style: style),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1000000,
              getTitlesWidget: (double value, TitleMeta meta) {
                return Text(
                  '${(value / 1000000).toStringAsFixed(1)}M',
                  style: const TextStyle(
                    color: TColors.textSecondary,
                    fontWeight: FontWeight.w500,
                    fontSize: 10,
                  ),
                );
              },
              reservedSize: 45,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: TColors.borderLight, width: 1),
        ),
        minX: 0,
        maxX: 10,
        minY: 0,
        maxY: 4000000,
        lineBarsData: [
          // Dr. Amina Kano
          LineChartBarData(
            spots: _generateCandidateVoteData('Amina'),
            gradient: LinearGradient(
              colors: [
                TColors.primaryBlue,
                TColors.primaryBlue.withOpacity(0.7),
              ],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: TColors.primaryBlue,
                  strokeWidth: 2,
                  strokeColor: TColors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  TColors.primaryBlue.withOpacity(0.3),
                  TColors.primaryBlue.withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Prof. John Okafor
          LineChartBarData(
            spots: _generateCandidateVoteData('John'),
            gradient: LinearGradient(
              colors: [
                TColors.primaryPurple,
                TColors.primaryPurple.withOpacity(0.7),
              ],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: TColors.primaryPurple,
                  strokeWidth: 2,
                  strokeColor: TColors.white,
                );
              },
            ),
          ),
          // Hajiya Fatima Bello
          LineChartBarData(
            spots: _generateCandidateVoteData('Fatima'),
            gradient: LinearGradient(
              colors: [
                TColors.primaryIndigo,
                TColors.primaryIndigo.withOpacity(0.7),
              ],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: TColors.primaryIndigo,
                  strokeWidth: 2,
                  strokeColor: TColors.white,
                );
              },
            ),
          ),
        ],
        // Event Markers
        extraLinesData: showEventMarkers
            ? ExtraLinesData(
                verticalLines: eventMarkers.map((marker) {
                  final timeIndex = _getTimeIndex(marker.time);
                  return VerticalLine(
                    x: timeIndex,
                    color: marker.color,
                    strokeWidth: 2,
                    dashArray: [8, 4],
                    label: VerticalLineLabel(
                      show: true,
                      labelResolver: (line) => marker.event,
                      style: TextStyle(
                        color: marker.color,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }).toList(),
              )
            : null,
      ),
    );
  }

  double _getTimeIndex(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time).inHours;
    return (10 - diff).clamp(0, 10).toDouble();
  }

  List<FlSpot> _generateCandidateVoteData(String candidate) {
    final random = Random(candidate.hashCode);
    final baseValue = candidate == 'Amina'
        ? 2000000
        : candidate == 'John'
        ? 1300000
        : 800000;

    return List.generate(6, (index) {
      final value =
          baseValue + (index * 200000) + (random.nextDouble() * 300000);
      return FlSpot(index * 2.0, value);
    });
  }

  Widget _buildEnhancedPieChart() {
    return SfCircularChart(
      legend: Legend(
        isVisible: true,
        position: LegendPosition.bottom,
        textStyle: const TextStyle(fontSize: 11),
        orientation: LegendItemOrientation.horizontal,
      ),
      tooltipBehavior: TooltipBehavior(
        enable: true,
        format: 'point.x: point.y votes (point.y%)',
        textStyle: const TextStyle(fontSize: 12),
      ),
      series: <CircularSeries>[
        DoughnutSeries<ChartData, String>(
          dataSource: pieChartData,
          xValueMapper: (ChartData data, _) => data.category,
          yValueMapper: (ChartData data, _) => data.value,
          pointColorMapper: (ChartData data, _) => data.color,
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            labelPosition: ChartDataLabelPosition.outside,
            textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
            connectorLineSettings: ConnectorLineSettings(
              type: ConnectorType.curve,
              length: '10%',
            ),
          ),
          enableTooltip: true,
          animationDuration: 1500,
          explode: true,
          explodeIndex: 0,
          explodeOffset: '8%',
          innerRadius: '40%',
          radius: '85%',
          strokeColor: TColors.white,
          strokeWidth: 3,
        ),
      ],
      centerY: '50%',
      centerX: '50%',
    );
  }

  Widget _buildBarChart() {
    return SfCartesianChart(
      primaryXAxis: CategoryAxis(
        labelStyle: const TextStyle(fontSize: 10),
        majorGridLines: const MajorGridLines(width: 0),
      ),
      primaryYAxis: NumericAxis(
        numberFormat: NumberFormat.compact(),
        labelStyle: const TextStyle(fontSize: 10),
        majorGridLines: MajorGridLines(
          color: TColors.borderLight.withOpacity(0.5),
        ),
      ),
      tooltipBehavior: TooltipBehavior(
        enable: true,
        format: 'point.x: point.y votes',
      ),
      series: <CartesianSeries>[
        ColumnSeries<ChartData, String>(
          dataSource: pieChartData,
          xValueMapper: (ChartData data, _) => data.category.split(' ').last,
          yValueMapper: (ChartData data, _) =>
              data.value * 52000, // Convert to actual votes
          pointColorMapper: (ChartData data, _) => data.color,
          animationDuration: 1500,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          gradient: LinearGradient(
            colors: [TColors.primaryBlue, TColors.primaryBlue.withOpacity(0.7)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityMetrics() {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            'Verified Votes',
            '98.7%',
            Icons.verified_user,
            TColors.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            'Fraud Cases',
            '247',
            Icons.warning,
            TColors.error,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            'Disqualified Users',
            '1,247',
            Icons.block,
            TColors.warning,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            'System Uptime',
            '99.9%',
            Icons.cloud_done,
            TColors.blockchain,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 11, color: TColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTrendCharts() {
    return SingleChildScrollView(
      child: StaggeredListAnimation(
        children: [
          // Voting Pattern Analysis
          ScaleAnimation(
            child: ChartContainer(
              title: 'Voting Patterns Over Time',
              subtitle: 'Hourly voting trends and peaks',
              child: SizedBox(height: 300, child: _buildAreaChart()),
            ),
          ),

          const SizedBox(height: 20),

          // Turnout Rate Trends
          ScaleAnimation(
            delay: const Duration(milliseconds: 200),
            child: ChartContainer(
              title: 'Voter Turnout Trends',
              subtitle: 'Turnout rate by time of day',
              child: SizedBox(height: 250, child: _buildTurnoutChart()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAreaChart() {
    return SfCartesianChart(
      primaryXAxis: CategoryAxis(labelStyle: const TextStyle(fontSize: 10)),
      primaryYAxis: NumericAxis(
        numberFormat: NumberFormat.compact(),
        labelStyle: const TextStyle(fontSize: 10),
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <CartesianSeries>[
        AreaSeries<TimeSeriesData, String>(
          dataSource: _generateHourlyData(),
          xValueMapper: (TimeSeriesData data, _) => '${data.time.hour}:00',
          yValueMapper: (TimeSeriesData data, _) => data.votes,
          gradient: LinearGradient(
            colors: [
              TColors.primaryBlue.withOpacity(0.6),
              TColors.primaryBlue.withOpacity(0.1),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderColor: TColors.primaryBlue,
          borderWidth: 2,
        ),
      ],
    );
  }

  Widget _buildTurnoutChart() {
    return SfCartesianChart(
      primaryXAxis: CategoryAxis(labelStyle: const TextStyle(fontSize: 10)),
      primaryYAxis: NumericAxis(
        minimum: 0,
        maximum: 100,
        labelFormat: '{value}%',
        labelStyle: const TextStyle(fontSize: 10),
      ),
      series: <CartesianSeries>[
        SplineSeries<RegionalData, String>(
          dataSource: regionalData,
          xValueMapper: (RegionalData data, _) => data.region.split(' ').first,
          yValueMapper: (RegionalData data, _) => data.turnoutRate,
          color: TColors.success,
          width: 3,
          markerSettings: const MarkerSettings(
            isVisible: true,
            shape: DataMarkerType.circle,
            borderWidth: 2,
            borderColor: TColors.white,
          ),
        ),
      ],
    );
  }

  List<TimeSeriesData> _generateHourlyData() {
    final now = DateTime.now();
    return List.generate(12, (index) {
      final time = now.subtract(Duration(hours: 11 - index));
      final baseVotes = 50000 + (index * 15000);
      final random = Random(index);
      final votes = baseVotes + (random.nextDouble() * 20000);

      return TimeSeriesData(
        time: time,
        votes: votes,
        candidate: 'Total',
        color: TColors.primaryBlue,
      );
    });
  }

  Widget _buildDistributionCharts() {
    return SingleChildScrollView(
      child: StaggeredListAnimation(
        children: [
          Row(
            children: [
              // Gender Distribution
              Expanded(
                child: ScaleAnimation(
                  child: ChartContainer(
                    title: 'Gender Distribution',
                    subtitle: 'Votes by gender demographics',
                    child: SizedBox(height: 250, child: _buildGenderChart()),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Age Group Distribution
              Expanded(
                child: ScaleAnimation(
                  delay: const Duration(milliseconds: 200),
                  child: ChartContainer(
                    title: 'Age Groups',
                    subtitle: 'Voting patterns by age',
                    child: SizedBox(height: 250, child: _buildAgeGroupChart()),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Wallet Balance Distribution
          ScaleAnimation(
            delay: const Duration(milliseconds: 400),
            child: ChartContainer(
              title: 'Voter Wallet Distribution',
              subtitle: 'Voting power by wallet balance brackets',
              child: SizedBox(
                height: 300,
                child: _buildWalletDistributionChart(),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Voting Method Distribution
          ScaleAnimation(
            delay: const Duration(milliseconds: 600),
            child: ChartContainer(
              title: 'Voting Methods',
              subtitle: 'Distribution by voting platform',
              child: SizedBox(height: 250, child: _buildVotingMethodChart()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderChart() {
    final genderData = [
      ChartData(category: 'Male', value: 52.4, color: TColors.primaryBlue),
      ChartData(category: 'Female', value: 45.8, color: TColors.primaryPurple),
      ChartData(
        category: 'Non-binary',
        value: 1.8,
        color: TColors.primaryIndigo,
      ),
    ];

    return SfCircularChart(
      legend: Legend(
        isVisible: true,
        position: LegendPosition.bottom,
        textStyle: const TextStyle(fontSize: 10),
      ),
      series: <PieSeries<ChartData, String>>[
        PieSeries<ChartData, String>(
          dataSource: genderData,
          xValueMapper: (ChartData data, _) => data.category,
          yValueMapper: (ChartData data, _) => data.value,
          pointColorMapper: (ChartData data, _) => data.color,
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            labelPosition: ChartDataLabelPosition.outside,
            textStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
          radius: '80%',
          explode: true,
          explodeAll: true,
          explodeOffset: '5%',
        ),
      ],
    );
  }

  Widget _buildAgeGroupChart() {
    final ageData = [
      ChartData(category: '18-25', value: 28.5, color: TColors.success),
      ChartData(category: '26-35', value: 34.2, color: TColors.primaryBlue),
      ChartData(category: '36-50', value: 25.8, color: TColors.warning),
      ChartData(category: '51+', value: 11.5, color: TColors.error),
    ];

    return SfCartesianChart(
      primaryXAxis: CategoryAxis(labelStyle: const TextStyle(fontSize: 10)),
      primaryYAxis: NumericAxis(
        labelFormat: '{value}%',
        labelStyle: const TextStyle(fontSize: 10),
      ),
      series: <CartesianSeries>[
        ColumnSeries<ChartData, String>(
          dataSource: ageData,
          xValueMapper: (ChartData data, _) => data.category,
          yValueMapper: (ChartData data, _) => data.value,
          pointColorMapper: (ChartData data, _) => data.color,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          animationDuration: 1500,
        ),
      ],
    );
  }

  Widget _buildWalletDistributionChart() {
    final walletData = [
      ChartData(category: 'Low (<₦10k)', value: 45.2, color: TColors.error),
      ChartData(
        category: 'Medium (₦10k-100k)',
        value: 38.7,
        color: TColors.warning,
      ),
      ChartData(category: 'High (>₦100k)', value: 16.1, color: TColors.success),
    ];

    return SfCartesianChart(
      primaryXAxis: CategoryAxis(
        labelStyle: const TextStyle(fontSize: 10),
        labelRotation: -45,
      ),
      primaryYAxis: NumericAxis(
        labelFormat: '{value}%',
        labelStyle: const TextStyle(fontSize: 10),
      ),
      series: <CartesianSeries>[
        BarSeries<ChartData, String>(
          dataSource: walletData,
          xValueMapper: (ChartData data, _) => data.category,
          yValueMapper: (ChartData data, _) => data.value,
          pointColorMapper: (ChartData data, _) => data.color,
          borderRadius: const BorderRadius.horizontal(
            right: Radius.circular(6),
          ),
          animationDuration: 1500,
          gradient: LinearGradient(
            colors: [TColors.primaryBlue.withOpacity(0.8), TColors.primaryBlue],
          ),
        ),
      ],
    );
  }

  Widget _buildVotingMethodChart() {
    final methodData = [
      ChartData(
        category: 'Mobile App',
        value: 67.3,
        color: TColors.primaryBlue,
      ),
      ChartData(
        category: 'Web Portal',
        value: 24.1,
        color: TColors.primaryPurple,
      ),
      ChartData(
        category: 'External Wallet',
        value: 8.6,
        color: TColors.blockchain,
      ),
    ];

    return SfCircularChart(
      legend: Legend(
        isVisible: true,
        position: LegendPosition.right,
        textStyle: const TextStyle(fontSize: 10),
      ),
      series: <DoughnutSeries<ChartData, String>>[
        DoughnutSeries<ChartData, String>(
          dataSource: methodData,
          xValueMapper: (ChartData data, _) => data.category,
          yValueMapper: (ChartData data, _) => data.value,
          pointColorMapper: (ChartData data, _) => data.color,
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            labelPosition: ChartDataLabelPosition.outside,
            textStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
          innerRadius: '50%',
          radius: '85%',
          animationDuration: 1500,
        ),
      ],
    );
  }

  Widget _buildRegionalCharts() {
    return SingleChildScrollView(
      child: StaggeredListAnimation(
        children: [
          // Regional Vote Distribution
          ScaleAnimation(
            child: ChartContainer(
              title: 'Regional Vote Distribution',
              subtitle: 'Total votes by state/region',
              child: SizedBox(height: 350, child: _buildRegionalBarChart()),
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              // Leading Candidate by Region
              Expanded(
                child: ScaleAnimation(
                  delay: const Duration(milliseconds: 200),
                  child: ChartContainer(
                    title: 'Regional Leaders',
                    subtitle: 'Leading candidate by region',
                    child: SizedBox(
                      height: 300,
                      child: _buildRegionalLeadersChart(),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Turnout Rates by Region
              Expanded(
                child: ScaleAnimation(
                  delay: const Duration(milliseconds: 400),
                  child: ChartContainer(
                    title: 'Turnout Rates',
                    subtitle: 'Voter participation by region',
                    child: SizedBox(
                      height: 300,
                      child: _buildTurnoutComparisonChart(),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Regional Fraud & Security Stats
          ScaleAnimation(
            delay: const Duration(milliseconds: 600),
            child: ChartContainer(
              title: 'Regional Security Overview',
              subtitle: 'Fraud cases and security metrics by region',
              child: SizedBox(
                height: 250,
                child: _buildRegionalSecurityChart(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegionalBarChart() {
    return SfCartesianChart(
      primaryXAxis: CategoryAxis(
        labelStyle: const TextStyle(fontSize: 10),
        labelRotation: -45,
        majorGridLines: const MajorGridLines(width: 0),
      ),
      primaryYAxis: NumericAxis(
        numberFormat: NumberFormat.compact(),
        labelStyle: const TextStyle(fontSize: 10),
        majorGridLines: MajorGridLines(
          color: TColors.borderLight.withOpacity(0.5),
        ),
      ),
      tooltipBehavior: TooltipBehavior(
        enable: true,
        format: 'point.x: point.y votes',
      ),
      series: <CartesianSeries>[
        ColumnSeries<RegionalData, String>(
          dataSource: regionalData,
          xValueMapper: (RegionalData data, _) => data.region.split(' ').first,
          yValueMapper: (RegionalData data, _) => data.votes,
          pointColorMapper: (RegionalData data, _) => data.color,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          animationDuration: 1500,
          gradient: LinearGradient(
            colors: [TColors.primaryBlue, TColors.primaryBlue.withOpacity(0.7)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ],
    );
  }

  Widget _buildRegionalLeadersChart() {
    return SfCircularChart(
      legend: Legend(
        isVisible: true,
        position: LegendPosition.bottom,
        textStyle: const TextStyle(fontSize: 9),
      ),
      series: <PieSeries<RegionalData, String>>[
        PieSeries<RegionalData, String>(
          dataSource: regionalData,
          xValueMapper: (RegionalData data, _) => data.region.split(' ').first,
          yValueMapper: (RegionalData data, _) => data.votes,
          pointColorMapper: (RegionalData data, _) => data.color,
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            labelPosition: ChartDataLabelPosition.outside,
            textStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            connectorLineSettings: ConnectorLineSettings(
              type: ConnectorType.curve,
              length: '8%',
            ),
          ),
          radius: '75%',
          explode: true,
          explodeAll: true,
          explodeOffset: '5%',
        ),
      ],
    );
  }

  Widget _buildTurnoutComparisonChart() {
    return SfCartesianChart(
      primaryXAxis: CategoryAxis(
        labelStyle: const TextStyle(fontSize: 9),
        labelRotation: -45,
      ),
      primaryYAxis: NumericAxis(
        minimum: 0,
        maximum: 100,
        labelFormat: '{value}%',
        labelStyle: const TextStyle(fontSize: 10),
      ),
      series: <CartesianSeries>[
        SplineAreaSeries<RegionalData, String>(
          dataSource: regionalData,
          xValueMapper: (RegionalData data, _) => data.region.split(' ').first,
          yValueMapper: (RegionalData data, _) => data.turnoutRate,
          gradient: LinearGradient(
            colors: [
              TColors.success.withOpacity(0.6),
              TColors.success.withOpacity(0.1),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderColor: TColors.success,
          borderWidth: 2,
          markerSettings: const MarkerSettings(
            isVisible: true,
            shape: DataMarkerType.circle,
            borderWidth: 2,
            borderColor: TColors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildRegionalSecurityChart() {
    final securityData = regionalData.map((region) {
      final random = Random(region.region.hashCode);
      return ChartData(
        category: region.region.split(' ').first,
        value: 1 + random.nextDouble() * 5, // Fraud cases (1-6)
        color: region.color,
      );
    }).toList();

    return SfCartesianChart(
      primaryXAxis: CategoryAxis(labelStyle: const TextStyle(fontSize: 10)),
      primaryYAxis: NumericAxis(
        labelStyle: const TextStyle(fontSize: 10),
        title: AxisTitle(
          text: 'Fraud Cases',
          textStyle: const TextStyle(fontSize: 10),
        ),
      ),
      series: <CartesianSeries>[
        LineSeries<ChartData, String>(
          dataSource: securityData,
          xValueMapper: (ChartData data, _) => data.category,
          yValueMapper: (ChartData data, _) => data.value,
          color: TColors.error,
          width: 3,
          markerSettings: const MarkerSettings(
            isVisible: true,
            shape: DataMarkerType.diamond,
            borderWidth: 2,
            borderColor: TColors.white,
          ),
        ),
      ],
    );
  }
}

// Chart Container Widget
class ChartContainer extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final bool isLive;

  const ChartContainer({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.isLive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: TColors.textPrimary,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: TColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (isLive)
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
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: TColors.success,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'LIVE',
                        style: TextStyle(
                          color: TColors.success,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
