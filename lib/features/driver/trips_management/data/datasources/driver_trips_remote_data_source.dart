import 'package:dio/dio.dart';
import '../models/api_trip_model.dart';
import '../../../../../core/shared/costants/app_constants.dart';
import '../../../../../core/shared/services/storage_service.dart';

abstract class DriverTripsRemoteDataSource {
  Future<List<ApiTripModel>> getTripsByDriverAndStatus(
      int driverId, String status);
  Future<List<ApiTripModel>> getCurrentTrips(int driverId);
  Future<List<ApiTripModel>> getCompletedTrips(int driverId);
  Future<List<ApiTripModel>> getAllDriverTrips(int driverId);
}

class DriverTripsRemoteDataSourceImpl implements DriverTripsRemoteDataSource {
  final Dio _dio;

  DriverTripsRemoteDataSourceImpl({Dio? dio}) : _dio = dio ?? Dio() {
    _setupDio();
  }

  void _setupDio() {
    _dio.options.baseUrl = ApiConstants.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);

    // Add request interceptor for authentication
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Get auth token from storage
        final token = StorageService.getString('auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        // Add content type
        options.headers['Content-Type'] = 'application/json';

        handler.next(options);
      },
      onError: (error, handler) {
        // Handle common errors
        if (error.response?.statusCode == 401) {
          // Token expired - could trigger logout
          print('Authentication failed - token may be expired');
        }
        handler.next(error);
      },
    ));
  }

  @override
  Future<List<ApiTripModel>> getTripsByDriverAndStatus(
      int driverId, String status) async {
    try {
      final response = await _dio.get(
        '/trips/by-driver/$driverId',
        queryParameters: {'status': status},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data
            .map((json) => ApiTripModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to fetch trips: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  @override
  Future<List<ApiTripModel>> getCurrentTrips(int driverId) async {
    return getTripsByDriverAndStatus(driverId, 'ASSIGNED');
  }

  @override
  Future<List<ApiTripModel>> getCompletedTrips(int driverId) async {
    return getTripsByDriverAndStatus(driverId, 'COMPLETED');
  }

  @override
  Future<List<ApiTripModel>> getAllDriverTrips(int driverId) async {
    try {
      final response = await _dio.get('/trips/by-driver/$driverId');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data
            .map((json) => ApiTripModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to fetch trips: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception(
            'Connection timeout. Please check your internet connection.');

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        switch (statusCode) {
          case 400:
            return Exception('Invalid request. Please check your data.');
          case 401:
            return Exception('Authentication failed. Please login again.');
          case 403:
            return Exception('Access denied. You don\'t have permission.');
          case 404:
            return Exception('Trips not found.');
          case 500:
            return Exception('Server error. Please try again later.');
          default:
            return Exception('Request failed with status: $statusCode');
        }

      case DioExceptionType.cancel:
        return Exception('Request was cancelled.');

      case DioExceptionType.connectionError:
        return Exception('No internet connection. Please check your network.');

      case DioExceptionType.badCertificate:
        return Exception('Certificate error. Please check your connection.');

      case DioExceptionType.unknown:
        return Exception('Something went wrong. Please try again.');
    }
  }
}
