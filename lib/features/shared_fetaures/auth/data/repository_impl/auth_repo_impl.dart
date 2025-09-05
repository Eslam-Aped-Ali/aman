// lib/data/repositories/auth_repository_impl.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:Aman/features/shared_fetaures/auth/data/datasource/locale/auth_local_data_source.dart';
import 'package:Aman/features/shared_fetaures/auth/data/datasource/remote/auth_remote_data_source_abstract.dart';
import 'package:Aman/features/shared_fetaures/auth/domain/entities/user.dart';
import 'package:Aman/features/shared_fetaures/auth/domain/repositories/auth_repo.dart';
import 'package:dartz/dartz.dart';
import 'package:Aman/core/shared/error_handling/failures.dart';
import 'package:Aman/generated/locale_keys.g.dart';
import 'package:Aman/core/shared/services/admin_validation_service.dart';

// تنفيذ مستودع المصادقة
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  // تسجيل مستخدم جديد
  @override
  Future<Either<Failure, String>> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
  }) async {
    try {
      // التحقق من صحة البيانات المدخلة
      final validationError = _validateRegistrationData(
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
      );

      if (validationError != null) {
        return Left(ValidationFailure(message: validationError));
      }

      // التحقق من صلاحية المدير إذا كان الدور هو مدير
      if (role == UserRole.ADMIN) {
        if (!AdminValidationService.isAuthorizedAdmin(phone)) {
          return Left(ValidationFailure(
            message: LocaleKeys.auth_adminNotAuthorized.tr(),
          ));
        }
      }

      // إرسال طلب التسجيل
      final message = await _remoteDataSource.register(
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
        role: role.value,
      );

      return Right(message);
    } on Exception catch (e) {
      // معالجة الأخطاء وتحويلها لفشل
      return Left(_mapExceptionToFailure(e));
    }
  }

  // تسجيل الدخول
  @override
  Future<Either<Failure, User>> login({
    required String phone,
    required String password,
  }) async {
    try {
      // التحقق من صحة البيانات المدخلة
      if (phone.isEmpty || password.isEmpty) {
        return const Left(ValidationFailure(
          message: 'Phone and password are required',
        ));
      }

      // إرسال طلب تسجيل الدخول
      final userModel = await _remoteDataSource.login(
        phone: phone,
        password: password,
      );

      // التحقق من صلاحية المدير بعد تسجيل الدخول الناجح
      if (userModel.role == UserRole.ADMIN) {
        if (!AdminValidationService.isAuthorizedAdmin(phone)) {
          return Left(ValidationFailure(
            message: LocaleKeys.auth_adminAccessDenied.tr(),
          ));
        }
      }

      // حفظ بيانات المستخدم ورمز التوثيق محلياً
      await _localDataSource.cacheUser(userModel);
      if (userModel.token != null) {
        await _localDataSource.saveToken(userModel.token!);
      }

      return Right(userModel);
    } on Exception catch (e) {
      // معالجة الأخطاء
      return Left(_mapExceptionToFailure(e));
    }
  }

  // تسجيل الخروج
  @override
  Future<Either<Failure, void>> logout() async {
    try {
      // مسح البيانات المحلية
      await _localDataSource.clearCachedUser();
      await _localDataSource.deleteToken();

      return const Right(null);
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  // جلب المستخدم الحالي
  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      // جلب المستخدم من التخزين المحلي
      final user = await _localDataSource.getCachedUser();
      return Right(user);
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  // جلب رمز التوثيق
  @override
  Future<Either<Failure, String?>> getToken() async {
    try {
      final token = await _localDataSource.getToken();
      return Right(token);
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  // حفظ رمز التوثيق
  @override
  Future<Either<Failure, void>> saveToken(String token) async {
    try {
      await _localDataSource.saveToken(token);
      return const Right(null);
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  // حذف رمز التوثيق
  @override
  Future<Either<Failure, void>> deleteToken() async {
    try {
      await _localDataSource.deleteToken();
      return const Right(null);
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  // التحقق من صحة بيانات التسجيل
  String? _validateRegistrationData({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) {
    if (fullName.trim().isEmpty) {
      return LocaleKeys.auth_registrationFailed.tr();
    }

    if (fullName.trim().length < 2) {
      return LocaleKeys.auth_registrationFailed.tr();
    }

    if (!_isValidEmail(email)) {
      return LocaleKeys.auth_invalidEmailFormat.tr();
    }

    if (!_isValidPhone(phone)) {
      return LocaleKeys.auth_invalidPhoneFormat.tr();
    }

    if (password.length < 6) {
      return LocaleKeys.auth_weakPassword.tr();
    }

    return null;
  }

  // التحقق من صحة البريد الإلكتروني
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    // Additional checks for common email issues
    if (email.length < 5 || email.length > 254) {
      return false;
    }

    // Check for valid domain
    if (!email.contains('@') || email.split('@').length != 2) {
      return false;
    }

    final parts = email.split('@');
    if (parts[0].isEmpty || parts[1].isEmpty) {
      return false;
    }

    return emailRegex.hasMatch(email);
  }

  // التحقق من صحة رقم الهاتف
  bool _isValidPhone(String phone) {
    // Remove any spaces or special characters
    final cleanPhone = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // Oman phone number validation
    // Oman country code: +968
    // Mobile numbers: 9XXXXXXX, 7XXXXXXX, 8XXXXXXX (8 digits after the first digit)
    // Landline numbers: 2XXXXXXX, 2XXXXXX (6-7 digits after 2)

    // Support various formats:
    // +96899999999, +96879999999, +96899999999
    // 96899999999, 96879999999, 96899999999
    // 99999999, 79999999, 89999999
    // 9999999, 7999999, 8999999 (some might be shorter)

    // Full international format: +968XXXXXXXX
    if (cleanPhone.startsWith('+968')) {
      final localNumber = cleanPhone.substring(4);
      return _isValidOmanLocalNumber(localNumber);
    }

    // Without + but with country code: 968XXXXXXXX
    if (cleanPhone.startsWith('968') && cleanPhone.length >= 11) {
      final localNumber = cleanPhone.substring(3);
      return _isValidOmanLocalNumber(localNumber);
    }

    // Local format: 9XXXXXXX, 7XXXXXXX, 8XXXXXXX, 2XXXXXXX
    return _isValidOmanLocalNumber(cleanPhone);
  }

  // Validate Oman local phone number
  bool _isValidOmanLocalNumber(String localNumber) {
    // Mobile numbers (8 digits): 9XXXXXXX, 7XXXXXXX, 8XXXXXXX
    if (localNumber.length == 8) {
      return RegExp(r'^[9|7|8][0-9]{7}$').hasMatch(localNumber);
    }

    // Landline numbers (7 digits): 2XXXXXXX
    if (localNumber.length == 7) {
      return RegExp(r'^2[0-9]{6}$').hasMatch(localNumber);
    }

    // Some older mobile formats might be 7 digits starting with 9
    if (localNumber.length == 7 && localNumber.startsWith('9')) {
      return RegExp(r'^9[0-9]{6}$').hasMatch(localNumber);
    }

    return false;
  }

// In auth_repository_impl.dart
  Failure _mapExceptionToFailure(Exception e) {
    final message = e.toString().replaceAll('Exception: ', '');

    // Check for specific error patterns
    if (message.contains('No internet') || message.contains('network')) {
      return const NetworkFailure(message: 'No internet connection');
    } else if (message.contains('timeout')) {
      return const NetworkFailure(message: 'Connection timeout');
    } else if (message.contains('already exists') || message.contains('409')) {
      return const ValidationFailure(message: 'This account already exists');
    } else if (message.contains('Invalid credentials') ||
        message.contains('401')) {
      return AuthenticationFailure(
          message: LocaleKeys.auth_invalidCredentials.tr());
    } else if (message.contains('Incorrect password')) {
      return AuthenticationFailure(
          message: LocaleKeys.auth_incorrectPassword.tr());
    } else if (message.contains('Phone number not found') ||
        message.contains('not found') ||
        message.contains('404')) {
      return AuthenticationFailure(message: LocaleKeys.auth_phoneNotFound.tr());
    } else if (message.contains('forbidden') || message.contains('403')) {
      return const AuthenticationFailure(message: 'Access denied');
    } else if (message.contains('validation') || message.contains('422')) {
      return ValidationFailure(message: message);
    } else if (message.contains('Server error') || message.contains('500')) {
      // For registration context, provide more specific server error message
      if (message.contains('register')) {
        return ServerFailure(
            message: LocaleKeys.auth_registrationServerError.tr());
      } else {
        return ServerFailure(message: LocaleKeys.auth_serverError.tr());
      }
    } else {
      return ServerFailure(message: message);
    }
  }
}
