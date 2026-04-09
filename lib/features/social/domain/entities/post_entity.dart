import 'package:equatable/equatable.dart';

class PostEntity extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatarUrl;
  final String activityId;
  final String caption;
  final List<String> likedByUserIds;
  final int commentCount;
  final DateTime createdAt;
  final double distanceMeters;
  final Duration duration;

  const PostEntity({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatarUrl,
    required this.activityId,
    required this.caption,
    required this.likedByUserIds,
    required this.commentCount,
    required this.createdAt,
    required this.distanceMeters,
    required this.duration,
  });

  bool isLikedBy(String uid) => likedByUserIds.contains(uid);

  @override
  List<Object?> get props => [
        id,
        userId,
        activityId,
        caption,
        likedByUserIds,
        commentCount,
        createdAt,
      ];
}

class CommentEntity extends Equatable {
  final String id;
  final String postId;
  final String userId;
  final String userName;
  final String? userAvatarUrl;
  final String text;
  final DateTime createdAt;

  const CommentEntity({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userName,
    this.userAvatarUrl,
    required this.text,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, postId, userId, text, createdAt];
}
