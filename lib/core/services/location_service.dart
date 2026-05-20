import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../error/exceptions.dart';

class LocationService {
  StreamSubscription<Position>? _subscription;

  Future<void> checkAndRequestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationException(message: 'Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw const LocationException(message: 'Location permission denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw const LocationException(
          message:
              'Location permissions are permanently denied. Enable them in settings.');
    }
  }

  Future<Position> getCurrentPosition() async {
    await checkAndRequestPermission();
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }

  Stream<Position> getPositionStream() {
    LocationSettings locationSettings;

    if (defaultTargetPlatform == TargetPlatform.android) {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 0,
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationText: "Tracking your position ...",
          notificationTitle: "Hashiru Active",
          enableWakeLock: true,
        ),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 0,
        activityType: ActivityType.fitness,
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: true,
      );
    } else {
      locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 0,
      );
    }

    return Geolocator.getPositionStream(
      locationSettings: locationSettings,
    );
  }

  void dispose() {
    _subscription?.cancel();
  }
}
