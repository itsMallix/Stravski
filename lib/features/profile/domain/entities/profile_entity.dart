import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String? bio;
  final int totalActivities;
  final double totalDistanceM;

  const ProfileEntity({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.bio,
    this.totalActivities = 0,
    this.totalDistanceM = 0,
  });

  @override
  List<Object?> get props => [
        id, email, displayName, photoUrl, bio,
        totalActivities, totalDistanceM,
      ];
}
