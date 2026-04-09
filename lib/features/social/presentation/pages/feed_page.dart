import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../bloc/social_bloc.dart';
import '../../domain/entities/post_entity.dart';
import '../../../../core/utils/formatters.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    context.read<SocialBloc>().add(FeedLoadRequested(userId: uid));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: BlocBuilder<SocialBloc, SocialState>(
        builder: (context, state) {
          if (state is SocialLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is FeedLoaded) {
            if (state.posts.isEmpty) {
              return _EmptyFeed();
            }
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: state.posts.length,
              itemBuilder: (context, i) => _PostCard(
                post: state.posts[i],
                currentUserId: FirebaseAuth.instance.currentUser?.uid ?? '',
              ),
            );
          }
          if (state is SocialError) {
            return Center(child: Text(state.message));
          }
          return _EmptyFeed();
        },
      ),
    );
  }
}

class _EmptyFeed extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline,
                size: 72,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
            const SizedBox(height: 16),
            const Text('Follow athletes to see their activities'),
          ],
        ),
      );
}

class _PostCard extends StatelessWidget {
  final PostEntity post;
  final String currentUserId;

  const _PostCard({required this.post, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLiked = post.isLikedBy(currentUserId);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────────
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: colorScheme.primaryContainer,
                  backgroundImage: post.userAvatarUrl != null
                      ? NetworkImage(post.userAvatarUrl!)
                      : null,
                  child: post.userAvatarUrl == null
                      ? Text(
                          post.userName.isNotEmpty
                              ? post.userName[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w700),
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.userName,
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      Text(timeAgo(post.createdAt),
                          style: TextStyle(
                              color: colorScheme.onSurface.withOpacity(0.5),
                              fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ── Activity stats bar ────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withOpacity(0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _MiniStat(
                      label: 'Distance',
                      value: formatDistance(post.distanceMeters)),
                  _MiniStat(
                      label: 'Duration', value: formatDuration(post.duration)),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // ── Caption ─────────────────────────────────────────────
            if (post.caption.isNotEmpty) Text(post.caption),
            const SizedBox(height: 10),

            // ── Actions ─────────────────────────────────────────────
            Row(
              children: [
                GestureDetector(
                  onTap: () => context.read<SocialBloc>().add(PostLikeToggled(
                        postId: post.id,
                        userId: currentUserId,
                        isCurrentlyLiked: !isLiked,
                      )),
                  child: Row(
                    children: [
                      Icon(
                        isLiked
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: isLiked
                            ? colorScheme.error
                            : colorScheme.onSurface.withOpacity(0.5),
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${post.likedByUserIds.length}',
                        style: TextStyle(
                            color: colorScheme.onSurface.withOpacity(0.5)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Icon(Icons.mode_comment_outlined,
                    size: 20, color: colorScheme.onSurface.withOpacity(0.5)),
                const SizedBox(width: 4),
                Text('${post.commentCount}',
                    style: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.5))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;

  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.5))),
        ],
      );
}
