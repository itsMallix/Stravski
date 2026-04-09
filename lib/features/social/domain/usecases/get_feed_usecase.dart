import '../entities/post_entity.dart';
import '../repositories/social_repository.dart';

class GetFeedUseCase {
  final SocialRepository _repository;
  GetFeedUseCase(this._repository);

  Future<List<PostEntity>> call({required String userId, int? limit}) =>
      _repository.getFeed(userId: userId, limit: limit);
}
