class ServerException implements Exception {
  final String message;
  const ServerException({required this.message});
  @override
  String toString() => 'ServerException: $message';
}

class CacheException implements Exception {
  final String message;
  const CacheException({required this.message});
  @override
  String toString() => 'CacheException: $message';
}

class LocationException implements Exception {
  final String message;
  const LocationException({required this.message});
  @override
  String toString() => 'LocationException: $message';
}

class AuthException implements Exception {
  final String message;
  const AuthException({required this.message});
  @override
  String toString() => 'AuthException: $message';
}

class PermissionException implements Exception {
  final String message;
  const PermissionException(
      {required this.message});
  @override
  String toString() => 'PermissionException: $message';
}
