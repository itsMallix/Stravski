import 'package:uuid/uuid.dart';
import 'package:xml/xml.dart';

import '../../domain/entities/activity_entity.dart';
import '../../domain/repositories/activity_repository.dart';
import '../datasources/activity_local_datasource.dart';
import '../datasources/activity_remote_datasource.dart';
import '../models/activity_model.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';

class ActivityRepositoryImpl implements ActivityRepository {
  final ActivityRemoteDataSource remoteDataSource;
  final ActivityLocalDataSource localDataSource;

  ActivityRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<void> saveActivity(ActivityEntity activity) async {
    try {
      final model = _toModel(activity);
      await remoteDataSource.saveActivity(model);
      await localDataSource.cacheActivity(model);
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message);
    }
  }

  @override
  Future<List<ActivityEntity>> getActivities({
    required String userId,
    int? limit,
  }) async {
    try {
      return await remoteDataSource.getActivities(
          userId: userId, limit: limit);
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message);
    }
  }

  @override
  Future<ActivityEntity> getActivityById(String id) async {
    try {
      return await remoteDataSource.getActivityById(id);
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message);
    }
  }

  @override
  Future<void> deleteActivity(String id) async {
    try {
      await remoteDataSource.deleteActivity(id);
      await localDataSource.clearActivity(id);
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message);
    }
  }

  @override
  Future<String> exportToGpx(ActivityEntity activity) async {
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0" encoding="UTF-8"');
    builder.element('gpx', nest: () {
      builder.attribute('version', '1.1');
      builder.attribute('creator', 'Stravski');
      builder.attribute('xmlns',
          'http://www.topografix.com/GPX/1/1');
      builder.element('trk', nest: () {
        builder.element('name', nest: activity.title);
        builder.element('type',
            nest: activity.type.name);
        builder.element('trkseg', nest: () {
          for (final pt in activity.coordinates) {
            builder.element('trkpt', nest: () {
              builder.attribute('lat', pt.latitude.toString());
              builder.attribute('lon', pt.longitude.toString());
              if (pt.altitude != null) {
                builder.element('ele',
                    nest: pt.altitude.toString());
              }
              builder.element('time',
                  nest: pt.timestamp.toUtc().toIso8601String());
            });
          }
        });
      });
    });
    return builder.buildDocument().toXmlString(pretty: true);
  }

  ActivityModel _toModel(ActivityEntity e) => ActivityModel(
        id: e.id.isEmpty ? const Uuid().v4() : e.id,
        userId: e.userId,
        type: e.type,
        title: e.title,
        startTime: e.startTime,
        endTime: e.endTime,
        duration: e.duration,
        distanceMeters: e.distanceMeters,
        averagePaceMinPerKm: e.averagePaceMinPerKm,
        averageSpeedKmH: e.averageSpeedKmH,
        caloriesBurned: e.caloriesBurned,
        coordinates: e.coordinates,
        heartRateZone: e.heartRateZone,
        notes: e.notes,
      );
}
