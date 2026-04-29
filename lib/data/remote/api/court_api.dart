import 'package:dio/dio.dart';

class CourtApi {
  final Dio _dio;
  CourtApi(this._dio);

  /// GET /api/courts — list all active courts (no params)
  Future<Response> getCourts() => _dio.get('/courts');

  /// GET /api/courts/search — search/filter courts
  Future<Response> searchCourts({
    String? name,
    double? maxPrice,
    double? lat,
    double? lng,
    double? radius,
  }) {
    final hasFilters =
        name != null ||
        maxPrice != null ||
        (lat != null && lng != null && radius != null);
    if (!hasFilters) return _dio.get('/courts/search');
    return _dio.get(
      '/courts/search',
      queryParameters: {
        'name': name,
        'maxPrice': maxPrice,
        'lat': lat,
        'lng': lng,
        'radius': radius,
      },
    );
  }

  Future<Response> getCourtDetail(String courtId) =>
      _dio.get('/courts/$courtId');

  Future<Response> getCourtAvailability(String courtId, String date) => _dio
      .get('/courts/$courtId/availability', queryParameters: {'date': date});

  Future<Response> createCourt(Map<String, dynamic> body) =>
      _dio.post('/courts', data: body);

  Future<Response> updateCourt(String courtId, Map<String, dynamic> body) =>
      _dio.put('/courts/$courtId', data: body);

  Future<Response> deleteCourt(String courtId) =>
      _dio.delete('/courts/$courtId');
}
