class WaitlistEntry {
  final String id;
  final String userId;
  final String courtId;
  final String? courtName;
  final String bookingDate;
  final String startTime;
  final String endTime;
  final int position;
  final String status;
  final DateTime createdAt;

  WaitlistEntry({
    required this.id,
    required this.userId,
    required this.courtId,
    this.courtName,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.position,
    required this.status,
    required this.createdAt,
  });

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  factory WaitlistEntry.fromJson(Map<String, dynamic> json) => WaitlistEntry(
    id: json['id']?.toString() ?? '',
    userId: json['user_id']?.toString() ?? '',
    courtId: json['court_id']?.toString() ?? '',
    courtName: json['court_name']?.toString(),
    bookingDate: json['booking_date']?.toString() ?? '',
    startTime: json['start_time']?.toString() ?? '',
    endTime: json['end_time']?.toString() ?? '',
    position: _toInt(json['position']),
    status: json['status']?.toString() ?? '',
    createdAt: json['created_at'] != null
        ? DateTime.parse(json['created_at'].toString())
        : DateTime.now(),
  );
}
