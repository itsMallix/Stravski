import 'package:equatable/equatable.dart';

class StatsEntity extends Equatable {
  final double totalDistanceM;
  final Duration totalDuration;
  final double avgPaceMinPerKm;
  final int activityCount;
  final double totalCalories;
  final Map<String, double> heartRateZoneMinutes; // zone -> minutes

  const StatsEntity({
    required this.totalDistanceM,
    required this.totalDuration,
    required this.avgPaceMinPerKm,
    required this.activityCount,
    required this.totalCalories,
    required this.heartRateZoneMinutes,
  });

  @override
  List<Object?> get props => [
        totalDistanceM,
        totalDuration,
        avgPaceMinPerKm,
        activityCount,
        totalCalories,
        heartRateZoneMinutes,
      ];
}
