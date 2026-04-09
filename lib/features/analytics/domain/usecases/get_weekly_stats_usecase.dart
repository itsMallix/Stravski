import '../entities/stats_entity.dart';
import '../repositories/analytics_repository.dart';

class GetWeeklyStatsUseCase {
  final AnalyticsRepository _repository;
  GetWeeklyStatsUseCase(this._repository);

  Future<StatsEntity> call({required String userId}) =>
      _repository.getWeeklyStats(userId: userId);
}
