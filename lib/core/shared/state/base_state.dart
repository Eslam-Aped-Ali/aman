import 'package:equatable/equatable.dart';
import 'package:Aman/core/shared/error_handling/failures.dart';

enum AppStatus {
  initial,
  loading,
  success,
  error,
  empty,
  offline,
}

enum RequestStatus {
  idle,
  loading,
  success,
  error,
}

abstract class BaseState extends Equatable {
  final AppStatus status;
  final Failure? failure;
  final String? message;

  const BaseState({
    this.status = AppStatus.initial,
    this.failure,
    this.message,
  });

  bool get isInitial => status == AppStatus.initial;
  bool get isLoading => status == AppStatus.loading;
  bool get isSuccess => status == AppStatus.success;
  bool get isError => status == AppStatus.error;
  bool get isEmpty => status == AppStatus.empty;
  bool get isOffline => status == AppStatus.offline;

  @override
  List<Object?> get props => [status, failure, message];
}

class BaseLoadingState extends BaseState {
  const BaseLoadingState({super.message})
      : super(
          status: AppStatus.loading,
        );
}

class BaseSuccessState extends BaseState {
  const BaseSuccessState({super.message})
      : super(
          status: AppStatus.success,
        );
}

class BaseErrorState extends BaseState {
  const BaseErrorState({
    required Failure super.failure,
    super.message,
  }) : super(
          status: AppStatus.error,
        );
}

class BaseEmptyState extends BaseState {
  const BaseEmptyState({super.message})
      : super(
          status: AppStatus.empty,
        );
}

class BaseOfflineState extends BaseState {
  const BaseOfflineState({super.message})
      : super(
          status: AppStatus.offline,
        );
}
