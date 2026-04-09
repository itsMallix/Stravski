import 'package:intl/intl.dart';

String formatDuration(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return h > 0 ? '$h:$m:$s' : '$m:$s';
}

String formatDistance(double meters) {
  if (meters < 1000) {
    return '${meters.toStringAsFixed(0)} m';
  }
  final km = meters / 1000;
  return '${km.toStringAsFixed(2)} km';
}

String formatPace(double paceMinPerKm) {
  if (paceMinPerKm <= 0 || paceMinPerKm.isInfinite || paceMinPerKm.isNaN) {
    return '--:--';
  }
  final mins = paceMinPerKm.floor();
  final secs = ((paceMinPerKm - mins) * 60).round().toString().padLeft(2, '0');
  return "$mins'$secs\"/km";
}

String formatSpeed(double speedKmH) {
  if (speedKmH.isNaN || speedKmH.isInfinite) return '0.0 km/h';
  return '${speedKmH.toStringAsFixed(1)} km/h';
}

String formatCalories(double cal) => '${cal.toStringAsFixed(0)} kcal';

String formatDate(DateTime dt) => DateFormat('dd MMM yyyy').format(dt);
String formatDateTime(DateTime dt) =>
    DateFormat('dd MMM yyyy, HH:mm').format(dt);
String formatTime(DateTime dt) => DateFormat('HH:mm').format(dt);

/// Returns a relative label like "2 days ago", "just now"
String timeAgo(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inSeconds < 60) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return formatDate(dt);
}
