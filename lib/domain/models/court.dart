class Court {
  final String id;
  final String name;
  final String? description;
  final String location;
  final String? address;
  final double pricePerHour;
  final double? latitude;
  final double? longitude;
  final String? imageUrl;
  final double? avgRating;
  final int? reviewCount;
  final double? distanceKm;
  final String? openingTime;
  final String? closingTime;
  final String? currentStatus;
  final String? allowedShoes;
  final DateTime createdAt;

  Court({
    required this.id,
    required this.name,
    this.description,
    required this.location,
    this.address,
    required this.pricePerHour,
    this.latitude,
    this.longitude,
    this.imageUrl,
    this.avgRating,
    this.reviewCount,
    this.distanceKm,
    this.openingTime,
    this.closingTime,
    this.currentStatus,
    this.allowedShoes,
    required this.createdAt,
  });

  static double _toDouble(dynamic v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }

  static double? _toDoubleOrNull(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  static int? _toIntOrNull(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  factory Court.fromJson(Map<String, dynamic> json) => Court(
    id: json['id']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
    description: json['description']?.toString(),
    location: json['location']?.toString() ?? json['address']?.toString() ?? '',
    address: json['address']?.toString(),
    pricePerHour: _toDouble(json['price_per_hour']),
    latitude: _toDoubleOrNull(json['location_lat'] ?? json['latitude']),
    longitude: _toDoubleOrNull(json['location_lng'] ?? json['longitude']),
    imageUrl: json['image_url']?.toString(),
    avgRating: _toDoubleOrNull(json['average_rating'] ?? json['avg_rating']),
    reviewCount: _toIntOrNull(json['total_reviews'] ?? json['review_count']),
    distanceKm: _toDoubleOrNull(json['distance_km']),
    openingTime: json['opening_time']?.toString(),
    closingTime: json['closing_time']?.toString(),
    currentStatus: json['current_status']?.toString(),
    allowedShoes: json['allowed_shoes']?.toString(),
    createdAt: json['created_at'] != null
        ? DateTime.parse(json['created_at'].toString())
        : DateTime.now(),
  );
}

class TimeSlot {
  final String startTime;
  final String endTime;
  final bool available;
  final double price;

  TimeSlot({
    required this.startTime,
    required this.endTime,
    required this.available,
    required this.price,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) => TimeSlot(
    startTime: json['start_time']?.toString() ?? '',
    endTime: json['end_time']?.toString() ?? '',
    available: json['available'] == true || json['available'] == 1,
    price: Court._toDouble(json['price']),
  );
}
