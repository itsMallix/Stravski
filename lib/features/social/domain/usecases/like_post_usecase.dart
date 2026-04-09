import '../repositories/social_repository.dart';

class LikePostUseCase {
  final SocialRepository _repository;
  LikePostUseCase(this._repository);

  Future<void> call({required String postId, required String userId}) =>
      _repository.likePost(postId: postId, userId: userId);
}
