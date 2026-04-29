class Booking {
  final String id;
  final String userId;
  final String courtId;
  final String? courtName;
  final String startTime;
  final String endTime;
  final double totalAmount;
  final String bookingStatus;
  final String? paymentMethod;
  final String? transactionId;
  final DateTime createdAt;

  final EquipmentRentals? _equipmentRentals;

  Booking({
    required this.id,
    required this.userId,
    required this.courtId,
    this.courtName,
    required this.startTime,
    required this.endTime,
    required this.totalAmount,
    required this.bookingStatus,
    this.paymentMethod,
    this.transactionId,
    required this.createdAt,
    EquipmentRentals? equipmentRentals,
  }) : _equipmentRentals = equipmentRentals;

  static double _toDouble(dynamic v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
    id: json['id']?.toString() ?? '',
    userId: json['user_id']?.toString() ?? '',
    courtId: json['court_id']?.toString() ?? '',
    courtName: json['court_name']?.toString(),
    startTime: json['start_time']?.toString() ?? '',
    endTime: json['end_time']?.toString() ?? '',
    totalAmount: _toDouble(json['total_amount']),
    bookingStatus:
        json['booking_status']?.toString() ?? json['status']?.toString() ?? '',
    paymentMethod: json['payment_method']?.toString(),
    transactionId: json['transaction_id']?.toString(),
    createdAt: json['created_at'] != null
        ? DateTime.parse(json['created_at'].toString())
        : DateTime.now(),
  );

  // Backward-compatible getters
  String get status => bookingStatus;
  double get totalPrice => totalAmount;
  String get bookingDate {
    try {
      final dt = DateTime.parse(startTime);
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return startTime;
    }
  }

  int get durationHours {
    try {
      final start = DateTime.parse(startTime);
      final end = DateTime.parse(endTime);
      return end.difference(start).inHours;
    } catch (_) {
      return 0;
    }
  }

  EquipmentRentals? get equipmentRentals => _equipmentRentals;

  bool get isUpcoming =>
      bookingStatus == 'CONFIRMED' || bookingStatus == 'confirmed';
  bool get isCompleted =>
      bookingStatus == 'COMPLETED' || bookingStatus == 'completed';
  bool get isCancelled =>
      bookingStatus == 'CANCELLED' || bookingStatus == 'cancelled';
}

class EquipmentRentals {
  final int rackets;
  final int shuttlecocks;
  final int shoes;

  EquipmentRentals({this.rackets = 0, this.shuttlecocks = 0, this.shoes = 0});

  factory EquipmentRentals.fromJson(Map<String, dynamic> json) =>
      EquipmentRentals(
        rackets: json['rackets'] ?? 0,
        shuttlecocks: json['shuttlecocks'] ?? 0,
        shoes: json['shoes'] ?? 0,
      );

  Map<String, dynamic> toJson() => {
    'rackets': rackets,
    'shuttlecocks': shuttlecocks,
    'shoes': shoes,
  };

  double get totalCost =>
      (rackets * 50) + (shuttlecocks * 30) + (shoes * 40).toDouble();
}
