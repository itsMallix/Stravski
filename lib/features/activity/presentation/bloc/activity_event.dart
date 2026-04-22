import 'package:equatable/equatable.dart';

import '../../domain/entities/activity_entity.dart';

abstract class ActivityEvent extends Equatable {
  const ActivityEvent();
  @override
  List<Object?> get props => [];
}

class ActivityStartTracking extends ActivityEvent {
  final String userId;
  final ActivityType type;
  const ActivityStartTracking({required this.userId, required this.type});

  @override
  List<Object?> get props => [userId, type];
}

class ActivityPauseTracking extends ActivityEvent {
  const ActivityPauseTracking();
}

class ActivityResumeTracking extends ActivityEvent {
  const ActivityResumeTracking();
}

class ActivityStopTracking extends ActivityEvent {
  const ActivityStopTracking();
}

class ActivityTick extends ActivityEvent {
  const ActivityTick();
}

class ActivityResetRequested extends ActivityEvent {
  const ActivityResetRequested();
}

class ActivityLocationUpdated extends ActivityEvent {
  final double latitude;
  final double longitude;
  final double? altitude;
  final double? accuracy;
  const ActivityLocationUpdated({
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.accuracy,
  });

  @override
  List<Object?> get props => [latitude, longitude, altitude, accuracy];
}

class ActivitySaveRequested extends ActivityEvent {
  final String title;
  final String? notes;
  const ActivitySaveRequested({required this.title, this.notes});

  @override
  List<Object?> get props => [title, notes];
}

class ActivitiesLoadRequested extends ActivityEvent {
  final String userId;
  const ActivitiesLoadRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class ActivityDetailRequested extends ActivityEvent {
  final String activityId;
  const ActivityDetailRequested({required this.activityId});

  @override
  List<Object?> get props => [activityId];
}

class ActivityExportGpxRequested extends ActivityEvent {
  final ActivityEntity activity;
  const ActivityExportGpxRequested({required this.activity});

  @override
  List<Object?> get props => [activity];
}
