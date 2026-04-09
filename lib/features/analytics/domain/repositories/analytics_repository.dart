import '../entities/stats_entity.dart';

abstract class AnalyticsRepository {
  Future<StatsEntity> getWeeklyStats({required String userId});
  Future<StatsEntity> getMonthlyStats({required String userId});
}
