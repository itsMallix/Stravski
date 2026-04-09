import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../activity/presentation/bloc/activity_bloc.dart';
import '../../../activity/presentation/bloc/activity_event.dart';
import '../../../activity/presentation/bloc/activity_state.dart';
import '../../../activity/domain/entities/activity_entity.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/constants/app_routes.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    context
        .read<ActivityBloc>()
        .add(const ActivitiesLoadRequested(userId: 'demo_user'));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final greeting = now.hour < 12
        ? 'Good Morning'
        : now.hour < 17
            ? 'Good Afternoon'
            : 'Good Evening';

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: BlocBuilder<ActivityBloc, ActivityState>(
          builder: (context, state) {
            final activities = state is ActivitiesLoaded
                ? state.activities
                : <ActivityEntity>[];

            // Today's stats
            final today = DateTime(now.year, now.month, now.day);
            final todayActivities = activities
                .where((a) =>
                    DateTime(
                        a.startTime.year, a.startTime.month, a.startTime.day) ==
                    today)
                .toList();
            final todayDistance =
                todayActivities.fold<double>(0, (s, a) => s + a.distanceMeters);
            final todayDuration = todayActivities.fold<Duration>(
                Duration.zero, (s, a) => s + a.duration);
            final todayCalories =
                todayActivities.fold<double>(0, (s, a) => s + a.caloriesBurned);

            // Streak (consecutive days with activity)
            int streak = 0;
            for (int i = 0; i < 30; i++) {
              final day = today.subtract(Duration(days: i));
              final hasActivity = activities.any((a) =>
                  DateTime(
                      a.startTime.year, a.startTime.month, a.startTime.day) ==
                  day);
              if (hasActivity) {
                streak++;
              } else if (i > 0) {
                break;
              }
            }

            // Weekly distance (last 7 days)
            final weeklyDistance = activities
                .where((a) => a.startTime
                    .isAfter(today.subtract(const Duration(days: 6))))
                .fold<double>(0, (s, a) => s + a.distanceMeters);

            final recent = activities.isNotEmpty ? activities.first : null;

            return CustomScrollView(
              slivers: [
                // ── App Bar ───────────────────────────────────────────
                SliverAppBar(
                  expandedHeight: 0,
                  floating: true,
                  backgroundColor: colorScheme.surface,
                  elevation: 0,
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(greeting,
                          style: TextStyle(
                              fontSize: 13,
                              color: colorScheme.onSurface
                                  .withValues(alpha: 0.5))),
                      Text('Stravski Runner',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800)),
                    ],
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: CircleAvatar(
                        backgroundColor: colorScheme.primaryContainer,
                        child: Text('S',
                            style: TextStyle(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Column(
                      children: [
                        // ── Today's Overview Card ──────────────────────
                        _TodayCard(
                          distance: todayDistance,
                          duration: todayDuration,
                          calories: todayCalories,
                          colorScheme: colorScheme,
                        ),
                        const SizedBox(height: 16),

                        // ── Streak + Weekly volume ─────────────────────
                        Row(
                          children: [
                            Expanded(
                              child: _StatMiniCard(
                                icon: Icons.local_fire_department_rounded,
                                iconColor: Colors.orange,
                                label: 'Day Streak',
                                value: '$streak',
                                unit: 'days',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatMiniCard(
                                icon: Icons.straighten_rounded,
                                iconColor: colorScheme.primary,
                                label: 'This Week',
                                value: formatDistance(weeklyDistance),
                                unit: '',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // ── Weekly volume bar chart ────────────────────
                        _WeeklyVolumeChart(
                          activities: activities,
                          colorScheme: colorScheme,
                        ),
                        const SizedBox(height: 20),

                        // ── Recent Activity ────────────────────────────
                        if (recent != null) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Recent Activity',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w700)),
                              TextButton(
                                onPressed: () => context.go(AppRoutes.history),
                                child: const Text('See all'),
                              ),
                            ],
                          ),
                          _RecentActivityCard(
                              activity: recent, colorScheme: colorScheme),
                        ] else ...[
                          _EmptyRunCard(colorScheme: colorScheme),
                        ],
                        const SizedBox(height: 96),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ─── Today Card ───────────────────────────────────────────────────────────────
class _TodayCard extends StatelessWidget {
  final double distance;
  final Duration duration;
  final double calories;
  final ColorScheme colorScheme;

  const _TodayCard({
    required this.distance,
    required this.duration,
    required this.calories,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary,
            colorScheme.primary.withValues(alpha: 0.75),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Today',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(formatDistance(distance),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 16),
          Row(
            children: [
              _TodayStat(label: 'Duration', value: formatDuration(duration)),
              const SizedBox(width: 24),
              _TodayStat(label: 'Calories', value: formatCalories(calories)),
            ],
          ),
        ],
      ),
    );
  }
}

class _TodayStat extends StatelessWidget {
  final String label;
  final String value;

  const _TodayStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7), fontSize: 11)),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700)),
      ],
    );
  }
}

