import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/activity_entity.dart';

class CoordinateModel extends CoordinatePoint {
  const CoordinateModel({
    required super.latitude,
    required super.longitude,
    super.altitude,
    super.accuracy,
    required super.timestamp,
  });

  factory CoordinateModel.fromMap(Map<String, dynamic> map) {
    return CoordinateModel(
      latitude: (map['lat'] as num).toDouble(),
      longitude: (map['lng'] as num).toDouble(),
      altitude: map['alt'] != null ? (map['alt'] as num).toDouble() : null,
      accuracy: map['acc'] != null ? (map['acc'] as num).toDouble() : null,
      timestamp: map['ts'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['ts'] as int)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'lat': latitude,
        'lng': longitude,
        if (altitude != null) 'alt': altitude,
        if (accuracy != null) 'acc': accuracy,
        'ts': timestamp.millisecondsSinceEpoch,
      };
}

class ActivityModel extends ActivityEntity {
  const ActivityModel({
    required super.id,
    required super.userId,
    required super.type,
    required super.title,
    required super.startTime,
    super.endTime,
    required super.duration,
    required super.distanceMeters,
    required super.averagePaceMinPerKm,
    required super.averageSpeedKmH,
    required super.caloriesBurned,
    required super.coordinates,
    super.heartRateZone,
    super.notes,
  });

  factory ActivityModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final coords = (data['coordinates'] as List<dynamic>? ?? [])
        .map((c) => CoordinateModel.fromMap(c as Map<String, dynamic>))
        .toList();

    return ActivityModel(
      id: doc.id,
      userId: data['userId'] as String,
      type: ActivityType.values.firstWhere(
          (e) => e.name == (data['type'] as String? ?? 'run'),
          orElse: () => ActivityType.run),
      title: data['title'] as String? ?? 'Activity',
      startTime: DateTime.fromMillisecondsSinceEpoch(data['startTime'] as int),
      endTime: data['endTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['endTime'] as int)
          : null,
      duration: Duration(seconds: data['durationSeconds'] as int? ?? 0),
      distanceMeters: (data['distanceMeters'] as num? ?? 0).toDouble(),
      averagePaceMinPerKm:
          (data['averagePaceMinPerKm'] as num? ?? 0).toDouble(),
      averageSpeedKmH: (data['averageSpeedKmH'] as num? ?? 0).toDouble(),
      caloriesBurned: (data['caloriesBurned'] as num? ?? 0).toDouble(),
      coordinates: coords,
      heartRateZone: data['heartRateZone'] as String?,
      notes: data['notes'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'type': type.name,
        'title': title,
        'startTime': startTime.millisecondsSinceEpoch,
        'endTime': endTime?.millisecondsSinceEpoch,
        'durationSeconds': duration.inSeconds,
        'distanceMeters': distanceMeters,
        'averagePaceMinPerKm': averagePaceMinPerKm,
        'averageSpeedKmH': averageSpeedKmH,
        'caloriesBurned': caloriesBurned,
        'coordinates': coordinates
            .map((c) => CoordinateModel(
                  latitude: c.latitude,
                  longitude: c.longitude,
                  altitude: c.altitude,
                  accuracy: c.accuracy,
                  timestamp: c.timestamp,
                ).toMap())
            .toList(),
        'heartRateZone': heartRateZone,
        'notes': notes,
        'createdAt': FieldValue.serverTimestamp(),
      };
}
