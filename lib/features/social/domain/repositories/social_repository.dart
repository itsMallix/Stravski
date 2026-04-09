import '../entities/post_entity.dart';

abstract class SocialRepository {
  Future<List<PostEntity>> getFeed({required String userId, int? limit});
  Future<void> likePost({required String postId, required String userId});
  Future<void> unlikePost({required String postId, required String userId});
  Future<void> addComment({required String postId, required CommentEntity comment});
  Future<List<CommentEntity>> getComments(String postId);
  Future<void> followUser({required String followerId, required String followeeId});
  Future<void> unfollowUser({required String followerId, required String followeeId});
  Future<bool> isFollowing({required String followerId, required String followeeId});
}
