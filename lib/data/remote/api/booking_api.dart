import 'package:dio/dio.dart';

class BookingApi {
  final Dio _dio;
  BookingApi(this._dio);

  // GET /api/bookings/my — get current user's bookings
  Future<Response> getBookings() => _dio.get('/bookings/my');

  // POST /api/bookings — create a new booking
  Future<Response> createBooking(Map<String, dynamic> body) =>
      _dio.post('/bookings', data: body);

  // GET /api/bookings/:id — get booking detail
  Future<Response> getBookingDetail(String bookingId) =>
      _dio.get('/bookings/$bookingId');

  // DELETE /api/bookings/:id — cancel a booking
  Future<Response> cancelBooking(String bookingId) =>
      _dio.delete('/bookings/$bookingId');

  // GET /api/bookings/:id/equipment — get equipment for booking
  Future<Response> getBookingEquipment(String bookingId) =>
      _dio.get('/bookings/$bookingId/equipment');

  // POST /api/bookings/:id/equipment — add equipment to booking
  Future<Response> addBookingEquipment(
    String bookingId,
    List<Map<String, dynamic>> equipment,
  ) => _dio.post('/bookings/$bookingId/equipment', data: equipment);
}
