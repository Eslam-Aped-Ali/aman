import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure({
    required this.message,
    this.statusCode,
  });

  @override
  List<Object?> get props => [message, statusCode];
}

class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.statusCode,
  });
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    required super.message,
    super.statusCode,
  });
}

class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    super.statusCode,
  });
}

class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    super.statusCode,
  });
}

class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.statusCode,
  });
}

class TimeoutFailure extends Failure {
  const TimeoutFailure({
    required super.message,
    super.statusCode,
  });
}

class UnknownFailure extends Failure {
  const UnknownFailure({
    required super.message,
    super.statusCode,
  });
}

class LocalFailure extends Failure {
  const LocalFailure(String message) : super(message: message);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(String message) : super(message: message);
}

// Legacy support - keeping for backward compatibility
class AuthenticationFailure extends AuthFailure {
  const AuthenticationFailure({
    required super.message,
    super.statusCode,
  });
}
