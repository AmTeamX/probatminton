import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({required this.message, this.statusCode, this.data});

  factory ApiException.fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(message: 'Connection timed out. Please try again.');
      case DioExceptionType.badResponse:
        final data = error.response?.data;
        final message = data is Map
            ? data['message'] ?? 'Server error occurred'
            : 'Server error occurred';
        return ApiException(
          message: message,
          statusCode: error.response?.statusCode,
          data: data,
        );
      case DioExceptionType.connectionError:
        return ApiException(message: 'No internet connection');
      default:
        return ApiException(message: 'An unexpected error occurred');
    }
  }

  @override
  String toString() => message;
}
