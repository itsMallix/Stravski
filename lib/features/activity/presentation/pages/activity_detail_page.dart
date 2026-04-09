import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../bloc/activity_bloc.dart';
import '../bloc/activity_event.dart';
import '../bloc/activity_state.dart';
import '../../domain/entities/activity_entity.dart';
import '../../../../core/utils/formatters.dart';

class ActivityDetailPage extends StatefulWidget {
  final String activityId;

  const ActivityDetailPage({super.key, required this.activityId});

  @override
  State<ActivityDetailPage> createState() => _ActivityDetailPageState();
}

class _ActivityDetailPageState extends State<ActivityDetailPage> {
  // _mapController is assigned in onMapCreated callback below
  // ignore: unused_field
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    context
        .read<ActivityBloc>()
        .add(ActivityDetailRequested(activityId: widget.activityId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<ActivityBloc, ActivityState>(
        listener: (context, state) {
          if (state is ActivityGpxExported) {
            _saveGpxFile(state.gpxContent, context);
          }
          if (state is ActivityError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is ActivityLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ActivityDetailLoaded) {
            return _buildDetail(context, state.activity);
          }
          if (state is ActivityError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildDetail(BuildContext context, ActivityEntity activity) {
    final colorScheme = Theme.of(context).colorScheme;
    final polylinePoints = activity.coordinates
        .map((c) => LatLng(c.latitude, c.longitude))
        .toList();

    LatLng initialTarget = polylinePoints.isNotEmpty
        ? polylinePoints.first
        : const LatLng(-6.2088, 106.8456);

    return CustomScrollView(
      slivers: [
        // ── App bar with map ──────────────────────────────────────
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: GoogleMap(
              onMapCreated: (ctrl) {
                _mapController = ctrl;
                if (polylinePoints.isNotEmpty) {
                  ctrl.animateCamera(CameraUpdate.newLatLngBounds(
                    _boundsFromPoints(polylinePoints),
                    60,
                  ));
                }
              },
              initialCameraPosition:
                  CameraPosition(target: initialTarget, zoom: 14),
              polylines: polylinePoints.length > 1
                  ? {
                      Polyline(
                        polylineId: const PolylineId('route'),
                        points: polylinePoints,
                        color: colorScheme.primary,
                        width: 5,
                        jointType: JointType.round,
                        startCap: Cap.roundCap,
                        endCap: Cap.roundCap,
                      ),
                    }
                  : const {},
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              tiltGesturesEnabled: false,
              rotateGesturesEnabled: false,
              scrollGesturesEnabled: false,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.download_rounded),
              onPressed: () => context.read<ActivityBloc>().add(
                    ActivityExportGpxRequested(activity: activity),
                  ),
              tooltip: 'Export GPX',
            ),
          ],
        ),

        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // ── Title + date ──────────────────────────────────────
              Text(
                activity.title,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined,
                      size: 14,
                      color: colorScheme.onSurface.withValues(alpha: 0.5)),
                  const SizedBox(width: 6),
                  Text(
                    formatDateTime(activity.startTime),
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                        fontSize: 13),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      activity.type.name.toUpperCase(),
                      style: TextStyle(
                          color: colorScheme.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Stats grid ────────────────────────────────────────
              _StatsGrid(activity: activity),
              const SizedBox(height: 24),

              // ── Notes ─────────────────────────────────────────────
              if (activity.notes != null && activity.notes!.isNotEmpty) ...[
                Text('Notes',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(activity.notes!),
                const SizedBox(height: 24),
              ],
            ]),
          ),
        ),
      ],
    );
  }

  LatLngBounds _boundsFromPoints(List<LatLng> points) {
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;
    for (final p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  Future<void> _saveGpxFile(String content, BuildContext context) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/activity_${DateTime.now().millisecondsSinceEpoch}.gpx');
      await file.writeAsString(content);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('GPX saved to ${file.path}')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save GPX: $e')),
        );
      }
    }
  }
}

class _StatsGrid extends StatelessWidget {
  final ActivityEntity activity;

  const _StatsGrid({required this.activity});

  @override
  Widget build(BuildContext context) {
    final stats = [
      _StatData('Distance', formatDistance(activity.distanceMeters),
          Icons.straighten_rounded),
      _StatData('Duration', formatDuration(activity.duration),
          Icons.timer_outlined),
      _StatData('Avg Pace', formatPace(activity.averagePaceMinPerKm),
          Icons.speed_rounded),
      _StatData('Avg Speed', formatSpeed(activity.averageSpeedKmH),
          Icons.bolt_rounded),
      _StatData('Calories', formatCalories(activity.caloriesBurned),
          Icons.local_fire_department_rounded),
      if (activity.heartRateZone != null)
        _StatData('HR Zone', activity.heartRateZone!, Icons.favorite_rounded),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.6,
      ),
      itemCount: stats.length,
      itemBuilder: (context, i) => _StatTile(data: stats[i]),
    );
  }
}

class _StatData {
  final String label;
  final String value;
  final IconData icon;
  const _StatData(this.label, this.value, this.icon);
}

class _StatTile extends StatelessWidget {
  final _StatData data;

  const _StatTile({required this.data});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(data.icon, size: 16, color: colorScheme.primary),
              const SizedBox(width: 6),
              Text(
                data.label,
                style: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            data.value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}
