import 'package:flutter/material.dart';

import '../../domain/entities/activity_entity.dart';
import '../../../../core/utils/formatters.dart';

class ActivityCard extends StatelessWidget {
  final ActivityEntity activity;
  final VoidCallback? onTap;

  const ActivityCard({super.key, required this.activity, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Sport Icon
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _activityIcon(activity.type),
                  color: colorScheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatDate(activity.startTime),
                      style: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.5),
                          fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _Stat(
                            icon: Icons.straighten_rounded,
                            value: formatDistance(activity.distanceMeters)),
                        const SizedBox(width: 16),
                        _Stat(
                            icon: Icons.timer_outlined,
                            value: formatDuration(activity.duration)),
                        const SizedBox(width: 16),
                        _Stat(
                            icon: Icons.speed_rounded,
                            value: formatPace(activity.averagePaceMinPerKm)),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: colorScheme.onSurface.withOpacity(0.3)),
            ],
          ),
        ),
      ),
    );
  }

  IconData _activityIcon(ActivityType t) {
    switch (t) {
      case ActivityType.run:
        return Icons.directions_run_rounded;
      case ActivityType.ride:
        return Icons.directions_bike_rounded;
      case ActivityType.walk:
        return Icons.directions_walk_rounded;
    }
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String value;

  const _Stat({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon,
            size: 14,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
        const SizedBox(width: 4),
        Text(value,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                )),
      ],
    );
  }
}
