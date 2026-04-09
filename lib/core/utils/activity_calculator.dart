import '../constants/app_constants.dart';
import 'distance_calculator.dart';

class ActivityStats {
  final double distanceM;
  final Duration duration;
  final double paceMinPerKm; // min/km
  final double speedKmH;
  final double calories;

  const ActivityStats({
    required this.distanceM,
    required this.duration,
    required this.paceMinPerKm,
    required this.speedKmH,
    required this.calories,
  });
}

ActivityStats computeActivityStats({
  required List<List<double>> coords, // [[lat, lon], ...]
  required Duration elapsed,
  required String activityType, // 'run' | 'ride' | 'walk'
}) {
  final distanceM = totalPathDistanceM(coords);
  final seconds = elapsed.inSeconds;

  final speedKmH = seconds > 0 ? (distanceM / 1000) / (seconds / 3600) : 0.0;
  final paceMinPerKm = speedKmH > 0 ? 60 / speedKmH : 0.0;

  final caloriesPerM = activityType == 'ride'
      ? AppConstants.caloriesPerMeterRide
      : activityType == 'walk'
          ? AppConstants.caloriesPerMeterWalk
          : AppConstants.caloriesPerMeterRun;
  final calories = distanceM * caloriesPerM;

  return ActivityStats(
    distanceM: distanceM,
    duration: elapsed,
    paceMinPerKm: paceMinPerKm,
    speedKmH: speedKmH,
    calories: calories,
  );
}

String heartRateZone(int bpm, {int maxHr = 190}) {
  final ratio = bpm / maxHr;
  if (ratio >= AppConstants.zone4Max) return 'Zone 5 – Max';
  if (ratio >= AppConstants.zone3Max) return 'Zone 4 – Hard';
  if (ratio >= AppConstants.zone2Max) return 'Zone 3 – Moderate';
  if (ratio >= AppConstants.zone1Max) return 'Zone 2 – Light';
  return 'Zone 1 – Easy';
}
