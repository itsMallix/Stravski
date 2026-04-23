import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stravski/core/theme/app_theme.dart';

import '../bloc/analytics_bloc.dart';
import '../../domain/entities/stats_entity.dart';
import '../../../../core/utils/formatters.dart';
import '../../../activity/presentation/bloc/activity_bloc.dart';
import '../../../activity/presentation/bloc/activity_event.dart';
import '../../../activity/presentation/bloc/activity_state.dart';
import '../../../activity/domain/entities/activity_entity.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _load(0);
    _tabCtrl.addListener(() {
      if (_tabCtrl.indexIsChanging) _load(_tabCtrl.index);
    });
    context.read<ActivityBloc>().add(ActivitiesLoadRequested(userId: _userId));
  }

  String get _userId => FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';

  void _load(int index) {
    final bloc = context.read<AnalyticsBloc>();
    if (index == 0) {
      bloc.add(WeeklyStatsRequested(userId: _userId));
    } else {
      bloc.add(MonthlyStatsRequested(userId: _userId));
    }
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Analytics',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: AppTheme.mainOrange,
          indicatorColor: AppTheme.mainOrange,
          unselectedLabelColor:
              Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          tabs: const [
            Tab(text: 'This Week'),
            Tab(text: 'This Month'),
          ],
        ),
      ),
      body: BlocBuilder<ActivityBloc, ActivityState>(
        builder: (context, actState) {
          final activities = actState is ActivitiesLoaded
              ? List<ActivityEntity>.from(actState.activities)
              : <ActivityEntity>[];
          return BlocBuilder<AnalyticsBloc, AnalyticsState>(
            builder: (context, statsState) {
              if (statsState is AnalyticsLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (statsState is AnalyticsStatsLoaded) {
                return _buildBody(context, statsState.stats, activities);
              }
              if (statsState is AnalyticsError) {
                return Center(child: Text(statsState.message));
              }
              return const Center(child: CircularProgressIndicator());
            },
          );
        },
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    StatsEntity stats,
    List<ActivityEntity> activities,
  ) {
    final cs = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top stats bar ────────────────────────────────────────
          _TopStatsBar(stats: stats, cs: cs),
          const SizedBox(height: 20),

          // ── Speed / Pace chart ───────────────────────────────────
          _SectionTitle('Pace Overview'),
          const SizedBox(height: 8),
          _PaceLineChart(activities: activities, cs: cs),
          const SizedBox(height: 20),

          // ── Daily Volume bar chart ───────────────────────────────
          _SectionTitle('Daily Volume'),
          const SizedBox(height: 8),
          _DailyVolumeChart(
            activities: activities,
            isWeekly: _tabCtrl.index == 0,
            cs: cs,
          ),
          const SizedBox(height: 20),

          // ── Pace zone breakdown ──────────────────────────────────
          _SectionTitle('Pace Zones'),
          const SizedBox(height: 10),
          _PaceZoneBreakdown(activities: activities, cs: cs),
          const SizedBox(height: 20),

          // ── Personal bests ───────────────────────────────────────
          _SectionTitle('Personal Bests'),
          const SizedBox(height: 8),
          _PersonalBests(activities: activities, cs: cs),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

Widget _SectionTitle(String title) => Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Text(title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
    );

// ─── Top stats bar ────────────────────────────────────────────────────────────
class _TopStatsBar extends StatelessWidget {
  final StatsEntity stats;
  final ColorScheme cs;

  const _TopStatsBar({required this.stats, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _TopStat(
              label: 'Distance', value: formatDistance(stats.totalDistanceM)),
          _Divider(),
          _TopStat(
              label: 'Duration', value: formatDuration(stats.totalDuration)),
          _Divider(),
          _TopStat(label: 'Activities', value: '${stats.activityCount}'),
          _Divider(),
          _TopStat(
              label: 'Calories', value: formatCalories(stats.totalCalories)),
        ],
      ),
    );
  }
}

class _TopStat extends StatelessWidget {
  final String label;
  final String value;

  const _TopStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
        const SizedBox(height: 2),
        Text(label,
            style: TextStyle(
                fontSize: 11,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.5))),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        height: 36,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.12),
      );
}

// ─── Pace line chart ──────────────────────────────────────────────────────────
class _PaceLineChart extends StatelessWidget {
  final List<ActivityEntity> activities;
  final ColorScheme cs;

