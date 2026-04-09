import 'dart:math';

/// Haversine formula - returns distance in meters between two coordinates.
double calculateDistance(
  double lat1,
  double lon1,
  double lat2,
  double lon2,
) {
  const earthRadiusM = 6371000.0;
  final dLat = _toRad(lat2 - lat1);
  final dLon = _toRad(lon2 - lon1);
  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_toRad(lat1)) * cos(_toRad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return earthRadiusM * c;
}

double _toRad(double deg) => deg * pi / 180;

/// Total path distance from a list of [lat, lon] pairs.
double totalPathDistanceM(List<List<double>> coords) {
  if (coords.length < 2) return 0;
  double total = 0;
  for (var i = 0; i < coords.length - 1; i++) {
    total += calculateDistance(
        coords[i][0], coords[i][1], coords[i + 1][0], coords[i + 1][1]);
  }
  return total;
}
