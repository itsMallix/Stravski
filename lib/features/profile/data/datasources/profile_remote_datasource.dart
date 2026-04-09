import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import '../../domain/entities/profile_entity.dart';
import '../../../../core/error/exceptions.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileEntity> getProfile(String userId);
  Future<void> updateProfile(ProfileEntity profile);
  Future<String?> uploadAvatar(
      {required String userId, required String filePath});
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  ProfileRemoteDataSourceImpl({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  @override
  Future<ProfileEntity> getProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) {
        throw ServerException(message: 'Profile not found');
      }
      final data = doc.data()!;
      return ProfileEntity(
        id: userId,
        email: data['email'] as String? ?? '',
        displayName: data['displayName'] as String? ?? '',
        photoUrl: data['photoUrl'] as String?,
        bio: data['bio'] as String?,
        totalActivities: data['totalActivities'] as int? ?? 0,
        totalDistanceM: (data['totalDistanceM'] as num? ?? 0).toDouble(),
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> updateProfile(ProfileEntity profile) async {
    try {
      await _firestore.collection('users').doc(profile.id).update({
        'displayName': profile.displayName,
        'bio': profile.bio,
        if (profile.photoUrl != null) 'photoUrl': profile.photoUrl,
      });
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<String?> uploadAvatar({
    required String userId,
    required String filePath,
  }) async {
    try {
      final ref = _storage.ref('avatars/$userId.jpg');
      await ref.putFile(File(filePath));
      final url = await ref.getDownloadURL();
      await _firestore
          .collection('users')
          .doc(userId)
          .update({'photoUrl': url});
      return url;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
