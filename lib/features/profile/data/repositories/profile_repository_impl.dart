import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ProfileEntity> getProfile(String userId) async {
    try {
      return await remoteDataSource.getProfile(userId);
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message);
    }
  }

  @override
  Future<void> updateProfile(ProfileEntity profile) async {
    try {
      return await remoteDataSource.updateProfile(profile);
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message);
    }
  }

  @override
  Future<String?> uploadAvatar(
      {required String userId, required String filePath}) async {
    try {
      return await remoteDataSource.uploadAvatar(
          userId: userId, filePath: filePath);
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message);
    }
  }
}
