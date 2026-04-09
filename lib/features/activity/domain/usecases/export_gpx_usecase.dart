import '../entities/activity_entity.dart';
import '../repositories/activity_repository.dart';

class ExportGpxUseCase {
  final ActivityRepository _repository;
  ExportGpxUseCase(this._repository);

  Future<String> call(ActivityEntity activity) =>
      _repository.exportToGpx(activity);
}
