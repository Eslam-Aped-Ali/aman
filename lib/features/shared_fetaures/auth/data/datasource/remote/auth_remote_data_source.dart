import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:Aman/core/shared/services/dio_service.dart';
import 'package:Aman/features/shared_fetaures/auth/data/datasource/remote/auth_remote_data_source_abstract.dart';
import 'package:Aman/features/shared_fetaures/auth/data/models/user_model.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioService _dioService;

  AuthRemoteDataSourceImpl({required DioService dioService})
      : _dioService = dioService;

  @override
  Future<String> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    final requestBody = {
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'password': password,
      'role': role,
    };

    // Use dynamic type since response is plain text
    final response = await _dioService.post<dynamic>(
      path: '/auth/register',
      data: requestBody,
      requireAuth: false,
    );

    return response.when(
      success: (data) {
        if (data == null) return 'User registered successfully';

        // Handle both string and dynamic responses
        if (data is String) {
          return data;
        } else if (data is Map<String, dynamic>) {
          return data['message'] ?? 'User registered successfully';
        }
        return data.toString();
      },
      error: (message, error) {
        throw _handleError(message, error);
      },
    );
  }

  @override
  Future<UserModel> login({
    required String phone,
    required String password,
  }) async {
    final requestBody = {
      'phone': phone,
      'password': int.tryParse(password) ?? password,
    };

    // Change to dynamic to handle string response
    final response = await _dioService.post<dynamic>(
      path: '/auth/login',
      data: requestBody,
      requireAuth: false,
      headers: {
        'Content-Type': 'application/json',
        'Accept': '*/*',
      },
    );

    return response.when(
      success: (data) {
        if (data == null) {
          throw Exception(
              'Invalid credentials. Please check your phone number and password.');
        }

        try {
          // Parse the response based on its type
          Map<String, dynamic> jsonData;

          if (data is String) {
            jsonData = json.decode(data);
          } else if (data is Map<String, dynamic>) {
            jsonData = data;
          } else {
            throw Exception(
                'Invalid credentials or server error. Please try again.');
          }

          return UserModel.fromJson(jsonData);
        } catch (e) {
          throw Exception(
              'Invalid credentials. Please check your phone number and password.');
        }
      },
      error: (message, error) {
        final errorMessage = message?.toLowerCase() ?? '';

        if (errorMessage.contains('invalid credentials') ||
            errorMessage.contains('incorrect password') ||
            errorMessage.contains('not found')) {
          throw Exception(
              'Invalid phone number or password. Please try again.');
        } else if (errorMessage.contains('too many attempts')) {
          throw Exception('Too many login attempts. Please try again later.');
        } else if (errorMessage.contains('account locked')) {
          throw Exception(
              'Your account has been locked. Please contact support.');
        } else if (errorMessage.contains('not verified')) {
          throw Exception('Please verify your account first.');
        } else {
          throw _handleError(message, error);
        }
      },
    );

    // (Removed duplicate response.when block to fix dead code error)
  }

  // Handle errors and convert them to appropriate exceptions
  Exception _handleError(String? message, dynamic error) {
    // Check if error is a DioException and has response data
    if (error is DioException && error.response?.data != null) {
      final errorData = error.response!.data;
      String errorMessage;

      if (errorData is String) {
        errorMessage = errorData;
      } else if (errorData is Map<String, dynamic>) {
        errorMessage = errorData['message'] ??
            errorData['error'] ??
            'Unknown error occurred';
      } else {
        errorMessage = 'Unknown error occurred';
      }

      // Handle specific error cases
      if (errorMessage.toLowerCase().contains('already exists')) {
        return Exception(
            'This user already exists. Please try logging in instead.');
      } else if (errorMessage.toLowerCase().contains('invalid credentials') ||
          errorMessage.toLowerCase().contains('incorrect password')) {
        return Exception(
            'Invalid phone number or password. Please check your credentials and try again.');
      } else if (errorMessage.toLowerCase().contains('not found')) {
        return Exception(
            'User not found. Please check your phone number or register first.');
      } else if (error.response?.statusCode == 401) {
        return Exception(
            'Invalid credentials. Please check your phone number and password.');
      } else if (error.response?.statusCode == 403) {
        return Exception(
            'Access denied. Please contact support if this persists.');
      } else if (error.response?.statusCode == 429) {
        return Exception('Too many attempts. Please try again later.');
      } else if (error.response?.statusCode == 422) {
        return Exception('Please check your input and try again.');
      }

      return Exception(errorMessage);
    }

    // Handle network related errors
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return Exception(
              'Connection timeout. Please check your internet connection and try again.');
        case DioExceptionType.connectionError:
          return Exception(
              'Connection error. Please check your internet connection.');
        case DioExceptionType.cancel:
          return Exception('Request was cancelled. Please try again.');
        default:
          return Exception('Network error occurred. Please try again.');
      }
    }

    // Default error message
    return Exception(
        message ?? 'An unexpected error occurred. Please try again.');
  }
}
