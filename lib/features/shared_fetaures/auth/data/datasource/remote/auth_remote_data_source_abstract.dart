import 'package:Aman/features/shared_fetaures/auth/data/models/user_model.dart';

// واجهة مصدر البيانات البعيد
abstract class AuthRemoteDataSource {
  Future<String> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String role,
  });

  Future<UserModel> login({
    required String phone,
    required String password,
  });
}
