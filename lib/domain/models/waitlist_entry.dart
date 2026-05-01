class WaitlistEntry {
  final String id;
  final String userId;
  final String courtId;
  final String? courtName;
  final String requestedDate;
  final String preferredTimeSlot;
  final String status; // PENDING, NOTIFIED, EXPIRED, CONFIRMED
  final DateTime createdAt;

  WaitlistEntry({
    required this.id,
    required this.userId,
    required this.courtId,
    this.courtName,
    required this.requestedDate,
    required this.preferredTimeSlot,
    required this.status,
    required this.createdAt,
  });

  /// Parse start time from preferred_time_slot (e.g. "10:00-12:00" → "10:00")
  String get startTime {
    final parts = preferredTimeSlot.split('-');
    return parts.isNotEmpty ? parts[0].trim() : '';
  }

  /// Parse end time from preferred_time_slot (e.g. "10:00-12:00" → "12:00")
  String get endTime {
    final parts = preferredTimeSlot.split('-');
    return parts.length > 1 ? parts[1].trim() : '';
  }

  factory WaitlistEntry.fromJson(Map<String, dynamic> json) => WaitlistEntry(
    id: json['id']?.toString() ?? '',
    userId: json['user_id']?.toString() ?? '',
    courtId: json['court_id']?.toString() ?? '',
    courtName: json['court_name']?.toString(),
    requestedDate: json['requested_date']?.toString() ?? '',
    preferredTimeSlot: json['preferred_time_slot']?.toString() ?? '',
    status: json['status']?.toString() ?? 'PENDING',
    createdAt: json['created_at'] != null
        ? DateTime.parse(json['created_at'].toString())
        : DateTime.now(),
  );

  /// Convenience getter for display date
  String get date => requestedDate;
}
