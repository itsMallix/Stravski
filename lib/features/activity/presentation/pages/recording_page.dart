import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart' hide ActivityType;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import '../bloc/activity_bloc.dart';
import '../bloc/activity_event.dart';
import '../bloc/activity_state.dart';
import '../../domain/entities/activity_entity.dart';
import '../widgets/live_stats_card.dart';

class RecordingPage extends StatefulWidget {
  const RecordingPage({super.key});

  @override
  State<RecordingPage> createState() => _RecordingPageState();
}

class _RecordingPageState extends State<RecordingPage>
    with TickerProviderStateMixin {
  GoogleMapController? _mapController;
  ActivityType _selectedType = ActivityType.run;
  bool _isStarted = false;
  late AnimationController _pulseCtrl;

  static const _polylineId = PolylineId('route');
  static const Color _lineColor = Color(0xFFFF5722);
  LatLng? _initialPosition;
  bool _isLoadingLocation = true;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _initLocation();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  String get _userId => FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';

  Future<void> _initLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) return;

    final position = await Geolocator.getCurrentPosition();

    setState(() {
      _initialPosition = LatLng(position.latitude, position.longitude);
      _isLoadingLocation = false;
    });
  }

  void _startActivity() {
    setState(() => _isStarted = true);
    context.read<ActivityBloc>().add(ActivityStartTracking(
          userId: _userId,
          type: _selectedType,
        ));
  }

  void _stopActivity() {
    context.read<ActivityBloc>().add(const ActivityStopTracking());
  }

  void _pauseActivity(bool isPaused) {
    if (isPaused) {
      context.read<ActivityBloc>().add(const ActivityResumeTracking());
    } else {
      context.read<ActivityBloc>().add(const ActivityPauseTracking());
    }
  }

  void _updateCameraToLocation(LatLng location) {
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(location),
      );
    }
  }

  void _showSaveBottomSheet() {
    final titleCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.viewInsetsOf(ctx).bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Save Activity',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Activity Title',
                hintText: 'Morning Run',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesCtrl,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.read<ActivityBloc>().add(ActivitySaveRequested(
                        title: titleCtrl.text.trim().isNotEmpty
                            ? titleCtrl.text.trim()
                            : 'Activity',
                        notes: notesCtrl.text.trim().isEmpty
                            ? null
                            : notesCtrl.text.trim(),
                      ));
                },
                child: const Text('Save Activity'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocListener<ActivityBloc, ActivityState>(
      listener: (context, state) {
        if (state is ActivitySaved) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Activity saved!'),
              backgroundColor: Colors.green.shade600,
            ),
          );
          setState(() => _isStarted = false);
        } else if (state is ActivityStopped) {
          _showSaveBottomSheet();
        } else if (state is ActivityTracking) {
          if (state.polylinePoints.isNotEmpty) {
            _updateCameraToLocation(state.polylinePoints.last);
          }
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => context.pop(),
          ),
          title: const Text('Record'),
        ),
        body: Stack(
          children: [
            // ── Full-screen map ─────────────────────────────────────
            BlocBuilder<ActivityBloc, ActivityState>(
              builder: (context, state) {
                final polylinePoints = state is ActivityTracking
                    ? state.polylinePoints
                    : (state is ActivityStopped
                        ? state.polylinePoints
                        : <LatLng>[]);

                if (_isLoadingLocation) {
                  return const Center(child: CircularProgressIndicator());
                }
                return GoogleMap(
                  onMapCreated: (ctrl) => _mapController = ctrl,
                  initialCameraPosition: CameraPosition(
                    target: _initialPosition!,
                    zoom: 17,
                    tilt: 25,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  polylines: polylinePoints.length > 1
                      ? {
                          Polyline(
                            polylineId: _polylineId,
                            points: polylinePoints,
                            color: _lineColor,
                            width: 5,
                            jointType: JointType.round,
                            startCap: Cap.roundCap,
                            endCap: Cap.roundCap,
                          ),
                        }
                      : const {},
                );
              },
            ),

            // ── Gradient bottom overlay ─────────────────────────────
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 340,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      colorScheme.surface.withValues(alpha: 0.95),
                      colorScheme.surface,
                    ],
                  ),
                ),
              ),
            ),

            // ── Activity type selector (pre-start) ──────────────────
            if (!_isStarted)
              Positioned(
                bottom: 180,
                left: 24,
                right: 24,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: ActivityType.values.map((t) {
                    final selected = t == _selectedType;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedType = t),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: selected
                                ? colorScheme.primary
                                : colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _activityIcon(t),
                                size: 18,
                                color: selected
                                    ? Colors.white
                                    : colorScheme.onSurface,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                t.name[0].toUpperCase() + t.name.substring(1),
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: selected
                                      ? Colors.white
                                      : colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

            // ── Live stats ─────────────────────────────────────────
            BlocBuilder<ActivityBloc, ActivityState>(
              builder: (context, state) {
                if (state is ActivityTracking) {
                  return Positioned(
                    bottom: 130,
                    left: 16,
                    right: 16,
                    child: LiveStatsCard(
                      distance: state.distanceMeters,
                      duration: state.elapsed,
                      pace: state.paceMinPerKm,
                      speed: state.speedKmH,
                      isPaused: state.isPaused,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            // ── Control buttons ────────────────────────────────────
            Positioned(
              bottom: 36,
              left: 0,
              right: 0,
              child: BlocBuilder<ActivityBloc, ActivityState>(
                builder: (context, state) {
                  if (!_isStarted || state is ActivityInitial) {
                    return Center(
                      child: _RecordButton(
                        onTap: _startActivity,
                        pulseCtrl: _pulseCtrl,
                        color: colorScheme.primary,
                        icon: Icons.play_arrow_rounded,
                        label: 'START',
                      ),
                    );
                  }
                  if (state is ActivityTracking) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Pause / Resume
                        _CircleIconButton(
                          icon: state.isPaused
                              ? Icons.play_arrow_rounded
                              : Icons.pause_rounded,
                          color: colorScheme.secondary,
                          onTap: () => _pauseActivity(state.isPaused),
                        ),
                        const SizedBox(width: 24),
                        // Stop
                        _CircleIconButton(
                          icon: Icons.stop_rounded,
                          color: colorScheme.error,
                          size: 72,
                          onTap: _stopActivity,
                        ),
                      ],
                    );
                  }
                  if (state is ActivityLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
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

class _RecordButton extends StatelessWidget {
  final VoidCallback onTap;
  final AnimationController pulseCtrl;
  final Color color;
  final IconData icon;
  final String label;

  const _RecordButton({
    required this.onTap,
    required this.pulseCtrl,
    required this.color,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: pulseCtrl,
        builder: (_, child) {
          return Container(
            width: 80 + 8 * pulseCtrl.value,
            height: 80 + 8 * pulseCtrl.value,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.15 + 0.1 * pulseCtrl.value),
            ),
            child: child,
          );
        },
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 32),
              Text(label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final double size;

  const _CircleIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
    this.size = 56,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        child: Icon(icon, color: Colors.white, size: size * 0.5),
      ),
    );
  }
}
