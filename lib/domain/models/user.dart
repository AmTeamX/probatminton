class UserProfile {
  final String id;
  final String authId;
  final String email;
  final String fullName;
  final String? address;
  final String role;
  final bool isMember;
  final DateTime? membershipStartedAt;
  final DateTime? membershipExpiresAt;
  final String? membershipFeeLastPaid;
  final String? membershipLastPaymentMethod;
  final String? languagePreference;
  final DateTime createdAt;

  UserProfile({
    required this.id,
    required this.authId,
    required this.email,
    required this.fullName,
    this.address,
    required this.role,
    this.isMember = false,
    this.membershipStartedAt,
    this.membershipExpiresAt,
    this.membershipFeeLastPaid,
    this.membershipLastPaymentMethod,
    this.languagePreference,
    required this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'] ?? '',
    authId: json['auth_id'] ?? '',
    email: json['email'] ?? '',
    fullName: json['full_name'] ?? '',
    address: json['address'],
    role: json['role'] ?? 'CUSTOMER',
    isMember:
        json['is_member'] == true ||
        json['is_member'] == 1 ||
        json['is_member'] == 'true' ||
        json['is_member'] == '1',
    membershipStartedAt: json['membership_started_at'] != null
        ? DateTime.parse(json['membership_started_at'].toString())
        : null,
    membershipExpiresAt: json['membership_expires_at'] != null
        ? DateTime.parse(json['membership_expires_at'].toString())
        : null,
    membershipFeeLastPaid: json['membership_fee_last_paid']?.toString(),
    membershipLastPaymentMethod: json['membership_last_payment_method'],
    languagePreference: json['language_preference'],
    createdAt: json['created_at'] != null
        ? DateTime.parse(json['created_at'].toString())
        : DateTime.now(),
  );

  bool get isAdmin => role == 'ADMIN';

  int? get membershipDaysRemaining {
    if (membershipExpiresAt == null) return null;
    final remaining = membershipExpiresAt!.difference(DateTime.now()).inDays;
    return remaining > 0 ? remaining : 0;
  }
}
