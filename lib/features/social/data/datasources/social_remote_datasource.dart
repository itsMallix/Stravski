import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/post_entity.dart';
import '../../../../core/error/exceptions.dart';

abstract class SocialRemoteDataSource {
  Future<List<PostEntity>> getFeed({required String userId, int? limit});
  Future<void> likePost({required String postId, required String userId});
  Future<void> unlikePost({required String postId, required String userId});
  Future<void> addComment(
      {required String postId, required CommentEntity comment});
  Future<List<CommentEntity>> getComments(String postId);
  Future<void> followUser(
      {required String followerId, required String followeeId});
  Future<void> unfollowUser(
      {required String followerId, required String followeeId});
  Future<bool> isFollowing(
      {required String followerId, required String followeeId});
}

class SocialRemoteDataSourceImpl implements SocialRemoteDataSource {
  final FirebaseFirestore _firestore;

  SocialRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<PostEntity>> getFeed({
    required String userId,
    int? limit,
  }) async {
    try {
      // Get following list first
      final followingSnap = await _firestore
          .collection('follows')
          .where('followerId', isEqualTo: userId)
          .get();
      final followingIds = followingSnap.docs
          .map((d) => d.data()['followeeId'] as String)
          .toList()
        ..add(userId);

      // Fetch posts from followed users
      Query<Map<String, dynamic>> query = _firestore
          .collection('posts')
          .where('userId', whereIn: followingIds.take(10).toList())
          .orderBy('createdAt', descending: true);
      if (limit != null) query = query.limit(limit);
      final snap = await query.get();
      return snap.docs.map(_postFromDoc).toList();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> likePost(
      {required String postId, required String userId}) async {
    await _firestore.collection('posts').doc(postId).update({
      'likedByUserIds': FieldValue.arrayUnion([userId]),
    });
  }

  @override
  Future<void> unlikePost(
      {required String postId, required String userId}) async {
    await _firestore.collection('posts').doc(postId).update({
      'likedByUserIds': FieldValue.arrayRemove([userId]),
    });
  }

  @override
  Future<void> addComment(
      {required String postId, required CommentEntity comment}) async {
    await _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(comment.id)
        .set({
      'userId': comment.userId,
      'userName': comment.userName,
      'userAvatarUrl': comment.userAvatarUrl,
      'text': comment.text,
      'createdAt': comment.createdAt.millisecondsSinceEpoch,
    });
    await _firestore.collection('posts').doc(postId).update({
      'commentCount': FieldValue.increment(1),
    });
  }

  @override
  Future<List<CommentEntity>> getComments(String postId) async {
    final snap = await _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt')
        .get();
    return snap.docs.map((d) {
      final data = d.data();
      return CommentEntity(
        id: d.id,
        postId: postId,
        userId: data['userId'] as String,
        userName: data['userName'] as String,
        userAvatarUrl: data['userAvatarUrl'] as String?,
        text: data['text'] as String,
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(data['createdAt'] as int),
      );
    }).toList();
  }

  @override
  Future<void> followUser({
    required String followerId,
    required String followeeId,
  }) async {
    await _firestore
        .collection('follows')
        .doc('${followerId}_$followeeId')
        .set({'followerId': followerId, 'followeeId': followeeId});
    await _firestore
        .collection('users')
        .doc(followerId)
        .update({'followingCount': FieldValue.increment(1)});
    await _firestore
        .collection('users')
        .doc(followeeId)
        .update({'followersCount': FieldValue.increment(1)});
  }

  @override
  Future<void> unfollowUser({
    required String followerId,
    required String followeeId,
  }) async {
    await _firestore
        .collection('follows')
        .doc('${followerId}_$followeeId')
        .delete();
    await _firestore
        .collection('users')
        .doc(followerId)
        .update({'followingCount': FieldValue.increment(-1)});
    await _firestore
        .collection('users')
        .doc(followeeId)
        .update({'followersCount': FieldValue.increment(-1)});
  }

  @override
  Future<bool> isFollowing({
    required String followerId,
    required String followeeId,
  }) async {
    final doc = await _firestore
        .collection('follows')
        .doc('${followerId}_$followeeId')
        .get();
    return doc.exists;
  }

  PostEntity _postFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return PostEntity(
      id: doc.id,
      userId: data['userId'] as String,
      userName: data['userName'] as String? ?? '',
      userAvatarUrl: data['userAvatarUrl'] as String?,
      activityId: data['activityId'] as String? ?? '',
      caption: data['caption'] as String? ?? '',
      likedByUserIds: List<String>.from(data['likedByUserIds'] as List? ?? []),
      commentCount: data['commentCount'] as int? ?? 0,
      createdAt:
          DateTime.fromMillisecondsSinceEpoch(data['createdAt'] as int? ?? 0),
      distanceMeters: (data['distanceMeters'] as num? ?? 0).toDouble(),
      duration: Duration(seconds: data['durationSeconds'] as int? ?? 0),
    );
  }
}
