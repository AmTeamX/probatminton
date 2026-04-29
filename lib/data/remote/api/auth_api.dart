import 'package:dio/dio.dart';

class AuthApi {
  final Dio _dio;
  AuthApi(this._dio);

  Future<Response> register(Map<String, dynamic> body) =>
      _dio.post('/auth/register', data: body);

  Future<Response> login(Map<String, dynamic> body) =>
      _dio.post('/auth/login', data: body);

  Future<Response> getProfile() => _dio.get('/auth/profile');

  Future<Response> getMembershipStatus() => _dio.get('/auth/membership/status');

  Future<Response> subscribeMembership(Map<String, dynamic> body) =>
      _dio.post('/auth/membership/subscribe', data: body);

  Future<Response> updateProfile(Map<String, dynamic> body) =>
      _dio.put('/auth/profile', data: body);
}
