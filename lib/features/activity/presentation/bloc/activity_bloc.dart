import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart' hide ActivityType;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/activity_entity.dart';
import '../../domain/usecases/save_activity_usecase.dart';
import '../../domain/usecases/get_activities_usecase.dart';
import '../../domain/usecases/get_activity_detail_usecase.dart';
import '../../domain/usecases/export_gpx_usecase.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/utils/activity_calculator.dart';
import '../../../../core/error/failures.dart';
import 'activity_event.dart';
import 'activity_state.dart';

class ActivityBloc extends Bloc<ActivityEvent, ActivityState> {
  final LocationService locationService;
  final SaveActivityUseCase saveActivityUseCase;
  final GetActivitiesUseCase getActivitiesUseCase;
  final GetActivityDetailUseCase getActivityDetailUseCase;
  final ExportGpxUseCase exportGpxUseCase;

  StreamSubscription<Position>? _locationSub;
  Timer? _timer;

  // Session state (mutable, only within bloc)
  final List<LatLng> _polyline = [];
  final List<CoordinatePoint> _coordinates = [];
  Duration _elapsed = Duration.zero;
  DateTime? _startTime;
  String _userId = '';
  ActivityType _activityType = ActivityType.run;

  ActivityBloc({
    required this.locationService,
    required this.saveActivityUseCase,
    required this.getActivitiesUseCase,
    required this.getActivityDetailUseCase,
    required this.exportGpxUseCase,
  }) : super(const ActivityInitial()) {
    on<ActivityStartTracking>(_onStart);
    on<ActivityStopTracking>(_onStop);
    on<ActivityLocationUpdated>(_onLocationUpdated);
    on<ActivityTick>(_onTick);
    on<ActivitySaveRequested>(_onSave);
    on<ActivitiesLoadRequested>(_onLoadActivities);
    on<ActivityDetailRequested>(_onDetailRequested);
    on<ActivityExportGpxRequested>(_onExportGpx);
    on<ActivityResetRequested>(_onReset);
  }

  void _cancelLocationStream() {
    try {
      _locationSub?.cancel().catchError((_) {});
    } catch (_) {}
    _locationSub = null;
  }

