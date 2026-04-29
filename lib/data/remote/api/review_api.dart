import 'package:dio/dio.dart';

class ReviewApi {
  final Dio _dio;
  ReviewApi(this._dio);

  Future<Response> getReviews(String courtId) =>
      _dio.get('/reviews', queryParameters: {'court_id': courtId});

  Future<Response> createReview(Map<String, dynamic> body) =>
      _dio.post('/reviews', data: body);

  Future<Response> updateReview(String reviewId, Map<String, dynamic> body) =>
      _dio.put('/reviews/$reviewId', data: body);

  Future<Response> deleteReview(String reviewId) =>
      _dio.delete('/reviews/$reviewId');
}
