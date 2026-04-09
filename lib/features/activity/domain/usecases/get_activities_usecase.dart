import '../entities/activity_entity.dart';
import '../repositories/activity_repository.dart';

class GetActivitiesUseCase {
  final ActivityRepository _repository;
  GetActivitiesUseCase(this._repository);

  Future<List<ActivityEntity>> call({required String userId, int? limit}) =>
      _repository.getActivities(userId: userId, limit: limit);
}
