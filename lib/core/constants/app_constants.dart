class AppConstants {
  AppConstants._();

  // Map
  static const double defaultMapZoom = 16.0;
  static const double routeMapZoom = 13.0;
  static const double mapPolylineWidth = 4.0;

  // Activity
  static const int locationUpdateIntervalMs = 1000;
  static const double minDistanceFilterMeters = 5.0;
  static const double metersPerKm = 1000.0;
  static const double caloriesPerMeterRun = 0.06; // rough estimate per meter
  static const double caloriesPerMeterRide = 0.03;
  static const double caloriesPerMeterWalk = 0.04;

  // Heart Rate Zones (% of max HR)
  static const double zone1Max = 0.60;
  static const double zone2Max = 0.70;
  static const double zone3Max = 0.80;
  static const double zone4Max = 0.90;
  // Zone 5: > 90%

  // Pagination
  static const int activitiesPageSize = 20;
  static const int feedPageSize = 15;

  // Cache
  static const String cachedUserKey = 'cached_user';
  static const Duration cacheMaxAge = Duration(hours: 24);

  // GPX
  static const String gpxMimeType = 'application/gpx+xml';

  // Storage paths
  static const String avatarsPath = 'avatars';
  static const String activityPhotosPath = 'activity_photos';
}