  const _PaceLineChart({required this.activities, required this.cs});

  @override
  Widget build(BuildContext context) {
    // Take up to 10 recent runs
    final runs = activities
        .where((a) => a.type == ActivityType.run && a.averagePaceMinPerKm > 0)
        .take(10)
        .toList()
        .reversed
        .toList();

    if (runs.isEmpty) {
      return _EmptyChart(message: 'Record a run to see pace data', cs: cs);
    }

    final spots = List.generate(
        runs.length, (i) => FlSpot(i.toDouble(), runs[i].averagePaceMinPerKm));

    return Container(
      height: 200,
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: LineChart(
        LineChartData(
          minY: 0,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (v) => FlLine(
              color: cs.onSurface.withValues(alpha: 0.08),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                getTitlesWidget: (v, _) => Text(
                  v.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 10,
                    color: cs.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) {
                  final idx = v.toInt();
                  if (idx < 0 || idx >= runs.length) {
                    return const SizedBox.shrink();
                  }
                  return Text(
                    '${runs[idx].startTime.month}/${runs[idx].startTime.day}',
                    style: TextStyle(
                      fontSize: 10,
                      color: cs.onSurface.withValues(alpha: 0.5),
                    ),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppTheme.mainPurple.withAlpha(95),
              barWidth: 3,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                  radius: 4,
                  color: AppTheme.mainPurple,
                  strokeColor: cs.surface,
                  strokeWidth: 2,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: AppTheme.mainPurple.withAlpha(25),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Daily volume bar chart ───────────────────────────────────────────────────
class _DailyVolumeChart extends StatelessWidget {
  final List<ActivityEntity> activities;
  final bool isWeekly;
  final ColorScheme cs;

  const _DailyVolumeChart(
      {required this.activities, required this.isWeekly, required this.cs});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = isWeekly ? 7 : 30;
    final dayLabels = isWeekly ? ['M', 'T', 'W', 'T', 'F', 'S', 'S'] : null;

    final data = List.generate(days, (i) {
      final d = now.subtract(Duration(days: days - 1 - i));
      final dist = activities
          .where((a) =>
              DateTime(a.startTime.year, a.startTime.month, a.startTime.day) ==
              DateTime(d.year, d.month, d.day))
          .fold<double>(0, (s, a) => s + a.distanceMeters / 1000);
      return (day: d, km: dist);
    });

    final maxKm = data.map((e) => e.km).reduce((a, b) => a > b ? a : b);

    return Container(
      height: 160,
      padding: const EdgeInsets.fromLTRB(4, 16, 16, 8),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: BarChart(
        BarChartData(
          maxY: maxKm > 0 ? maxKm * 1.3 : 10,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (v) => FlLine(
              color: cs.onSurface.withValues(alpha: 0.08),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (v, _) => Text(
                  v.toStringAsFixed(0),
                  style: TextStyle(
                      fontSize: 9, color: cs.onSurface.withValues(alpha: 0.5)),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: isWeekly,
                getTitlesWidget: (v, _) {
                  final idx = v.toInt();
                  if (!isWeekly || idx < 0 || idx >= 7) {
                    return const SizedBox.shrink();
                  }
                  final wd = data[idx].day.weekday - 1;
                  return Text(
                    dayLabels![wd],
                    style: TextStyle(
                        fontSize: 10,
                        color: cs.onSurface.withValues(alpha: 0.5)),
                  );
                },
              ),
            ),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          barGroups: List.generate(
            days,
            (i) => BarChartGroupData(x: i, barRods: [
              BarChartRodData(
                toY: data[i].km,
                color:
                    data[i].day.day == now.day && data[i].day.month == now.month
                        ? AppTheme.darkYellow
                        : AppTheme.darkYellow.withValues(alpha: 0.4),
                width: isWeekly ? 20 : 6,
                borderRadius: BorderRadius.circular(4),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

// ─── Pace zone breakdown ──────────────────────────────────────────────────────
class _PaceZoneBreakdown extends StatelessWidget {
  final List<ActivityEntity> activities;
  final ColorScheme cs;

  const _PaceZoneBreakdown({required this.activities, required this.cs});

  static const _zones = [
    (label: 'Recovery', maxPace: 999.0, color: Color(0xFF90CAF9)),
    (label: 'Endurance', maxPace: 7.0, color: Color(0xFF80CBC4)),
    (label: 'Tempo', maxPace: 5.5, color: Color(0xFFA5D6A7)),
    (label: 'Cruise', maxPace: 4.5, color: Color(0xFFFFCC80)),
    (label: 'Push', maxPace: 3.8, color: Color(0xFFFF8A65)),
    (label: 'Sprint', maxPace: 0.0, color: Color(0xFFEF5350)),
  ];

  @override
  Widget build(BuildContext context) {
    final runs = activities
        .where((a) => a.type == ActivityType.run && a.averagePaceMinPerKm > 0);

    if (runs.isEmpty) {
      return _EmptyChart(
          message: 'Record a run to see pace zone distribution', cs: cs);
    }

    // Count runs per zone
    final counts = List<int>.filled(_zones.length, 0);
    for (final run in runs) {
      final pace = run.averagePaceMinPerKm;
      if (pace >= 7.0) {
        counts[0]++;
      } else if (pace >= 5.5) {
        counts[1]++;
      } else if (pace >= 4.5) {
        counts[2]++;
      } else if (pace >= 3.8) {
        counts[3]++;
      } else if (pace >= 3.0) {
        counts[4]++;
      } else {
        counts[5]++;
      }
    }

    final total = counts.reduce((a, b) => a + b);
    final maxCount = counts.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: List.generate(_zones.length, (i) {
          final zone = _zones[i];
          final pct = total > 0 ? counts[i] / total : 0.0;
          final barRatio = maxCount > 0 ? counts[i] / maxCount : 0.0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                SizedBox(
                  width: 70,
                  child: Text(zone.label,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600)),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        height: 12,
                        decoration: BoxDecoration(
                          color: cs.onSurface.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: barRatio,
                        child: Container(
                          height: 12,
                          decoration: BoxDecoration(
                            color: zone.color,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 36,
                  child: Text(
                    '${(pct * 100).toStringAsFixed(0)}%',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurface.withValues(alpha: 0.5)),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ─── Personal bests ───────────────────────────────────────────────────────────
class _PersonalBests extends StatelessWidget {
  final List<ActivityEntity> activities;
  final ColorScheme cs;

  const _PersonalBests({required this.activities, required this.cs});

  @override
  Widget build(BuildContext context) {
    final runs = activities.where((a) => a.type == ActivityType.run).toList();

    if (runs.isEmpty) {
      return _EmptyChart(message: 'Record runs to see personal bests', cs: cs);
    }

    final longestRun =
        runs.reduce((a, b) => a.distanceMeters > b.distanceMeters ? a : b);
    final validPaceRuns = runs.where((a) => a.averagePaceMinPerKm > 0);
    final fastestPace = validPaceRuns.isNotEmpty
        ? validPaceRuns.reduce(
            (a, b) => a.averagePaceMinPerKm < b.averagePaceMinPerKm ? a : b)
        : null;
    final longestDuration =
        runs.reduce((a, b) => a.duration > b.duration ? a : b);

    return Row(
      children: [
        Expanded(
          child: _PBCard(
              icon: Icons.straighten_rounded,
              color: cs.primary,
              label: 'Longest Run',
              value: formatDistance(longestRun.distanceMeters)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _PBCard(
              icon: Icons.speed_rounded,
              color: Colors.orange,
              label: 'Best Pace',
              value: fastestPace != null
                  ? '${fastestPace.averagePaceMinPerKm.toStringAsFixed(2)}/km'
                  : '-/km'),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _PBCard(
              icon: Icons.timer_rounded,
              color: Colors.teal,
              label: 'Longest Time',
              value: formatDuration(longestDuration.duration)),
        ),
      ],
    );
  }
}

class _PBCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const _PBCard(
      {required this.icon,
      required this.color,
      required this.label,
      required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
          Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 10, color: cs.onSurface.withValues(alpha: 0.5))),
        ],
      ),
    );
  }
}

// ─── Empty chart placeholder ──────────────────────────────────────────────────
class _EmptyChart extends StatelessWidget {
  final String message;
  final ColorScheme cs;

  const _EmptyChart({required this.message, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      width: double.infinity,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(message,
            style: TextStyle(
                color: cs.onSurface.withValues(alpha: 0.4), fontSize: 13)),
      ),
    );
  }
}
