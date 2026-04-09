import '../../domain/entities/stats_entity.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../datasources/analytics_remote_datasource.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final AnalyticsRemoteDataSource remoteDataSource;
  AnalyticsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<StatsEntity> getWeeklyStats({required String userId}) async {
    try {
      return await remoteDataSource.getWeeklyStats(userId: userId);
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message);
    }
  }

  @override
  Future<StatsEntity> getMonthlyStats({required String userId}) async {
    try {
      return await remoteDataSource.getMonthlyStats(userId: userId);
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message);
    }
  }
}
