import 'package:dio/dio.dart';

class WaitlistApi {
  final Dio _dio;
  WaitlistApi(this._dio);

  /// GET /api/waitlist/my — Get current user's waitlist entries
  Future<Response> getMyWaitlist() => _dio.get('/waitlist/my');

  /// POST /api/waitlist — Join waitlist
  /// Body: { court_id, requested_date, preferred_time_slot }
  Future<Response> joinWaitlist(Map<String, dynamic> body) =>
      _dio.post('/waitlist', data: body);

  /// POST /api/waitlist/:id/confirm — Confirm a notified waitlist entry
  Future<Response> confirmWaitlist(
    String entryId, {
    String? paymentMethod,
    String? transferReference,
  }) => _dio.post(
    '/waitlist/$entryId/confirm',
    data: {
      'payment_method': ?paymentMethod,
      'transfer_reference': ?transferReference,
    },
  );

  /// DELETE /api/waitlist/:id — Leave waitlist
  Future<Response> leaveWaitlist(String entryId) =>
      _dio.delete('/waitlist/$entryId');
}
