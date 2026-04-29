class Payment {
  final String id;
  final String bookingId;
  final double amount;
  final String paymentMethod;
  final String status;
  final DateTime createdAt;

  Payment({
    required this.id,
    required this.bookingId,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
  });

  static double _toDouble(dynamic v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
    id: json['id']?.toString() ?? '',
    bookingId: json['booking_id']?.toString() ?? '',
    amount: _toDouble(json['amount']),
    paymentMethod: json['payment_method']?.toString() ?? '',
    status: json['status']?.toString() ?? '',
    createdAt: json['created_at'] != null
        ? DateTime.parse(json['created_at'].toString())
        : DateTime.now(),
  );
}
