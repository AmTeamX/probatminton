import 'package:dio/dio.dart';

class CommunityApi {
  final Dio _dio;
  CommunityApi(this._dio);

  // GET /api/community — list all parties
  Future<Response> getParties() => _dio.get('/community');

  // GET /api/community/:id — get party details
  Future<Response> getPartyDetail(String partyId) =>
      _dio.get('/community/$partyId');

  // POST /api/community — create a party
  Future<Response> createParty(Map<String, dynamic> body) =>
      _dio.post('/community', data: body);

  // POST /api/community/:id/join — join a party
  Future<Response> joinParty(String partyId) =>
      _dio.post('/community/$partyId/join');

  // GET /api/community/mine — get my joined parties
  Future<Response> getMyParties() => _dio.get('/community/mine');
}
