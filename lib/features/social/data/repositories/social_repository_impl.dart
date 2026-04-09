import '../../domain/entities/post_entity.dart';
import '../../domain/repositories/social_repository.dart';
import '../datasources/social_remote_datasource.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';

class SocialRepositoryImpl implements SocialRepository {
  final SocialRemoteDataSource remoteDataSource;

  SocialRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<PostEntity>> getFeed(
          {required String userId, int? limit}) async {
    try {
      return await remoteDataSource.getFeed(
          userId: userId, limit: limit);
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message);
    }
  }

  @override
  Future<void> likePost(
          {required String postId, required String userId}) =>
      remoteDataSource.likePost(postId: postId, userId: userId);

  @override
  Future<void> unlikePost(
          {required String postId, required String userId}) =>
      remoteDataSource.unlikePost(postId: postId, userId: userId);

  @override
  Future<void> addComment(
          {required String postId,
          required CommentEntity comment}) =>
      remoteDataSource.addComment(postId: postId, comment: comment);

  @override
  Future<List<CommentEntity>> getComments(String postId) =>
      remoteDataSource.getComments(postId);

  @override
  Future<void> followUser(
          {required String followerId,
          required String followeeId}) =>
      remoteDataSource.followUser(
          followerId: followerId, followeeId: followeeId);

  @override
  Future<void> unfollowUser(
          {required String followerId,
          required String followeeId}) =>
      remoteDataSource.unfollowUser(
          followerId: followerId, followeeId: followeeId);

  @override
  Future<bool> isFollowing(
          {required String followerId,
          required String followeeId}) =>
      remoteDataSource.isFollowing(
          followerId: followerId, followeeId: followeeId);
}
