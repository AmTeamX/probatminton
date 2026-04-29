import 'package:dio/dio.dart';

class PaymentApi {
  final Dio _dio;
  PaymentApi(this._dio);

  Future<Response> createPaymentIntent(Map<String, dynamic> body) =>
      _dio.post('/payments/create-payment-intent', data: body);

  Future<Response> confirmPayment(Map<String, dynamic> body) =>
      _dio.post('/payments/confirm', data: body);

  Future<Response> bankTransfer(Map<String, dynamic> body) =>
      _dio.post('/payments/bank-transfer', data: body);

  Future<Response> promptPay(Map<String, dynamic> body) =>
      _dio.post('/payments/promptpay', data: body);

  Future<Response> getPaymentForBooking(String bookingId) =>
      _dio.get('/payments/booking/$bookingId');
}
