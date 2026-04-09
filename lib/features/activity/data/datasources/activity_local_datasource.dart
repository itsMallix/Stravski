import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/activity_model.dart';
import '../../../../core/error/exceptions.dart';

abstract class ActivityLocalDataSource {
  Future<void> cacheActivity(ActivityModel activity);
  Future<ActivityModel?> getCachedActivity(String id);
  Future<void> clearActivity(String id);
}

class ActivityLocalDataSourceImpl implements ActivityLocalDataSource {
  static const String _prefix = 'activity_cache_';

  @override
  Future<void> cacheActivity(ActivityModel activity) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Store only minimal metadata (not full coordinate list) for performance
      final data = {
        'id': activity.id,
        'distanceMeters': activity.distanceMeters,
        'durationSeconds': activity.duration.inSeconds,
        'title': activity.title,
      };
      await prefs.setString('$_prefix${activity.id}', jsonEncode(data));
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<ActivityModel?> getCachedActivity(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('$_prefix$id');
      if (raw == null) return null;
      // Returns null – let caller fall through to remote
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clearActivity(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_prefix$id');
  }
}
