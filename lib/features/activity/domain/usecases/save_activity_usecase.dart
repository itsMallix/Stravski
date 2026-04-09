import '../entities/activity_entity.dart';
import '../repositories/activity_repository.dart';

class SaveActivityUseCase {
  final ActivityRepository _repository;
  SaveActivityUseCase(this._repository);

  Future<void> call(ActivityEntity activity) =>
      _repository.saveActivity(activity);
}
