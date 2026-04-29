class Review {
  final String id;
  final String courtId;
  final String userId;
  final String? userName;
  final int rating;
  final String? comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.courtId,
    required this.userId,
    this.userName,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  factory Review.fromJson(Map<String, dynamic> json) => Review(
    id: json['id']?.toString() ?? '',
    courtId: json['court_id']?.toString() ?? '',
    userId: json['user_id']?.toString() ?? '',
    userName: json['user_name']?.toString(),
    rating: _toInt(json['rating']),
    comment: json['comment']?.toString(),
    createdAt: json['created_at'] != null
        ? DateTime.parse(json['created_at'].toString())
        : DateTime.now(),
  );
}