  // ─── Start ───────────────────────────────────────────────────────────────
  Future<void> _onStart(
    ActivityStartTracking event,
    Emitter<ActivityState> emit,
  ) async {
    emit(const ActivityLoading());
    try {
      await locationService.checkAndRequestPermission();
      _polyline.clear();
      _coordinates.clear();
      _elapsed = Duration.zero;
      _startTime = DateTime.now();
      _userId = event.userId;
      _activityType = event.type;

      // Get initial position
      final initialPos = await locationService.getCurrentPosition();
      final initialLatLng = LatLng(initialPos.latitude, initialPos.longitude);
      _polyline.add(initialLatLng);
      _coordinates.add(CoordinatePoint(
        latitude: initialPos.latitude,
        longitude: initialPos.longitude,
        altitude: initialPos.altitude,
        accuracy: initialPos.accuracy,
        timestamp: DateTime.now(),
      ));

      // Emit initial state with first position
      emit(ActivityTracking(
        polylinePoints: [initialLatLng],
        distanceMeters: 0,
        elapsed: Duration.zero,
        paceMinPerKm: 0,
        speedKmH: 0,
        type: _activityType,
      ));

      // Start location stream
      _cancelLocationStream();
      _locationSub = locationService.getPositionStream().listen((pos) {
        add(ActivityLocationUpdated(
          latitude: pos.latitude,
          longitude: pos.longitude,
          altitude: pos.altitude,
          accuracy: pos.accuracy,
        ));
      });

      // Elapsed timer — dispatches ActivityTick every second
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!isClosed) {
          _elapsed += const Duration(seconds: 1);
          add(const ActivityTick());
        }
      });
    } catch (e) {
      emit(ActivityError(message: e.toString()));
    }
  }

  // ─── Location update ─────────────────────────────────────────────────────
  void _onLocationUpdated(
    ActivityLocationUpdated event,
    Emitter<ActivityState> emit,
  ) {
    final latLng = LatLng(event.latitude, event.longitude);
    _polyline.add(latLng);
    _coordinates.add(CoordinatePoint(
      latitude: event.latitude,
      longitude: event.longitude,
      altitude: event.altitude,
      accuracy: event.accuracy,
      timestamp: DateTime.now(),
    ));

    // Emit immediately on every GPS fix so the map polyline and stats card
    // update in real-time, not only when the 1-second timer fires.
    final stats = computeActivityStats(
      coords: _polyline.map((p) => [p.latitude, p.longitude]).toList(),
      elapsed: _elapsed,
      activityType: _activityType.name,
    );
    emit(ActivityTracking(
      polylinePoints: List.from(_polyline),
      distanceMeters: stats.distanceM,
      elapsed: _elapsed,
      paceMinPerKm: stats.paceMinPerKm,
      speedKmH: stats.speedKmH,
      type: _activityType,
    ));
  }

  // ─── Tick (every second) ─────────────────────────────────────────────────
  void _onTick(ActivityTick event, Emitter<ActivityState> emit) {
    final stats = computeActivityStats(
      coords: _polyline.map((p) => [p.latitude, p.longitude]).toList(),
      elapsed: _elapsed,
      activityType: _activityType.name,
    );
    emit(ActivityTracking(
      polylinePoints: List.from(_polyline),
      distanceMeters: stats.distanceM,
      elapsed: _elapsed,
      paceMinPerKm: stats.paceMinPerKm,
      speedKmH: stats.speedKmH,
      type: _activityType,
    ));
  }

  // ─── Stop ────────────────────────────────────────────────────────────────
  void _onStop(ActivityStopTracking event, Emitter<ActivityState> emit) {
    _timer?.cancel();
    _cancelLocationStream();

    final stats = computeActivityStats(
      coords: _polyline.map((p) => [p.latitude, p.longitude]).toList(),
      elapsed: _elapsed,
      activityType: _activityType.name,
    );

    emit(ActivityStopped(
      polylinePoints: List.from(_polyline),
      distanceMeters: stats.distanceM,
      elapsed: _elapsed,
      paceMinPerKm: stats.paceMinPerKm,
      speedKmH: stats.speedKmH,
      type: _activityType,
    ));
  }

  // ─── Reset ───────────────────────────────────────────────────────────────
  void _onReset(ActivityResetRequested event, Emitter<ActivityState> emit) {
    _timer?.cancel();
    _cancelLocationStream();
    _polyline.clear();
    _coordinates.clear();
    _elapsed = Duration.zero;
    emit(const ActivityInitial());
  }

  // ─── Save ────────────────────────────────────────────────────────────────
  Future<void> _onSave(
    ActivitySaveRequested event,
    Emitter<ActivityState> emit,
  ) async {
    emit(const ActivityLoading());
    try {
      final stats = computeActivityStats(
        coords: _polyline.map((p) => [p.latitude, p.longitude]).toList(),
        elapsed: _elapsed,
        activityType: _activityType.name,
      );
      final activity = ActivityEntity(
        id: const Uuid().v4(),
        userId: _userId,
        type: _activityType,
        title: event.title,
        startTime: _startTime ?? DateTime.now(),
        endTime: DateTime.now(),
        duration: _elapsed,
        distanceMeters: stats.distanceM,
        averagePaceMinPerKm: stats.paceMinPerKm,
        averageSpeedKmH: stats.speedKmH,
        caloriesBurned: stats.calories,
        coordinates: List.from(_coordinates),
        notes: event.notes,
      );
      await saveActivityUseCase(activity);
      emit(ActivitySaved(savedActivity: activity));
    } on Failure catch (e) {
      emit(ActivityError(message: e.message));
    }
  }

  // ─── Load activities ─────────────────────────────────────────────────────
  Future<void> _onLoadActivities(
    ActivitiesLoadRequested event,
    Emitter<ActivityState> emit,
  ) async {
    emit(const ActivityLoading());
    try {
      final activities = await getActivitiesUseCase(userId: event.userId);
      emit(ActivitiesLoaded(activities: activities));
    } on Failure catch (e) {
      emit(ActivityError(message: e.message));
    }
  }

  // ─── Detail ──────────────────────────────────────────────────────────────
  Future<void> _onDetailRequested(
    ActivityDetailRequested event,
    Emitter<ActivityState> emit,
  ) async {
    emit(const ActivityLoading());
    try {
      final activity = await getActivityDetailUseCase(event.activityId);
      emit(ActivityDetailLoaded(activity: activity));
    } on Failure catch (e) {
      emit(ActivityError(message: e.message));
    }
  }

  // ─── GPX export ──────────────────────────────────────────────────────────
  Future<void> _onExportGpx(
    ActivityExportGpxRequested event,
    Emitter<ActivityState> emit,
  ) async {
    try {
      final gpx = await exportGpxUseCase(event.activity);
      emit(ActivityGpxExported(gpxContent: gpx));
    } on Failure catch (e) {
      emit(ActivityError(message: e.message));
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _cancelLocationStream();
    return super.close();
  }
}
