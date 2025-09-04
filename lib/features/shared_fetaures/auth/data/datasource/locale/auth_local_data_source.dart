// lib/data/datasources/auth_local_data_source.dart
import 'dart:convert';

import 'package:Aman/core/shared/services/storage_service.dart';
import 'package:Aman/features/shared_fetaures/auth/data/models/user_model.dart';

// واجهة مصدر البيانات المحلي
abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<void> clearCachedUser();

  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> deleteToken();
}

// تنفيذ مصدر البيانات المحلي
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  // مفاتيح التخزين
  static const String _userKey = 'cached_user';
  static const String _tokenKey = 'auth_token';

  // حفظ بيانات المستخدم محلياً
  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      // تحويل المستخدم إلى JSON وحفظه
      final userJson = json.encode(user.toJson());
      await StorageService.setString(_userKey, userJson);
    } catch (e) {
      throw Exception('Failed to cache user: $e');
    }
  }

  // جلب بيانات المستخدم المحفوظة
  @override
  Future<UserModel?> getCachedUser() async {
    try {
      // جلب البيانات المحفوظة
      final userJson = StorageService.getString(_userKey);
      if (userJson != null) {
        // تحويل JSON إلى نموذج المستخدم
        final userMap = json.decode(userJson) as Map<String, dynamic>;
        return UserModel.fromJson(userMap);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get cached user: $e');
    }
  }

  // مسح بيانات المستخدم المحفوظة
  @override
  Future<void> clearCachedUser() async {
    try {
      await StorageService.remove(_userKey);
    } catch (e) {
      throw Exception('Failed to clear cached user: $e');
    }
  }

  // حفظ رمز التوثيق
  @override
  Future<void> saveToken(String token) async {
    try {
      await StorageService.setString(_tokenKey, token);
    } catch (e) {
      throw Exception('Failed to save token: $e');
    }
  }

  // جلب رمز التوثيق
  @override
  Future<String?> getToken() async {
    try {
      return StorageService.getString(_tokenKey);
    } catch (e) {
      throw Exception('Failed to get token: $e');
    }
  }

  // حذف رمز التوثيق
  @override
  Future<void> deleteToken() async {
    try {
      await StorageService.remove(_tokenKey);
    } catch (e) {
      throw Exception('Failed to delete token: $e');
    }
  }
}