// ─── Mini stat card ───────────────────────────────────────────────────────────
class _StatMiniCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String unit;

  const _StatMiniCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 8),
          Text(value,
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          Text(label,
              style: TextStyle(
                  fontSize: 12, color: cs.onSurface.withValues(alpha: 0.5))),
        ],
      ),
    );
  }
}

// ─── Weekly volume bar chart ──────────────────────────────────────────────────
class _WeeklyVolumeChart extends StatelessWidget {
  final List<ActivityEntity> activities;
  final ColorScheme colorScheme;

  const _WeeklyVolumeChart(
      {required this.activities, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final days = List.generate(7, (i) {
      final d = today.subtract(Duration(days: 6 - i));
      final dist = activities
          .where((a) =>
              DateTime(a.startTime.year, a.startTime.month, a.startTime.day) ==
              DateTime(d.year, d.month, d.day))
          .fold<double>(0, (s, a) => s + a.distanceMeters);
      return (day: d, distanceM: dist);
    });

    final maxDist =
        days.map((e) => e.distanceM).reduce((a, b) => a > b ? a : b);
    final labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Weekly Volume',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (i) {
              final d = days[i];
              final isToday =
                  d.day.day == today.day && d.day.month == today.month;
              final ratio = maxDist > 0 ? d.distanceM / maxDist : 0.0;
              final dayLabel = labels[d.day.weekday % 7]; // weekday: 1=Mon
              return Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300 + i * 40),
                        width: 24,
                        height: (ratio * 70).clamp(4, 70),
                        decoration: BoxDecoration(
                          color: isToday
                              ? colorScheme.primary
                              : colorScheme.primary.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(dayLabel,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight:
                                isToday ? FontWeight.w700 : FontWeight.normal,
                            color: isToday
                                ? colorScheme.primary
                                : colorScheme.onSurface
                                    .withValues(alpha: 0.4))),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

// ─── Recent activity card ─────────────────────────────────────────────────────
class _RecentActivityCard extends StatelessWidget {
  final ActivityEntity activity;
  final ColorScheme colorScheme;

  const _RecentActivityCard(
      {required this.activity, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    final typeIcon = activity.type == ActivityType.run
        ? Icons.directions_run_rounded
        : activity.type == ActivityType.ride
            ? Icons.directions_bike_rounded
            : Icons.directions_walk_rounded;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(typeIcon, color: colorScheme.primary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(activity.title,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                Text(formatDateTime(activity.startTime),
                    style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface.withValues(alpha: 0.5))),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(formatDistance(activity.distanceMeters),
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 16)),
              Text(formatDuration(activity.duration),
                  style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurface.withValues(alpha: 0.5))),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────
class _EmptyRunCard extends StatelessWidget {
  final ColorScheme colorScheme;

  const _EmptyRunCard({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(Icons.directions_run_rounded,
              size: 48, color: colorScheme.primary.withValues(alpha: 0.4)),
          const SizedBox(height: 12),
          Text('No runs yet',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface.withValues(alpha: 0.6))),
          const SizedBox(height: 4),
          Text('Tap Start Run to record your first run',
              style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurface.withValues(alpha: 0.4))),
        ],
      ),
    );
  }
}
