import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/stats_entity.dart';
import '../../../../core/error/exceptions.dart';

abstract class AnalyticsRemoteDataSource {
  Future<StatsEntity> getWeeklyStats({required String userId});
  Future<StatsEntity> getMonthlyStats({required String userId});
}

class AnalyticsRemoteDataSourceImpl implements AnalyticsRemoteDataSource {
  final FirebaseFirestore _firestore;
  AnalyticsRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<StatsEntity> getWeeklyStats({required String userId}) async {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return _queryStats(userId, weekAgo);
  }

  @override
  Future<StatsEntity> getMonthlyStats({required String userId}) async {
    final now = DateTime.now();
    final monthAgo = DateTime(now.year, now.month - 1, now.day);
    return _queryStats(userId, monthAgo);
  }

  Future<StatsEntity> _queryStats(String userId, DateTime since) async {
    try {
      final snap = await _firestore
          .collection('activities')
          .where('userId', isEqualTo: userId)
          .where('startTime',
              isGreaterThanOrEqualTo: since.millisecondsSinceEpoch)
          .get();

      double totalDist = 0;
      int totalSecs = 0;
      double totalCal = 0;

      for (final doc in snap.docs) {
        final data = doc.data();
        totalDist += (data['distanceMeters'] as num? ?? 0).toDouble();
        totalSecs += data['durationSeconds'] as int? ?? 0;
        totalCal += (data['caloriesBurned'] as num? ?? 0).toDouble();
      }

      final totalKm = totalDist / 1000;
      final totalHours = totalSecs / 3600;
      final avgPace =
          totalHours > 0 && totalKm > 0 ? 60 / (totalKm / totalHours) : 0.0;

      return StatsEntity(
        totalDistanceM: totalDist,
        totalDuration: Duration(seconds: totalSecs),
        avgPaceMinPerKm: avgPace,
        activityCount: snap.docs.length,
        totalCalories: totalCal,
        heartRateZoneMinutes: const {
          'Zone 1': 20,
          'Zone 2': 35,
          'Zone 3': 25,
          'Zone 4': 15,
          'Zone 5': 5,
        }, // Simulated HR zones
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
