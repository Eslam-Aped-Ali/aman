// lib/features/shared_features/auth/presentation/bloc/auth_cubit.dart
import 'package:Aman/core/shared/usecases/usecase_abstract.dart';
import 'package:Aman/features/shared_fetaures/auth/domain/entities/user.dart';
import 'package:Aman/features/shared_fetaures/auth/domain/usecases/get_user_usecase.dart';
import 'package:Aman/features/shared_fetaures/auth/domain/usecases/login_usecase.dart';
import 'package:Aman/features/shared_fetaures/auth/domain/usecases/logout_usecase.dart';
import 'package:Aman/features/shared_fetaures/auth/domain/usecases/register_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Aman/core/shared/utils/enums.dart';

import 'auth_state.dart';

// Cubit بسيط لإدارة حالة المصادقة
class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;

  // متغيرات لحفظ البيانات المؤقتة
  User? _currentUser;
  String? _tempPhoneNumber;
  UserRole _selectedRole = UserRole.PASSENGER;

  AuthCubit({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required LogoutUseCase logoutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
  })  : _loginUseCase = loginUseCase,
        _registerUseCase = registerUseCase,
        _logoutUseCase = logoutUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        super(AuthState());

  // Getters
  User? get currentUser => _currentUser;
  String? get tempPhoneNumber => _tempPhoneNumber;
  UserRole get selectedRole => _selectedRole;

  // تعيين رقم الهاتف المؤقت
  void setTempPhoneNumber(String phone) {
    _tempPhoneNumber = phone;
  }

  // تعيين الدور المختار
  void setSelectedRole(UserRole role) {
    _selectedRole = role;
  }

  // تسجيل مستخدم جديد
  Future<void> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    UserRole? role,
  }) async {
    emit(state.copyWith(requestState: RequestState.loading));

    final result = await _registerUseCase(
      RegisterParams(
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
        role: role ?? _selectedRole,
      ),
    );

    result.fold(
      (failure) {
        emit(state.copyWith(
          requestState: RequestState.error,
          msg: failure.message,
          errorType: _mapFailureToErrorType(failure.message),
        ));
      },
      (message) {
        emit(state.copyWith(
          requestState: RequestState.done,
          msg: message,
        ));
      },
    );
  }

  // تسجيل الدخول
  Future<void> login({
    required String phone,
    required String password,
  }) async {
    emit(state.copyWith(requestState: RequestState.loading));

    final result = await _loginUseCase(
      LoginParams(
        phone: phone,
        password: password,
      ),
    );

    result.fold(
      (failure) {
        emit(state.copyWith(
          requestState: RequestState.error,
          msg: failure.message,
          errorType: _mapFailureToErrorType(failure.message),
        ));
      },
      (user) {
        _currentUser = user;
        emit(state.copyWith(
          requestState: RequestState.done,
          msg: 'Login successful',
        ));
      },
    );
  }

  // تسجيل الخروج
  Future<void> logout() async {
    emit(state.copyWith(requestState: RequestState.loading));

    final result = await _logoutUseCase(NoParams());

    result.fold(
      (failure) {
        emit(state.copyWith(
          requestState: RequestState.error,
          msg: failure.message,
        ));
      },
      (_) {
        _currentUser = null;
        emit(state.copyWith(
          requestState: RequestState.done,
          msg: 'Logged out successfully',
        ));
      },
    );
  }

  // جلب المستخدم الحالي
  Future<void> getCurrentUser() async {
    emit(state.copyWith(requestState: RequestState.loading));

    final result = await _getCurrentUserUseCase(NoParams());

    result.fold(
      (failure) {
        emit(state.copyWith(
          requestState: RequestState.error,
          msg: failure.message,
        ));
      },
      (user) {
        _currentUser = user;
        emit(state.copyWith(
          requestState: RequestState.done,
        ));
      },
    );
  }

  // إعادة تعيين الحالة
  void reset() {
    emit(AuthState());
  }

  // تحويل رسالة الفشل إلى نوع الخطأ
  ErrorType _mapFailureToErrorType(String message) {
    if (message.contains('network') || message.contains('internet')) {
      return ErrorType.network;
    } else if (message.contains('not found')) {
      return ErrorType.unknown;
    } else if (message.contains('unauthorized')) {
      return ErrorType.unAuth;
    } else if (message.contains('validation')) {
      return ErrorType.validation;
    } else {
      return ErrorType.server;
    }
  }
}
