// lib/data/repositories/auth_repository_impl.dart
import 'package:Aman/features/shared_fetaures/auth/data/datasource/locale/auth_local_data_source.dart';
import 'package:Aman/features/shared_fetaures/auth/data/datasource/remote/auth_remote_data_source_abstract.dart';
import 'package:Aman/features/shared_fetaures/auth/domain/entities/user.dart';
import 'package:Aman/features/shared_fetaures/auth/domain/repositories/auth_repo.dart';
import 'package:dartz/dartz.dart';
import 'package:Aman/core/shared/error_handling/failures.dart';

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
      return 'Full name is required';
    }

    if (!_isValidEmail(email)) {
      return 'Invalid email format';
    }

    if (!_isValidPhone(phone)) {
      return 'Invalid phone number';
    }

    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  // التحقق من صحة البريد الإلكتروني
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  // التحقق من صحة رقم الهاتف
  bool _isValidPhone(String phone) {
    // يمكنك تعديل هذا حسب متطلبات بلدك
    return phone.length >= 10 && RegExp(r'^[0-9]+$').hasMatch(phone);
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
      return const AuthenticationFailure(message: 'Invalid credentials');
    } else if (message.contains('not found') || message.contains('404')) {
      return const AuthenticationFailure(message: 'User not found');
    } else if (message.contains('forbidden') || message.contains('403')) {
      return const AuthenticationFailure(message: 'Access denied');
    } else if (message.contains('validation') || message.contains('422')) {
      return ValidationFailure(message: message);
    } else if (message.contains('Server error') || message.contains('500')) {
      return const ServerFailure(
          message: 'Server error. Please try again later.');
    } else {
      return ServerFailure(message: message);
    }
  }
}
