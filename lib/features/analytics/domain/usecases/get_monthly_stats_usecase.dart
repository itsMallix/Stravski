import '../repositories/analytics_repository.dart';
import '../entities/stats_entity.dart';

class GetMonthlyStatsUseCase {
  final AnalyticsRepository _repository;
  GetMonthlyStatsUseCase(this._repository);

  Future<StatsEntity> call({required String userId}) =>
      _repository.getMonthlyStats(userId: userId);
}
