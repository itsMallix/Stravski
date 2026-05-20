import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';

class LiveStatsCard extends StatelessWidget {
  final double distance;
  final Duration duration;
  final double pace;
  final double speed;
  const LiveStatsCard({
    super.key,
    required this.distance,
    required this.duration,
    required this.pace,
    required this.speed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatItem(
                  label: 'Distance',
                  value: formatDistance(distance),
                  isLarge: true),
              _Divider(),
              _StatItem(label: 'Duration', value: formatDuration(duration)),
              _Divider(),
              _StatItem(label: 'Pace', value: formatPace(pace)),
              _Divider(),
              _StatItem(label: 'Speed', value: formatSpeed(speed)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final bool isLarge;

  const _StatItem({
    required this.label,
    required this.value,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: isLarge ? 22 : 15,
                color: isLarge ? Theme.of(context).colorScheme.primary : null,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        height: 32,
        width: 1,
        color: Theme.of(context).colorScheme.outlineVariant,
      );
}
