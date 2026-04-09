abstract class Failure {
  final String message;
  const Failure({required this.message});
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message});
}

class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

class LocationFailure extends Failure {
  const LocationFailure({required super.message});
}

class AuthFailure extends Failure {
  const AuthFailure({required super.message});
}

class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'No internet connection'});
}

class PermissionFailure extends Failure {
  const PermissionFailure({super.message = 'Permission denied'});
}

class UnknownFailure extends Failure {
  const UnknownFailure({super.message = 'An unexpected error occurred'});
}
