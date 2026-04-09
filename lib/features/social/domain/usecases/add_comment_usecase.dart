import '../entities/post_entity.dart';
import '../repositories/social_repository.dart';

class AddCommentUseCase {
  final SocialRepository _repository;
  AddCommentUseCase(this._repository);

  Future<void> call({required String postId, required CommentEntity comment}) =>
      _repository.addComment(postId: postId, comment: comment);
}
