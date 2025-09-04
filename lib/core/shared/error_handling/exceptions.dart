import 'package:equatable/equatable.dart';

abstract class AppException extends Equatable implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  const AppException({
    required this.message,
    this.statusCode,
    this.data,
  });

  @override
  List<Object?> get props => [message, statusCode, data];

  @override
  String toString() => message;
}

class ServerException extends AppException {
  const ServerException({
    required super.message,
    super.statusCode,
    super.data,
  });
}

class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.statusCode,
    super.data,
  });
}

class CacheException extends AppException {
  const CacheException({
    required super.message,
    super.statusCode,
    super.data,
  });
}

class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.statusCode,
    super.data,
  });
}

class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.statusCode,
    super.data,
  });
}

class TimeoutException extends AppException {
  const TimeoutException({
    required super.message,
    super.statusCode,
    super.data,
  });
}

class UnknownException extends AppException {
  const UnknownException({
    required super.message,
    super.statusCode,
    super.data,
  });
}
