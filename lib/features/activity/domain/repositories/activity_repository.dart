import '../entities/activity_entity.dart';

abstract class ActivityRepository {
  Future<void> saveActivity(ActivityEntity activity);
  Future<List<ActivityEntity>> getActivities({required String userId, int? limit});
  Future<ActivityEntity> getActivityById(String id);
  Future<void> deleteActivity(String id);
  Future<String> exportToGpx(ActivityEntity activity);
}
