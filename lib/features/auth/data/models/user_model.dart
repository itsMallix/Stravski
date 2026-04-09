import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.displayName,
    super.photoUrl,
    required super.createdAt,
    super.totalActivities,
    super.followersCount,
    super.followingCount,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      email: map['email'] as String? ?? '',
      displayName: map['displayName'] as String? ?? '',
      photoUrl: map['photoUrl'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (map['createdAt'] as int))
          : DateTime.now(),
      totalActivities: map['totalActivities'] as int? ?? 0,
      followersCount: map['followersCount'] as int? ?? 0,
      followingCount: map['followingCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'email': email,
        'displayName': displayName,
        'photoUrl': photoUrl,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'totalActivities': totalActivities,
        'followersCount': followersCount,
        'followingCount': followingCount,
      };
}
