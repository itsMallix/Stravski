import '../repositories/social_repository.dart';

class FollowUserUseCase {
  final SocialRepository _repository;
  FollowUserUseCase(this._repository);

  Future<void> call({required String followerId, required String followeeId}) =>
      _repository.followUser(followerId: followerId, followeeId: followeeId);
}
