import '../entities/activity_entity.dart';
import '../repositories/activity_repository.dart';

class GetActivityDetailUseCase {
  final ActivityRepository _repository;
  GetActivityDetailUseCase(this._repository);

  Future<ActivityEntity> call(String id) =>
      _repository.getActivityById(id);
}
