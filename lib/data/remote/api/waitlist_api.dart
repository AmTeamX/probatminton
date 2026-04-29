import 'package:dio/dio.dart';

class WaitlistApi {
  final Dio _dio;
  WaitlistApi(this._dio);

  Future<Response> getWaitlist({String? courtId, String? date}) => _dio.get(
    '/waitlist',
    queryParameters: {'court_id': ?courtId, 'date': ?date},
  );

  Future<Response> joinWaitlist(Map<String, dynamic> body) =>
      _dio.post('/waitlist', data: body);

  Future<Response> leaveWaitlist(String entryId) =>
      _dio.delete('/waitlist/$entryId');
}
