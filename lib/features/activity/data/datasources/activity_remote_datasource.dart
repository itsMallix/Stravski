import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/activity_model.dart';
import '../../../../core/error/exceptions.dart';

abstract class ActivityRemoteDataSource {
  Future<void> saveActivity(ActivityModel activity);
  Future<List<ActivityModel>> getActivities(
      {required String userId, int? limit});
  Future<ActivityModel> getActivityById(String id);
  Future<void> deleteActivity(String id);
}

class ActivityRemoteDataSourceImpl implements ActivityRemoteDataSource {
  final FirebaseFirestore _firestore;

  ActivityRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('activities');

  @override
  Future<void> saveActivity(ActivityModel activity) async {
    try {
      await _collection.doc(activity.id).set(activity.toFirestore());
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<ActivityModel>> getActivities({
    required String userId,
    int? limit,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _collection
          .where('userId', isEqualTo: userId)
          .orderBy('startTime', descending: true);
      if (limit != null) query = query.limit(limit);
      final snap = await query.get();
      return snap.docs.map(ActivityModel.fromFirestore).toList();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<ActivityModel> getActivityById(String id) async {
    try {
      final doc = await _collection.doc(id).get();
      if (!doc.exists) {
        throw const ServerException(message: 'Activity not found');
      }
      return ActivityModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> deleteActivity(String id) async {
    try {
      await _collection.doc(id).delete();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
