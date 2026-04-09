import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/post_entity.dart';
import '../../domain/usecases/get_feed_usecase.dart';
import '../../domain/usecases/like_post_usecase.dart';
import '../../domain/usecases/add_comment_usecase.dart';
import '../../domain/usecases/follow_user_usecase.dart';
import '../../../../core/error/failures.dart';

// ─── Events ──────────────────────────────────────────────────────────────────
abstract class SocialEvent extends Equatable {
  const SocialEvent();
  @override
  List<Object?> get props => [];
}

class FeedLoadRequested extends SocialEvent {
  final String userId;
  const FeedLoadRequested({required this.userId});
  @override
  List<Object?> get props => [userId];
}

class PostLikeToggled extends SocialEvent {
  final String postId;
  final String userId;
  final bool isCurrentlyLiked;
  const PostLikeToggled({
    required this.postId,
    required this.userId,
    required this.isCurrentlyLiked,
  });
  @override
  List<Object?> get props => [postId, userId, isCurrentlyLiked];
}

class CommentAddedEvent extends SocialEvent {
  final String postId;
  final CommentEntity comment;
  const CommentAddedEvent({required this.postId, required this.comment});
  @override
  List<Object?> get props => [postId, comment];
}

class UserFollowToggled extends SocialEvent {
  final String followerId;
  final String followeeId;
  final bool isCurrentlyFollowing;
  const UserFollowToggled({
    required this.followerId,
    required this.followeeId,
    required this.isCurrentlyFollowing,
  });
  @override
  List<Object?> get props => [followerId, followeeId, isCurrentlyFollowing];
}

// ─── States ───────────────────────────────────────────────────────────────────
abstract class SocialState extends Equatable {
  const SocialState();
  @override
  List<Object?> get props => [];
}

class SocialInitial extends SocialState {
  const SocialInitial();
}

class SocialLoading extends SocialState {
  const SocialLoading();
}

class FeedLoaded extends SocialState {
  final List<PostEntity> posts;
  const FeedLoaded({required this.posts});
  @override
  List<Object?> get props => [posts];
}

class SocialError extends SocialState {
  final String message;
  const SocialError({required this.message});
  @override
  List<Object?> get props => [message];
}

// ─── BLoC ─────────────────────────────────────────────────────────────────────
class SocialBloc extends Bloc<SocialEvent, SocialState> {
  final GetFeedUseCase getFeedUseCase;
  final LikePostUseCase likePostUseCase;
  final AddCommentUseCase addCommentUseCase;
  final FollowUserUseCase followUserUseCase;

  SocialBloc({
    required this.getFeedUseCase,
    required this.likePostUseCase,
    required this.addCommentUseCase,
    required this.followUserUseCase,
  }) : super(const SocialInitial()) {
    on<FeedLoadRequested>(_onLoadFeed);
    on<PostLikeToggled>(_onLikeToggled);
    on<CommentAddedEvent>(_onCommentAdded);
    on<UserFollowToggled>(_onFollowToggled);
  }

  Future<void> _onLoadFeed(
    FeedLoadRequested event,
    Emitter<SocialState> emit,
  ) async {
    emit(const SocialLoading());
    try {
      final posts = await getFeedUseCase(userId: event.userId);
      emit(FeedLoaded(posts: posts));
    } on Failure catch (e) {
      emit(SocialError(message: e.message));
    } catch (e) {
      emit(SocialError(message: e.toString()));
    }
  }

  Future<void> _onLikeToggled(
    PostLikeToggled event,
    Emitter<SocialState> emit,
  ) async {
    if (state is FeedLoaded) {
      final posts = List.of((state as FeedLoaded).posts);
      if (event.isCurrentlyLiked) {
        await likePostUseCase(
            postId: event.postId, userId: event.userId);
      }
      // Optimistic UI update
      final idx = posts.indexWhere((p) => p.id == event.postId);
      if (idx != -1) {
        final post = posts[idx];
        final updatedLikes = event.isCurrentlyLiked
            ? [...post.likedByUserIds, event.userId]
            : post.likedByUserIds
                .where((id) => id != event.userId)
                .toList();
        posts[idx] = PostEntity(
          id: post.id,
          userId: post.userId,
          userName: post.userName,
          userAvatarUrl: post.userAvatarUrl,
          activityId: post.activityId,
          caption: post.caption,
          likedByUserIds: updatedLikes,
          commentCount: post.commentCount,
          createdAt: post.createdAt,
          distanceMeters: post.distanceMeters,
          duration: post.duration,
        );
        emit(FeedLoaded(posts: posts));
      }
    }
  }

  Future<void> _onCommentAdded(
    CommentAddedEvent event,
    Emitter<SocialState> emit,
  ) async {
    await addCommentUseCase(
        postId: event.postId, comment: event.comment);
  }

  Future<void> _onFollowToggled(
    UserFollowToggled event,
    Emitter<SocialState> emit,
  ) async {
    await followUserUseCase(
      followerId: event.followerId,
      followeeId: event.followeeId,
    );
  }
}
