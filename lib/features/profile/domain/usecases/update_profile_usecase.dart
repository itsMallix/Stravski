import '../repositories/profile_repository.dart';
import '../entities/profile_entity.dart';

class UpdateProfileUseCase {
  final ProfileRepository _repository;
  UpdateProfileUseCase(this._repository);

  Future<void> call(ProfileEntity profile) =>
      _repository.updateProfile(profile);
}
