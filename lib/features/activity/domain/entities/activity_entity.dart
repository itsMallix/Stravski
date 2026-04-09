import 'package:equatable/equatable.dart';

enum ActivityType { run, ride, walk }

class CoordinatePoint extends Equatable {
  final double latitude;
  final double longitude;
  final double? altitude;
  final double? accuracy;
  final DateTime timestamp;

  const CoordinatePoint({
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.accuracy,
    required this.timestamp,
  });

  @override
  List<Object?> get props =>
      [latitude, longitude, altitude, accuracy, timestamp];
}

class ActivityEntity extends Equatable {
  final String id;
  final String userId;
  final ActivityType type;
  final String title;
  final DateTime startTime;
  final DateTime? endTime;
  final Duration duration;
  final double distanceMeters;
  final double averagePaceMinPerKm;
  final double averageSpeedKmH;
  final double caloriesBurned;
  final List<CoordinatePoint> coordinates;
  final String? heartRateZone;
  final String? notes;

  const ActivityEntity({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.startTime,
    this.endTime,
    required this.duration,
    required this.distanceMeters,
    required this.averagePaceMinPerKm,
    required this.averageSpeedKmH,
    required this.caloriesBurned,
    required this.coordinates,
    this.heartRateZone,
    this.notes,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        type,
        title,
        startTime,
        endTime,
        duration,
        distanceMeters,
        averagePaceMinPerKm,
        averageSpeedKmH,
        caloriesBurned,
        coordinates,
        heartRateZone,
        notes,
      ];
}
