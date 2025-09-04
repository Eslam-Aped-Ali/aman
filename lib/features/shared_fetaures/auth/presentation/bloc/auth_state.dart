import 'package:Aman/core/shared/utils/enums.dart';

class AuthState {
  final RequestState requestState;
  final String msg;
  final ErrorType errorType;

  AuthState({
    this.requestState = RequestState.initial,
    this.msg = '',
    this.errorType = ErrorType.none,
  });

  AuthState copyWith({
    RequestState? requestState,
    String? msg,
    ErrorType? errorType,
  }) =>
      AuthState(
        requestState: requestState ?? this.requestState,
        msg: msg ?? this.msg,
        errorType: errorType ?? this.errorType,
      );
}
