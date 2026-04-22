import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../domain/entities/activity_entity.dart';

abstract class ActivityState extends Equatable {
  const ActivityState();
  @override
  List<Object?> get props => [];
}

class ActivityInitial extends ActivityState {
  const ActivityInitial();
}

class ActivityLoading extends ActivityState {
  const ActivityLoading();
}

class ActivityTracking extends ActivityState {
  final List<LatLng> polylinePoints;
  final double distanceMeters;
  final Duration elapsed;
  final double paceMinPerKm;
  final double speedKmH;
  final bool isPaused;
  final ActivityType type;

  const ActivityTracking({
    required this.polylinePoints,
    required this.distanceMeters,
    required this.elapsed,
    required this.paceMinPerKm,
    required this.speedKmH,
    required this.isPaused,
    required this.type,
  });

  ActivityTracking copyWith({
    List<LatLng>? polylinePoints,
    double? distanceMeters,
    Duration? elapsed,
    double? paceMinPerKm,
    double? speedKmH,
    bool? isPaused,
    ActivityType? type,
  }) =>
      ActivityTracking(
        polylinePoints: polylinePoints ?? this.polylinePoints,
        distanceMeters: distanceMeters ?? this.distanceMeters,
        elapsed: elapsed ?? this.elapsed,
        paceMinPerKm: paceMinPerKm ?? this.paceMinPerKm,
        speedKmH: speedKmH ?? this.speedKmH,
        isPaused: isPaused ?? this.isPaused,
        type: type ?? this.type,
      );

  // Do NOT override props — every new emit must rebuild the UI
  @override
  List<Object?> get props => [elapsed.inSeconds, distanceMeters, isPaused];
}

class ActivityStopped extends ActivityState {
  final List<LatLng> polylinePoints;
  final double distanceMeters;
  final Duration elapsed;
  final double paceMinPerKm;
  final double speedKmH;
  final ActivityType type;

  const ActivityStopped({
    required this.polylinePoints,
    required this.distanceMeters,
    required this.elapsed,
    required this.paceMinPerKm,
    required this.speedKmH,
    required this.type,
  });

  @override
  List<Object?> get props => [
        polylinePoints,
        distanceMeters,
        elapsed,
        paceMinPerKm,
        speedKmH,
        type,
      ];
}

class ActivitySaved extends ActivityState {
  final ActivityEntity savedActivity;
  const ActivitySaved({required this.savedActivity});

  @override
  List<Object?> get props => [savedActivity];
}

class ActivitiesLoaded extends ActivityState {
  final List<ActivityEntity> activities;
  const ActivitiesLoaded({required this.activities});

  @override
  List<Object?> get props => [activities];
}

class ActivityDetailLoaded extends ActivityState {
  final ActivityEntity activity;
  const ActivityDetailLoaded({required this.activity});

  @override
  List<Object?> get props => [activity];
}

class ActivityGpxExported extends ActivityState {
  final String gpxContent;
  const ActivityGpxExported({required this.gpxContent});

  @override
  List<Object?> get props => [gpxContent];
}

class ActivityError extends ActivityState {
  final String message;
  const ActivityError({required this.message});

  @override
  List<Object?> get props => [message];
}
