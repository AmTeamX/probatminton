import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/remote/api/payment_api.dart';
import '../../domain/models/payment.dart';
import 'auth_provider.dart';

// Payment API provider
final paymentApiProvider = Provider<PaymentApi>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PaymentApi(apiClient.dio);
});

// ── Payment Processing ──

sealed class PaymentState {
  const PaymentState();
}

class PaymentIdle extends PaymentState {
  const PaymentIdle();
}

class PaymentProcessing extends PaymentState {
  const PaymentProcessing();
}

class PaymentCompleted extends PaymentState {
  final Payment payment;
  const PaymentCompleted(this.payment);
}

class PaymentError extends PaymentState {
  final String message;
  const PaymentError(this.message);
}

class PaymentNotifier extends StateNotifier<PaymentState> {
  final PaymentApi _paymentApi;

  PaymentNotifier(this._paymentApi) : super(const PaymentIdle());

  Future<void> processPayment({
    required String bookingId,
    required String paymentMethod,
    required double amount,
  }) async {
    state = const PaymentProcessing();
    try {
      late final Response<dynamic> response;

      switch (paymentMethod) {
        case 'credit_card':
          // Create payment intent first, then confirm
          final intent = await _paymentApi.createPaymentIntent({
            'booking_id': bookingId,
            'amount': amount,
            'currency': 'thb',
          });
          if (intent.data != null) {
            response = await _paymentApi.confirmPayment({
              'booking_id': bookingId,
              'payment_intent_id': intent.data['payment_intent_id'],
              'payment_method': 'credit_card',
            });
          } else {
            throw Exception('Failed to create payment intent');
          }
          break;
        case 'bank_transfer':
          response = await _paymentApi.bankTransfer({
            'booking_id': bookingId,
            'amount': amount,
          });
          break;
        case 'promptpay':
          response = await _paymentApi.promptPay({
            'booking_id': bookingId,
            'amount': amount,
          });
          break;
        default:
          throw Exception('Unknown payment method: $paymentMethod');
      }

      dynamic data = response.data;
      if (data is String) data = jsonDecode(data);
      if (data is Map && data['payment'] != null) {
        final payment = Payment.fromJson(
          Map<String, dynamic>.from(data['payment'] as Map),
        );
        state = PaymentCompleted(payment);
      } else {
        state = const PaymentError('Payment failed');
      }
    } catch (e) {
      state = PaymentError('Payment failed: $e');
    }
  }

  void reset() {
    state = const PaymentIdle();
  }
}

final paymentProvider = StateNotifierProvider<PaymentNotifier, PaymentState>((
  ref,
) {
  final paymentApi = ref.watch(paymentApiProvider);
  return PaymentNotifier(paymentApi);
});
