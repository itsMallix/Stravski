import 'dart:async';

import 'package:geolocator/geolocator.dart';

import '../error/exceptions.dart';

class LocationService {
  StreamSubscription<Position>? _subscription;

  Future<void> checkAndRequestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationException(
          message: 'Location services are disabled.');
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
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // meters
      ),
    );
  }

  void dispose() {
    _subscription?.cancel();
  }
}
