import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final DateTime createdAt;
  final int totalActivities;
  final int followersCount;
  final int followingCount;

  const UserEntity({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    required this.createdAt,
    this.totalActivities = 0,
    this.followersCount = 0,
    this.followingCount = 0,
  });

  @override
  List<Object?> get props => [
        id,
        email,
        displayName,
        photoUrl,
        createdAt,
        totalActivities,
        followersCount,
        followingCount,
      ];
}
