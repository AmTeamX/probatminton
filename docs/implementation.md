# 🏸 Pro Badminton — Implementation Guide

> This document provides the complete technical reference for implementing the Pro Badminton Flutter mobile app. It covers architecture, API integration, data models, screen specifications, and code patterns.

---

## Table of Contents

1. [Architecture Overview](#1-architecture-overview)
2. [Tech Stack](#2-tech-stack)
3. [Project Structure](#3-project-structure)
4. [Core Layer](#4-core-layer)
5. [Data Layer](#5-data-layer)
6. [Domain Layer — Data Models](#6-domain-layer--data-models)
7. [Presentation Layer — Providers](#7-presentation-layer--providers)
8. [Presentation Layer — Screens](#8-presentation-layer--screens)
9. [Presentation Layer — Widgets](#9-presentation-layer--widgets)
10. [Navigation & Routing](#10-navigation--routing)
11. [Authentication Flow](#11-authentication-flow)
12. [API Reference](#12-api-reference)
13. [Database Schema](#13-database-schema)
14. [Design System](#14-design-system)
15. [Environment & Platform Configuration](#15-environment--platform-configuration)
16. [Localization](#16-localization)
17. [Testing Strategy](#17-testing-strategy)

---

## 1. Architecture Overview

The app follows **Clean Architecture** with **MVVM** presentation pattern:

```
┌─────────────────────────────────────────────────┐
│                  Presentation                    │
│  (Screens, Widgets, Providers/Riverpod)         │
├─────────────────────────────────────────────────┤
│                   Domain                         │
│  (Models — pure Dart classes, no dependencies)   │
├─────────────────────────────────────────────────┤
│                    Data                          │
│  (API services, Repositories, Local Storage)     │
├─────────────────────────────────────────────────┤
│                   Core                           │
│  (Config, Network client, Utils, Theme)          │
└─────────────────────────────────────────────────┘
```

**Data flow:** `Screen → Provider → Repository → API Service → Dio → Backend`

**Dependency rule:** Inner layers have no knowledge of outer layers. Domain layer has zero external dependencies.

---

## 2. Tech Stack

| Component            | Technology                                                      |
| -------------------- | --------------------------------------------------------------- |
| **Framework**        | Flutter 3.x (stable channel)                                    |
| **Language**         | Dart 3.x                                                        |
| **Architecture**     | Clean Architecture / MVVM                                       |
| **State Management** | Riverpod (`flutter_riverpod` + `riverpod_annotation`)           |
| **Networking**       | Dio 5.x                                                         |
| **Serialization**    | Manual `fromJson` / `toJson`                                    |
| **Navigation**       | GoRouter                                                        |
| **Image Loading**    | CachedNetworkImage                                              |
| **Auth**             | Supabase Auth via direct REST API calls                         |
| **Maps**             | google_maps_flutter                                             |
| **Payments**         | flutter_stripe                                                  |
| **Local Storage**    | flutter_secure_storage (tokens) + shared_preferences (settings) |
| **Localization**     | flutter_localizations + intl                                    |
| **DI**               | Riverpod (providers)                                            |
| **Testing**          | flutter_test, mockito, integration_test                         |

---

## 3. Project Structure

```
probadminton/
├── lib/
│   ├── main.dart                           # App entry point
│   ├── app.dart                            # MaterialApp + GoRouter setup
│   ├── core/
│   │   ├── constants/
│   │   │   ├── api_config.dart             # API base URL, pricing constants
│   │   │   └── app_theme.dart              # ThemeData definition
│   │   ├── network/
│   │   │   ├── api_client.dart             # Dio client with interceptors
│   │   │   └── api_exceptions.dart         # Custom exception classes
│   │   └── utils/
│   │       ├── price_calculator.dart       # Booking price calculation
│   │       ├── validators.dart             # Form input validators
│   │       └── formatters.dart             # Date/currency formatters
│   ├── data/
│   │   ├── remote/
│   │   │   └── api/
│   │   │       ├── auth_api.dart
│   │   │       ├── court_api.dart
│   │   │       ├── booking_api.dart
│   │   │       ├── payment_api.dart
│   │   │       ├── review_api.dart
│   │   │       ├── waitlist_api.dart
│   │   │       └── community_api.dart
│   │   ├── local/
│   │   │   ├── token_storage.dart          # FlutterSecureStorage wrapper
│   │   │   └── preferences_storage.dart    # SharedPreferences wrapper
│   │   └── repositories/
│   │       ├── auth_repository.dart
│   │       ├── court_repository.dart
│   │       ├── booking_repository.dart
│   │       ├── payment_repository.dart
│   │       ├── review_repository.dart
│   │       ├── waitlist_repository.dart
│   │       └── community_repository.dart
│   ├── domain/
│   │   └── models/
│   │       ├── user.dart
│   │       ├── court.dart
│   │       ├── booking.dart
│   │       ├── review.dart
│   │       ├── waitlist_entry.dart
│   │       ├── community_post.dart
│   │       └── payment.dart
│   ├── presentation/
│   │   ├── providers/
│   │   │   ├── auth_provider.dart
│   │   │   ├── court_provider.dart
│   │   │   ├── booking_provider.dart
│   │   │   ├── payment_provider.dart
│   │   │   ├── review_provider.dart
│   │   │   ├── waitlist_provider.dart
│   │   │   ├── community_provider.dart
│   │   │   ├── membership_provider.dart
│   │   │   └── locale_provider.dart
│   │   ├── screens/
│   │   │   ├── splash/
│   │   │   │   └── splash_screen.dart
│   │   │   ├── auth/
│   │   │   │   ├── login_screen.dart
│   │   │   │   └── register_screen.dart
│   │   │   ├── home/
│   │   │   │   └── home_screen.dart
│   │   │   ├── map/
│   │   │   │   └── map_screen.dart
│   │   │   ├── court/
│   │   │   │   ├── court_detail_screen.dart
│   │   │   │   └── booking_screen.dart
│   │   │   ├── bookings/
│   │   │   │   ├── my_bookings_screen.dart
│   │   │   │   └── booking_detail_screen.dart
│   │   │   ├── payment/
│   │   │   │   └── payment_screen.dart
│   │   │   ├── reviews/
│   │   │   │   └── review_screen.dart
│   │   │   ├── waitlist/
│   │   │   │   └── waitlist_screen.dart
│   │   │   ├── membership/
│   │   │   │   └── membership_screen.dart
│   │   │   ├── community/
│   │   │   │   ├── community_screen.dart
│   │   │   │   └── create_post_screen.dart
│   │   │   ├── profile/
│   │   │   │   ├── profile_screen.dart
│   │   │   │   └── edit_profile_screen.dart
│   │   │   └── admin/
│   │   │       ├── admin_dashboard_screen.dart
│   │   │       ├── manage_courts_screen.dart
│   │   │       ├── manage_bookings_screen.dart
│   │   │       ├── manage_users_screen.dart
│   │   │       └── manage_community_screen.dart
│   │   ├── widgets/
│   │   │   ├── court_card.dart
│   │   │   ├── booking_card.dart
│   │   │   ├── review_card.dart
│   │   │   ├── rating_stars.dart
│   │   │   ├── time_slot_grid.dart
│   │   │   ├── equipment_selector.dart
│   │   │   ├── price_summary.dart
│   │   │   ├── status_badge.dart
│   │   │   ├── empty_state.dart
│   │   │   ├── loading_shimmer.dart
│   │   │   └── bottom_nav_bar.dart
│   │   └── router/
│   │       └── app_router.dart
│   ├── l10n/
│   │   ├── app_en.arb
│   │   ├── app_th.arb
│   │   └── app_zh.arb
│   └── generated/
│       └── l10n/
├── android/
│   ├── app/src/main/
│   │   ├── AndroidManifest.xml
│   │   └── res/xml/network_security_config.xml
│   ├── build.gradle.kts
│   └── ...
├── ios/
│   └── Runner/Info.plist
├── test/
│   ├── unit/
│   └── widget/
├── integration_test/
│   └── app_test.dart
├── pubspec.yaml
├── l10n.yaml
└── analysis_options.yaml
```

---

## 4. Core Layer

### 4.1 API Configuration

```dart
// lib/core/constants/api_config.dart
class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080/api',
  );

  static const String supabaseUrl = 'https://obywrvuqmiajsirekqmy.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
  static const String stripePublishableKey = 'pk_test_...';

  // Equipment pricing
  static const double racketPrice = 50.0;
  static const double shuttlecockPrice = 30.0;
  static const double shoesPrice = 40.0;
  static const double memberHourlyRate = 150.0;
  static const double membershipMonthlyPrice = 199.0;
}
```

### 4.2 App Theme

```dart
// lib/core/constants/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF006400);
  static const Color primaryLight = Color(0xFF4CAF50);
  static const Color secondary = Color(0xFFFF6F00);
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFB00020);
  static const Color success = Color(0xFF4CAF50);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: const Color(0xFF006400),
    brightness: Brightness.light,
    cardTheme: CardThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
  );
}
```

### 4.3 Dio API Client

```dart
// lib/core/network/api_client.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/api_config.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient({required String baseUrl, required TokenStorage tokenStorage}) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await tokenStorage.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          final refreshed = await tokenStorage.refreshToken();
          if (refreshed != null) {
            error.requestOptions.headers['Authorization'] = 'Bearer $refreshed';
            final response = await _dio.fetch(error.requestOptions);
            handler.resolve(response);
            return;
          }
        }
        handler.next(error);
      },
    ));

    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }

  Dio get dio => _dio;
}
```

### 4.4 API Exceptions

```dart
// lib/core/network/api_exceptions.dart
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({required this.message, this.statusCode, this.data});

  factory ApiException.fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(message: 'Connection timed out. Please try again.');
      case DioExceptionType.badResponse:
        final data = error.response?.data;
        final message = data is Map
            ? data['message'] ?? 'Server error occurred'
            : 'Server error occurred';
        return ApiException(
          message: message,
          statusCode: error.response?.statusCode,
          data: data,
        );
      case DioExceptionType.connectionError:
        return ApiException(message: 'No internet connection');
      default:
        return ApiException(message: 'An unexpected error occurred');
    }
  }

  @override
  String toString() => message;
}
```

### 4.5 Price Calculator

```dart
// lib/core/utils/price_calculator.dart
import '../../core/constants/api_config.dart';

class PriceCalculator {
  /// Calculate court cost based on membership status
  static double courtCost({
    required double pricePerHour,
    required int durationHours,
    required bool isMember,
  }) {
    if (isMember) {
      return ApiConfig.memberHourlyRate * durationHours;
    }
    return pricePerHour * durationHours;
  }

  /// Calculate equipment rental cost
  static double equipmentCost({
    required int rackets,
    required int shuttlecocks,
    required int shoes,
  }) {
    return (rackets * ApiConfig.racketPrice) +
        (shuttlecocks * ApiConfig.shuttlecockPrice) +
        (shoes * ApiConfig.shoesPrice);
  }

  /// Calculate total booking price
  static double total({
    required double pricePerHour,
    required int durationHours,
    required bool isMember,
    required int rackets,
    required int shuttlecocks,
    required int shoes,
  }) {
    return courtCost(
          pricePerHour: pricePerHour,
          durationHours: durationHours,
          isMember: isMember,
        ) +
        equipmentCost(
          rackets: rackets,
          shuttlecocks: shuttlecocks,
          shoes: shoes,
        );
  }

  /// Calculate monthly savings for a member
  static double monthlySavings({
    required double pricePerHour,
    required int hoursPerWeek,
  }) {
    final standardMonthly = pricePerHour * hoursPerWeek * 4;
    final memberMonthly = ApiConfig.memberHourlyRate * hoursPerWeek * 4;
    return standardMonthly - memberMonthly;
  }
}
```

### 4.6 Form Validators

```dart
// lib/core/utils/validators.dart
class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(value)) return 'Enter a valid email';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? required(String? value, [String field = 'This field']) {
    if (value == null || value.trim().isEmpty) return '$field is required';
    return null;
  }

  static String? rating(int? value) {
    if (value == null || value < 1 || value > 5) return 'Rating must be 1-5';
    return null;
  }
}
```

### 4.7 Formatters

```dart
// lib/core/utils/formatters.dart
import 'package:intl/intl.dart';

class Formatters {
  static String currency(double amount) {
    return '฿${NumberFormat('#,##0').format(amount)}';
  }

  static String date(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  static String time(String time24) {
    final parts = time24.split(':');
    final hour = int.parse(parts[0]);
    final minute = parts[1];
    final period = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$hour12:$minute $period';
  }

  static String dateTime(DateTime dt) {
    return DateFormat('dd MMM yyyy, HH:mm').format(dt);
  }

  static String distance(double km) {
    if (km < 1) return '${(km * 1000).round()} m';
    return '${km.toStringAsFixed(1)} km';
  }
}
```

---

## 5. Data Layer

### 5.1 Token Storage

```dart
// lib/data/local/token_storage.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _expiresAtKey = 'expires_at';

  final FlutterSecureStorage _secureStorage;

  TokenStorage(this._secureStorage);

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required int expiresAt,
  }) async {
    await _secureStorage.write(key: _accessTokenKey, value: accessToken);
    await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
    await _secureStorage.write(key: _expiresAtKey, value: expiresAt.toString());
  }

  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: _accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenKey);
  }

  Future<bool> isTokenValid() async {
    final expiresAtStr = await _secureStorage.read(key: _expiresAtKey);
    if (expiresAtStr == null) return false;
    final expiresAt = int.tryParse(expiresAtStr);
    if (expiresAt == null) return false;
    return DateTime.now().millisecondsSinceEpoch < expiresAt * 1000;
  }

  Future<void> clearTokens() async {
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
    await _secureStorage.delete(key: _expiresAtKey);
  }

  Future<String?> refreshToken() async {
    // Implement token refresh if backend supports it
    return null;
  }
}
```

### 5.2 Preferences Storage

```dart
// lib/data/local/preferences_storage.dart
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesStorage {
  static const _localeKey = 'locale';

  final SharedPreferences _prefs;

  PreferencesStorage(this._prefs);

  Future<void> setLocale(String locale) async {
    await _prefs.setString(_localeKey, locale);
  }

  String getLocale() {
    return _prefs.getString(_localeKey) ?? 'en';
  }
}
```

### 5.3 API Service Classes

#### Auth API

```dart
// lib/data/remote/api/auth_api.dart
import 'package:dio/dio.dart';

class AuthApi {
  final Dio _dio;
  AuthApi(this._dio);

  Future<Response> register(Map<String, dynamic> body) =>
      _dio.post('/auth/register', data: body);

  Future<Response> login(Map<String, dynamic> body) =>
      _dio.post('/auth/login', data: body);

  Future<Response> getProfile() =>
      _dio.get('/auth/profile');

  Future<Response> getMembershipStatus() =>
      _dio.get('/auth/membership/status');

  Future<Response> subscribeMembership(Map<String, dynamic> body) =>
      _dio.post('/auth/membership/subscribe', data: body);

  Future<Response> updateProfile(Map<String, dynamic> body) =>
      _dio.put('/auth/profile', data: body);
}
```

#### Court API

```dart
// lib/data/remote/api/court_api.dart
import 'package:dio/dio.dart';

class CourtApi {
  final Dio _dio;
  CourtApi(this._dio);

  Future<Response> getCourts({
    String? search,
    double? maxPrice,
    double? lat,
    double? lng,
    double? radius,
  }) => _dio.get('/courts', queryParameters: {
    if (search != null) 'search': search,
    if (maxPrice != null) 'maxPrice': maxPrice,
    if (lat != null) 'lat': lat,
    if (lng != null) 'lng': lng,
    if (radius != null) 'radius': radius,
  });

  Future<Response> getCourtDetail(String courtId) =>
      _dio.get('/courts/$courtId');

  Future<Response> getCourtAvailability(String courtId, String date) =>
      _dio.get('/courts/$courtId/availability', queryParameters: {'date': date});

  Future<Response> createCourt(Map<String, dynamic> body) =>
      _dio.post('/courts', data: body);

  Future<Response> updateCourt(String courtId, Map<String, dynamic> body) =>
      _dio.put('/courts/$courtId', data: body);

  Future<Response> deleteCourt(String courtId) =>
      _dio.delete('/courts/$courtId');
}
```

#### Booking API

```dart
// lib/data/remote/api/booking_api.dart
import 'package:dio/dio.dart';

class BookingApi {
  final Dio _dio;
  BookingApi(this._dio);

  Future<Response> getBookings() => _dio.get('/bookings');

  Future<Response> createBooking(Map<String, dynamic> body) =>
      _dio.post('/bookings', data: body);

  Future<Response> getBookingDetail(String bookingId) =>
      _dio.get('/bookings/$bookingId');

  Future<Response> cancelBooking(String bookingId) =>
      _dio.put('/bookings/$bookingId/cancel');

  Future<Response> updateBooking(String bookingId, Map<String, dynamic> body) =>
      _dio.put('/bookings/$bookingId', data: body);
}
```

#### Payment API

```dart
// lib/data/remote/api/payment_api.dart
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
```

#### Review API

```dart
// lib/data/remote/api/review_api.dart
import 'package:dio/dio.dart';

class ReviewApi {
  final Dio _dio;
  ReviewApi(this._dio);

  Future<Response> getReviews(String courtId) =>
      _dio.get('/reviews', queryParameters: {'court_id': courtId});

  Future<Response> createReview(Map<String, dynamic> body) =>
      _dio.post('/reviews', data: body);

  Future<Response> updateReview(String reviewId, Map<String, dynamic> body) =>
      _dio.put('/reviews/$reviewId', data: body);

  Future<Response> deleteReview(String reviewId) =>
      _dio.delete('/reviews/$reviewId');
}
```

#### Waitlist API

```dart
// lib/data/remote/api/waitlist_api.dart
import 'package:dio/dio.dart';

class WaitlistApi {
  final Dio _dio;
  WaitlistApi(this._dio);

  Future<Response> getWaitlist({String? courtId, String? date}) =>
      _dio.get('/waitlist', queryParameters: {
        if (courtId != null) 'court_id': courtId,
        if (date != null) 'date': date,
      });

  Future<Response> joinWaitlist(Map<String, dynamic> body) =>
      _dio.post('/waitlist', data: body);

  Future<Response> leaveWaitlist(String entryId) =>
      _dio.delete('/waitlist/$entryId');
}
```

#### Community API

```dart
// lib/data/remote/api/community_api.dart
import 'package:dio/dio.dart';

class CommunityApi {
  final Dio _dio;
  CommunityApi(this._dio);

  Future<Response> getPosts() => _dio.get('/community');

  Future<Response> createPost(Map<String, dynamic> body) =>
      _dio.post('/community', data: body);

  Future<Response> updatePost(String postId, Map<String, dynamic> body) =>
      _dio.put('/community/$postId', data: body);

  Future<Response> deletePost(String postId) =>
      _dio.delete('/community/$postId');
}
```

---

## 6. Domain Layer — Data Models

### User Profile

```dart
// lib/domain/models/user.dart
class UserProfile {
  final String id;
  final String authId;
  final String email;
  final String fullName;
  final String? address;
  final String role;
  final String membershipStatus;
  final DateTime? membershipExpiresAt;

  UserProfile({
    required this.id,
    required this.authId,
    required this.email,
    required this.fullName,
    this.address,
    required this.role,
    required this.membershipStatus,
    this.membershipExpiresAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'],
    authId: json['auth_id'],
    email: json['email'],
    fullName: json['full_name'],
    address: json['address'],
    role: json['role'],
    membershipStatus: json['membership_status'] ?? 'none',
    membershipExpiresAt: json['membership_expires_at'] != null
        ? DateTime.parse(json['membership_expires_at'])
        : null,
  );

  bool get isAdmin => role == 'ADMIN';
  bool get isMember => membershipStatus == 'active';
}
```

### Court

```dart
// lib/domain/models/court.dart
class Court {
  final String id;
  final String name;
  final String? description;
  final String location;
  final double pricePerHour;
  final double? latitude;
  final double? longitude;
  final String? imageUrl;
  final double? avgRating;
  final int? reviewCount;
  final double? distanceKm;
  final DateTime createdAt;

  Court({
    required this.id,
    required this.name,
    this.description,
    required this.location,
    required this.pricePerHour,
    this.latitude,
    this.longitude,
    this.imageUrl,
    this.avgRating,
    this.reviewCount,
    this.distanceKm,
    required this.createdAt,
  });

  factory Court.fromJson(Map<String, dynamic> json) => Court(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    location: json['location'],
    pricePerHour: (json['price_per_hour'] as num).toDouble(),
    latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
    longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
    imageUrl: json['image_url'],
    avgRating: json['avg_rating'] != null ? (json['avg_rating'] as num).toDouble() : null,
    reviewCount: json['review_count'],
    distanceKm: json['distance_km'] != null ? (json['distance_km'] as num).toDouble() : null,
    createdAt: DateTime.parse(json['created_at']),
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
    startTime: json['start_time'],
    endTime: json['end_time'],
    available: json['available'],
    price: (json['price'] as num).toDouble(),
  );
}
```

### Booking

```dart
// lib/domain/models/booking.dart
class Booking {
  final String id;
  final String userId;
  final String courtId;
  final String? courtName;
  final String bookingDate;
  final String startTime;
  final String endTime;
  final int durationHours;
  final double totalPrice;
  final String status;
  final EquipmentRentals? equipmentRentals;
  final DateTime createdAt;

  Booking({
    required this.id,
    required this.userId,
    required this.courtId,
    this.courtName,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.durationHours,
    required this.totalPrice,
    required this.status,
    this.equipmentRentals,
    required this.createdAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
    id: json['id'],
    userId: json['user_id'],
    courtId: json['court_id'],
    courtName: json['court_name'],
    bookingDate: json['booking_date'],
    startTime: json['start_time'],
    endTime: json['end_time'],
    durationHours: json['duration_hours'],
    totalPrice: (json['total_price'] as num).toDouble(),
    status: json['status'],
    equipmentRentals: json['equipment_rentals'] != null
        ? EquipmentRentals.fromJson(json['equipment_rentals'])
        : null,
    createdAt: DateTime.parse(json['created_at']),
  );

  bool get isUpcoming => status == 'pending' || status == 'confirmed';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
}

class EquipmentRentals {
  final int rackets;
  final int shuttlecocks;
  final int shoes;

  EquipmentRentals({
    this.rackets = 0,
    this.shuttlecocks = 0,
    this.shoes = 0,
  });

  factory EquipmentRentals.fromJson(Map<String, dynamic> json) => EquipmentRentals(
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
```

### Review

```dart
// lib/domain/models/review.dart
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

  factory Review.fromJson(Map<String, dynamic> json) => Review(
    id: json['id'],
    courtId: json['court_id'],
    userId: json['user_id'],
    userName: json['user_name'],
    rating: json['rating'],
    comment: json['comment'],
    createdAt: DateTime.parse(json['created_at']),
  );
}
```

### Waitlist Entry

```dart
// lib/domain/models/waitlist_entry.dart
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

  factory WaitlistEntry.fromJson(Map<String, dynamic> json) => WaitlistEntry(
    id: json['id'],
    userId: json['user_id'],
    courtId: json['court_id'],
    courtName: json['court_name'],
    bookingDate: json['booking_date'],
    startTime: json['start_time'],
    endTime: json['end_time'],
    position: json['position'],
    status: json['status'],
    createdAt: DateTime.parse(json['created_at']),
  );
}
```

### Community Post

```dart
// lib/domain/models/community_post.dart
class CommunityPost {
  final String id;
  final String userId;
  final String? userName;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;

  CommunityPost({
    required this.id,
    required this.userId,
    this.userName,
    required this.title,
    required this.content,
    required this.createdAt,
    this.updatedAt,
  });

  factory CommunityPost.fromJson(Map<String, dynamic> json) => CommunityPost(
    id: json['id'],
    userId: json['user_id'],
    userName: json['user_name'],
    title: json['title'],
    content: json['content'],
    createdAt: DateTime.parse(json['created_at']),
    updatedAt: json['updated_at'] != null
        ? DateTime.parse(json['updated_at'])
        : null,
  );
}
```

### Payment

```dart
// lib/domain/models/payment.dart
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

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
    id: json['id'],
    bookingId: json['booking_id'],
    amount: (json['amount'] as num).toDouble(),
    paymentMethod: json['payment_method'],
    status: json['status'],
    createdAt: DateTime.parse(json['created_at']),
  );
}
```

---

## 7. Presentation Layer — Providers

### Auth Provider

```dart
// lib/presentation/providers/auth_provider.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

sealed class AuthStatus {
  const AuthStatus();
}
class Authenticated extends AuthStatus {
  final UserProfile user;
  const Authenticated(this.user);
}
class Unauthenticated extends AuthStatus {
  const Unauthenticated();
}
class AuthLoading extends AuthStatus {
  const AuthLoading();
}

@riverpod
class AuthState extends _$AuthState {
  @override
  FutureOr<AuthStatus> build() async {
    final tokenStorage = ref.read(tokenStorageProvider);
    final isValid = await tokenStorage.isTokenValid();
    if (isValid) {
      final profile = await ref.read(authApiProvider).getProfile();
      return Authenticated(UserProfile.fromJson(profile.data['user']));
    }
    return const Unauthenticated();
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final response = await ref.read(authApiProvider).login({
        'email': email,
        'password': password,
      });
      final session = response.data['session'];
      await ref.read(tokenStorageProvider).saveTokens(
        accessToken: session['access_token'],
        refreshToken: session['refresh_token'],
        expiresAt: session['expires_at'],
      );
      final profile = await ref.read(authApiProvider).getProfile();
      return Authenticated(UserProfile.fromJson(profile.data['user']));
    });
  }

  Future<void> register(Map<String, dynamic> body) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authApiProvider).register(body);
      // Auto-login after registration
      final loginResponse = await ref.read(authApiProvider).login({
        'email': body['email'],
        'password': body['password'],
      });
      final session = loginResponse.data['session'];
      await ref.read(tokenStorageProvider).saveTokens(
        accessToken: session['access_token'],
        refreshToken: session['refresh_token'],
        expiresAt: session['expires_at'],
      );
      final profile = await ref.read(authApiProvider).getProfile();
      return Authenticated(UserProfile.fromJson(profile.data['user']));
    });
  }

  Future<void> logout() async {
    await ref.read(tokenStorageProvider).clearTokens();
    state = const AsyncData(Unauthenticated());
  }
}
```

### Court Provider

```dart
// lib/presentation/providers/court_provider.dart
@riverpod
Future<List<Court>> courts(CourtsRef ref, {String? search, double? maxPrice}) async {
  final response = await ref.read(courtApiProvider).getCourts(
    search: search,
    maxPrice: maxPrice,
  );
  final courtsJson = response.data['courts'] as List;
  return courtsJson.map((json) => Court.fromJson(json)).toList();
}

@riverpod
Future<Court> courtDetail(CourtDetailRef ref, String courtId) async {
  final response = await ref.read(courtApiProvider).getCourtDetail(courtId);
  return Court.fromJson(response.data['court']);
}

@riverpod
Future<List<TimeSlot>> courtAvailability(
  CourtAvailabilityRef ref,
  String courtId,
  String date,
) async {
  final response = await ref.read(courtApiProvider)
      .getCourtAvailability(courtId, date);
  final slotsJson = response.data['slots'] as List;
  return slotsJson.map((json) => TimeSlot.fromJson(json)).toList();
}
```

### Booking Provider

```dart
// lib/presentation/providers/booking_provider.dart
@riverpod
Future<List<Booking>> bookings(BookingsRef ref) async {
  final response = await ref.read(bookingApiProvider).getBookings();
  final bookingsJson = response.data['bookings'] as List;
  return bookingsJson.map((json) => Booking.fromJson(json)).toList();
}

@riverpod
Future<Booking> bookingDetail(BookingDetailRef ref, String bookingId) async {
  final response = await ref.read(bookingApiProvider).getBookingDetail(bookingId);
  return Booking.fromJson(response.data['booking']);
}
```

### Review Provider

```dart
// lib/presentation/providers/review_provider.dart
@riverpod
Future<List<Review>> reviews(ReviewsRef ref, String courtId) async {
  final response = await ref.read(reviewApiProvider).getReviews(courtId);
  final reviewsJson = response.data['reviews'] as List;
  return reviewsJson.map((json) => Review.fromJson(json)).toList();
}
```

### Membership Provider

```dart
// lib/presentation/providers/membership_provider.dart
@riverpod
Future<Map<String, dynamic>> membershipStatus(MembershipStatusRef ref) async {
  final response = await ref.read(authApiProvider).getMembershipStatus();
  return response.data;
}
```

---

## 8. Presentation Layer — Screens

### 8.1 Splash Screen

- App logo centered
- Check `TokenStorage.isTokenValid()`
- If valid → fetch profile → navigate to Home
- If invalid → navigate to Login
- Use `FutureBuilder` or `initState` with redirect

### 8.2 Login Screen

- App logo at top
- Email `TextFormField` with `keyboardType: TextInputType.emailAddress`
- Password `TextFormField` with `obscureText` toggle
- Full-width "Login" `ElevatedButton`
- "Don't have an account? Register" `TextButton` → navigates to Register
- Error display via `SnackBar`
- `CircularProgressIndicator` overlay during API call

### 8.3 Register Screen

- Full name `TextFormField`
- Email `TextFormField`
- Password `TextFormField` (min 6 chars, visibility toggle)
- Address `TextFormField` (multiline, `maxLines: 3`)
- "Register" `ElevatedButton`
- "Already have an account? Login" `TextButton`
- Success → auto-login → navigate to Home

### 8.4 Home / Search Screen

- `TextField` search bar at top (searches court names)
- Filter row: Max Price `Slider`, Distance toggle
- `ListView.builder` of `CourtCard` widgets
- `RefreshIndicator` for pull-to-refresh
- Empty state when no courts match
- Uses `geolocator` for GPS position
- FAB "Map View" → navigates to Map Screen

### 8.5 Map View Screen

- `GoogleMap` widget filling screen
- Court markers with info windows
- Tap marker → bottom sheet with court preview card
- Tap preview card → Court Detail screen
- Requires location permission (`permission_handler`)

### 8.6 Court Detail Screen

- Hero image (full width) with placeholder fallback
- Court name (headline text)
- Star rating visual + review count
- Price per hour (show member price if active)
- Description paragraph
- Location text + small `GoogleMap` preview
- Reviews section: average rating, list of `ReviewCard`, "Write a Review" button
- Sticky "Book Now" `ElevatedButton` at bottom

### 8.7 Booking Flow (Multi-step)

**Step 1 — Select Date:**

- `TableCalendar` or `showDatePicker`
- Only future dates enabled

**Step 2 — Select Time Slot:**

- `GridView` of time slot chips (08:00–22:00)
- Green = available, Red = booked
- Tap to select start time
- Duration selector: 1hr / 2hr / 3hr buttons

**Step 3 — Equipment Rentals:**

- `EquipmentSelector` widget for each type
- Rackets (฿50), Shuttlecocks (฿30), Shoes (฿40)
- Counter with +/- buttons

**Step 4 — Price Summary:**

- Court cost line
- Equipment breakdown lines
- Membership discount line (if active)
- **Total** in bold
- "Proceed to Payment" button

**Step 5 — Payment Method:**

- Radio selection: Credit Card / Bank Transfer / PromptPay
- Credit Card: `flutter_stripe` payment sheet via `client_secret`
- Bank Transfer: Shows bank details + reference input
- PromptPay: Shows QR/prompt

**Step 6 — Confirmation:**

- Success icon + "Booking Confirmed!" text
- Booking summary card
- "View Booking" and "Back to Home" buttons

### 8.8 My Bookings Screen

- `TabBar`: Upcoming | Completed | Cancelled
- Each tab: `ListView` of `BookingCard` widgets
- Swipe to cancel on upcoming tab (`Dismissible`)
- Tap card → Booking Detail screen

### 8.9 Booking Detail Screen

- Large color-coded `StatusBadge`
- Court name + thumbnail
- Date, time, duration
- Equipment rented (if any)
- Price breakdown
- Payment status & method
- "Cancel Booking" button (if upcoming)
- "Write Review" button (if completed and not reviewed)

### 8.10 Review Screen

- Star rating selector (1-5, interactive)
- Comment `TextFormField` (multiline)
- "Submit Review" `ElevatedButton`
- Calls `POST /api/reviews`

### 8.11 Waitlist Screen

- `ListView` of waitlist entries
- Each entry: court name, date/time, position badge, status
- "Leave Waitlist" button per entry
- "Join Waitlist" button accessible from Court Detail when slot is full

### 8.12 Membership Screen

- Status card (Active/Inactive with color)
- If inactive:
  - Benefits list
  - "Subscribe ฿199/month" button
  - Savings calculator (hours/week input → monthly savings)
- If active:
  - Expiry date
  - Days remaining
  - Active benefits indicator

### 8.13 Community Screen

- `ListView` of post cards (newest first)
- Each card: title, content preview, author, date
- FAB to create new post
- Tap post → detail/edit view
- Own posts: edit/delete options

### 8.14 Profile Screen

- User avatar (initials `CircleAvatar`)
- Full name, email, address
- Membership status badge
- `ListTile` menu items:
  - Edit Profile
  - Membership
  - My Waitlists
  - Community
  - Language (EN / TH / CN)
  - Admin Panel (if `role == 'ADMIN'`)
  - About
  - Logout

### 8.15 Admin Dashboard (ADMIN only)

- Summary cards: Total Users, Total Courts, Today's Bookings, Revenue
- Quick actions: Add Court, View All Bookings

### 8.16 Admin Manage Courts (ADMIN only)

- `ListView` of all courts
- FAB to add court
- Swipe to delete
- Tap to edit

### 8.17 Admin Manage Bookings (ADMIN only)

- `ListView` of all bookings
- Filter by status
- Tap to update status

### 8.18 Admin Manage Users (ADMIN only)

- `ListView` of all users
- Tap to view user details

### 8.19 Admin Manage Community (ADMIN only)

- `ListView` of all community posts
- Delete option on each

---

## 9. Presentation Layer — Widgets

### Shared Components

| Widget              | Purpose                                                               |
| ------------------- | --------------------------------------------------------------------- |
| `CourtCard`         | Court preview card for lists (image, name, price, rating, distance)   |
| `BookingCard`       | Booking summary card (court name, date, time, status, price)          |
| `ReviewCard`        | Review display card (user, stars, comment, date)                      |
| `RatingStars`       | Visual star rating display (read-only, 1-5 stars)                     |
| `TimeSlotGrid`      | Grid of time slot chips with color coding                             |
| `EquipmentSelector` | Counter widget for equipment quantity (+/- buttons)                   |
| `PriceSummary`      | Price breakdown display (court + equipment + discount)                |
| `StatusBadge`       | Color-coded status chip (pending/confirmed/cancelled/completed)       |
| `EmptyState`        | Empty list placeholder (icon + message)                               |
| `LoadingShimmer`    | Shimmer loading effect placeholder                                    |
| `BottomNavBar`      | Bottom navigation bar (Home, Map, Bookings, Profile + optional Admin) |

---

## 10. Navigation & Routing

### GoRouter Configuration

```dart
// lib/presentation/router/app_router.dart
import 'package:go_router/go_router.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  redirect: (context, state) {
    final authState = /* read auth state */;
    final isAuthRoute = state.matchedLocation == '/login' ||
        state.matchedLocation == '/register' ||
        state.matchedLocation == '/splash';

    if (authState is Unauthenticated && !isAuthRoute) return '/login';
    if (authState is Authenticated && isAuthRoute) return '/home';
    return null;
  },
  routes: [
    GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
    ShellRoute(
      builder: (_, __, child) => MainScaffold(child: child),
      routes: [
        GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
        GoRoute(path: '/map', builder: (_, __) => const MapScreen()),
        GoRoute(path: '/bookings', builder: (_, __) => const MyBookingsScreen()),
        GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
      ],
    ),
    GoRoute(path: '/courts/:id', builder: (_, state) =>
        CourtDetailScreen(courtId: state.pathParameters['id']!)),
    GoRoute(path: '/courts/:id/book', builder: (_, state) =>
        BookingScreen(courtId: state.pathParameters['id']!)),
    GoRoute(path: '/bookings/:id', builder: (_, state) =>
        BookingDetailScreen(bookingId: state.pathParameters['id']!)),
    GoRoute(path: '/reviews/create', builder: (_, state) =>
        const ReviewScreen()),
    GoRoute(path: '/waitlist', builder: (_, __) => const WaitlistScreen()),
    GoRoute(path: '/membership', builder: (_, __) => const MembershipScreen()),
    GoRoute(path: '/community', builder: (_, __) => const CommunityScreen()),
    GoRoute(path: '/community/create', builder: (_, __) =>
        const CreatePostScreen()),
    GoRoute(path: '/profile/edit', builder: (_, __) =>
        const EditProfileScreen()),
    GoRoute(path: '/payment', builder: (_, __) => const PaymentScreen()),
    GoRoute(path: '/admin', builder: (_, __) => const AdminDashboardScreen()),
    GoRoute(path: '/admin/courts', builder: (_, __) =>
        const ManageCourtsScreen()),
    GoRoute(path: '/admin/bookings', builder: (_, __) =>
        const ManageBookingsScreen()),
    GoRoute(path: '/admin/users', builder: (_, __) =>
        const ManageUsersScreen()),
    GoRoute(path: '/admin/community', builder: (_, __) =>
        const ManageCommunityScreen()),
  ],
);
```

---

## 11. Authentication Flow

```
Splash Screen → Check stored token → Valid? → Home Screen
                                     → Invalid/Expired? → Login Screen

Login Screen → POST /api/auth/login → Store tokens in FlutterSecureStorage → Home Screen
Register Screen → POST /api/auth/register → Auto-login → Home Screen

All API calls attach: Authorization: Bearer <access_token>
On 401 response → Clear tokens → Redirect to Login
```

### Token Management

- Store `access_token`, `refresh_token`, `expires_at` in `FlutterSecureStorage`
- Dio interceptor auto-attaches `Authorization: Bearer <token>` header
- On 401: attempt refresh; if fails, clear tokens and redirect to login
- Logout: clear all tokens, reset auth state

---

## 12. API Reference

**Base URL:** `http://<SERVER_IP>:8080/api`

- Android emulator: `10.0.2.2`
- iOS simulator: `localhost`
- Physical device: LAN IP (e.g., `192.168.1.x`)

All authenticated endpoints require: `Authorization: Bearer <access_token>`

### Endpoint Summary

| Method | Endpoint                          | Auth     | Description                  |
| ------ | --------------------------------- | -------- | ---------------------------- |
| POST   | `/auth/register`                  | None     | Register new user            |
| POST   | `/auth/login`                     | None     | Login, get tokens            |
| GET    | `/auth/profile`                   | Required | Get user profile             |
| PUT    | `/auth/profile`                   | Required | Update profile               |
| GET    | `/auth/membership/status`         | Required | Get membership status        |
| POST   | `/auth/membership/subscribe`      | Required | Subscribe to membership      |
| GET    | `/courts`                         | Required | List courts (search/filter)  |
| GET    | `/courts/:id`                     | Required | Court detail                 |
| GET    | `/courts/:id/availability`        | Required | Time slots for date          |
| POST   | `/courts`                         | Admin    | Create court                 |
| PUT    | `/courts/:id`                     | Admin    | Update court                 |
| DELETE | `/courts/:id`                     | Admin    | Delete court                 |
| GET    | `/bookings`                       | Required | List bookings                |
| POST   | `/bookings`                       | Required | Create booking               |
| GET    | `/bookings/:id`                   | Required | Booking detail               |
| PUT    | `/bookings/:id/cancel`            | Required | Cancel booking               |
| PUT    | `/bookings/:id`                   | Admin    | Update booking status        |
| POST   | `/payments/create-payment-intent` | Required | Create Stripe payment intent |
| POST   | `/payments/confirm`               | Required | Confirm payment              |
| POST   | `/payments/bank-transfer`         | Required | Bank transfer payment        |
| POST   | `/payments/promptpay`             | Required | PromptPay payment            |
| GET    | `/payments/booking/:bookingId`    | Required | Payment status for booking   |
| POST   | `/waitlist`                       | Required | Join waitlist                |
| GET    | `/waitlist`                       | Required | List waitlist entries        |
| DELETE | `/waitlist/:id`                   | Required | Leave waitlist               |
| GET    | `/reviews`                        | None\*   | List reviews for court       |
| POST   | `/reviews`                        | Required | Create review                |
| PUT    | `/reviews/:id`                    | Required | Update review (owner)        |
| DELETE | `/reviews/:id`                    | Required | Delete review (owner/admin)  |
| GET    | `/community`                      | Required | List community posts         |
| POST   | `/community`                      | Required | Create post                  |
| PUT    | `/community/:id`                  | Required | Update post (owner)          |
| DELETE | `/community/:id`                  | Required | Delete post (owner/admin)    |
| GET    | `/health`                         | None     | Health check                 |
| GET    | `/meta`                           | None     | API metadata                 |

### Booking API — Create Booking Request

```json
{
  "court_id": "uuid",
  "booking_date": "2026-05-01",
  "start_time": "09:00",
  "end_time": "11:00",
  "duration_hours": 2,
  "equipment_rentals": {
    "rackets": 1,
    "shuttlecocks": 2,
    "shoes": 0
  }
}
```

### Payment API — Create Payment Intent Request

```json
{
  "booking_id": "uuid",
  "payment_method": "credit_card"
}
```

### Payment API — Create Payment Intent Response

```json
{
  "client_secret": "pi_xxx_secret_yyy",
  "payment_intent_id": "pi_xxx",
  "amount": 40000
}
```

---

## 13. Database Schema

### `users`

| Column                | Type         | Constraints                                       |
| --------------------- | ------------ | ------------------------------------------------- |
| id                    | UUID         | PK, auto-generated                                |
| auth_id               | UUID         | FK to Supabase Auth users                         |
| email                 | VARCHAR(255) | UNIQUE, NOT NULL                                  |
| full_name             | VARCHAR(255) | NOT NULL                                          |
| address               | TEXT         |                                                   |
| role                  | VARCHAR(20)  | DEFAULT 'CUSTOMER', CHECK IN ('CUSTOMER','ADMIN') |
| membership_status     | VARCHAR(20)  | DEFAULT 'none'                                    |
| membership_expires_at | TIMESTAMP    | NULLABLE                                          |
| created_at            | TIMESTAMP    | DEFAULT NOW()                                     |

### `courts`

| Column         | Type          | Constraints   |
| -------------- | ------------- | ------------- |
| id             | UUID          | PK            |
| name           | VARCHAR(255)  | NOT NULL      |
| description    | TEXT          |               |
| location       | VARCHAR(500)  | NOT NULL      |
| price_per_hour | DECIMAL(10,2) | NOT NULL      |
| latitude       | DECIMAL(10,8) |               |
| longitude      | DECIMAL(11,8) |               |
| image_url      | VARCHAR(500)  |               |
| avg_rating     | DECIMAL(3,2)  | DEFAULT 0     |
| review_count   | INTEGER       | DEFAULT 0     |
| created_at     | TIMESTAMP     | DEFAULT NOW() |

### `bookings`

| Column            | Type          | Constraints                                                                 |
| ----------------- | ------------- | --------------------------------------------------------------------------- |
| id                | UUID          | PK                                                                          |
| user_id           | UUID          | FK to users.id                                                              |
| court_id          | UUID          | FK to courts.id                                                             |
| booking_date      | DATE          | NOT NULL                                                                    |
| start_time        | TIME          | NOT NULL                                                                    |
| end_time          | TIME          | NOT NULL                                                                    |
| duration_hours    | INTEGER       | NOT NULL, CHECK 1-3                                                         |
| total_price       | DECIMAL(10,2) | NOT NULL                                                                    |
| status            | VARCHAR(20)   | DEFAULT 'pending', CHECK IN ('pending','confirmed','cancelled','completed') |
| equipment_rentals | JSONB         | DEFAULT '{}'                                                                |
| created_at        | TIMESTAMP     | DEFAULT NOW()                                                               |

### `payments`

| Column                   | Type          | Constraints                                          |
| ------------------------ | ------------- | ---------------------------------------------------- |
| id                       | UUID          | PK                                                   |
| booking_id               | UUID          | FK to bookings.id                                    |
| amount                   | DECIMAL(10,2) | NOT NULL                                             |
| payment_method           | VARCHAR(50)   | CHECK IN ('credit_card','bank_transfer','promptpay') |
| status                   | VARCHAR(20)   | DEFAULT 'pending'                                    |
| stripe_payment_intent_id | VARCHAR(255)  | NULLABLE                                             |
| bank_reference           | VARCHAR(255)  | NULLABLE                                             |
| created_at               | TIMESTAMP     | DEFAULT NOW()                                        |

### `reviews`

| Column     | Type      | Constraints         |
| ---------- | --------- | ------------------- |
| id         | UUID      | PK                  |
| court_id   | UUID      | FK to courts.id     |
| user_id    | UUID      | FK to users.id      |
| rating     | INTEGER   | NOT NULL, CHECK 1-5 |
| comment    | TEXT      |                     |
| created_at | TIMESTAMP | DEFAULT NOW()       |
| updated_at | TIMESTAMP |                     |

### `waitlist`

| Column       | Type        | Constraints       |
| ------------ | ----------- | ----------------- |
| id           | UUID        | PK                |
| user_id      | UUID        | FK to users.id    |
| court_id     | UUID        | FK to courts.id   |
| booking_date | DATE        | NOT NULL          |
| start_time   | TIME        | NOT NULL          |
| end_time     | TIME        | NOT NULL          |
| position     | INTEGER     | NOT NULL          |
| status       | VARCHAR(20) | DEFAULT 'waiting' |
| created_at   | TIMESTAMP   | DEFAULT NOW()     |

### `community_posts`

| Column     | Type         | Constraints    |
| ---------- | ------------ | -------------- |
| id         | UUID         | PK             |
| user_id    | UUID         | FK to users.id |
| title      | VARCHAR(255) | NOT NULL       |
| content    | TEXT         | NOT NULL       |
| created_at | TIMESTAMP    | DEFAULT NOW()  |
| updated_at | TIMESTAMP    |                |

---

## 14. Design System

### Color Scheme

| Element        | Color                                    |
| -------------- | ---------------------------------------- |
| Primary        | `#006400` (Dark Green - badminton theme) |
| Primary Light  | `#4CAF50`                                |
| Secondary      | `#FF6F00` (Orange accent)                |
| Background     | `#F5F5F5`                                |
| Surface        | `#FFFFFF`                                |
| Error          | `#B00020`                                |
| Success        | `#4CAF50`                                |
| Text Primary   | `#212121`                                |
| Text Secondary | `#757575`                                |

### Typography

- **Headings:** Bold, 24sp / 20sp / 18sp
- **Body:** Regular, 16sp / 14sp
- **Captions:** 12sp

### Component Patterns

| Component         | Pattern                                                             |
| ----------------- | ------------------------------------------------------------------- |
| **Cards**         | `Card` with `RoundedRectangleBorder(borderRadius: 12)`, elevation 2 |
| **Primary Btn**   | `ElevatedButton` filled green, rounded 8dp                          |
| **Secondary Btn** | `OutlinedButton` with green border                                  |
| **Input Fields**  | `TextFormField` with `OutlineInputBorder`, labels                   |
| **Bottom Nav**    | 4 items (Home, Map, Bookings, Profile), 5 if Admin                  |
| **Snackbars**     | `ScaffoldMessenger.of(context).showSnackBar(...)`                   |
| **Loading**       | `CircularProgressIndicator` or shimmer                              |
| **Empty States**  | Icon + message centered                                             |

### Status Colors

| Status    | Color  |
| --------- | ------ |
| pending   | Orange |
| confirmed | Blue   |
| completed | Green  |
| cancelled | Red    |
| waiting   | Yellow |

---

## 15. Environment & Platform Configuration

### Android — `AndroidManifest.xml`

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />

<application
    android:usesCleartextTraffic="true"
    ...>
    <meta-data
        android:name="com.google.android.geo.API_KEY"
        android:value="YOUR_GOOGLE_MAPS_API_KEY" />
</application>
```

### Android — Network Security Config

```xml
<!-- android/app/src/main/res/xml/network_security_config.xml -->
<network-security-config>
    <domain-config cleartextTrafficPermitted="true">
        <domain includeSubdomains="true">10.0.2.2</domain>
        <domain includeSubdomains="true">localhost</domain>
        <domain includeSubdomains="true">192.168.0.0/16</domain>
    </domain-config>
</network-security-config>
```

### iOS — `Info.plist`

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to show nearby badminton courts.</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>We need your location to show nearby badminton courts.</string>
```

### Backend `.env` for Mobile Development

```env
PORT=8080
ENABLE_FRONTEND=false
CORS_ORIGINS=*
```

---

## 16. Localization

### Configuration — `l10n.yaml`

```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
```

### Language Files

- `lib/l10n/app_en.arb` — English
- `lib/l10n/app_th.arb` — Thai (TH)
- `lib/l10n/app_zh.arb` — Chinese (中文)

### English ARB Example

```json
{
  "@@locale": "en",
  "appTitle": "Pro Badminton",
  "login": "Login",
  "register": "Register",
  "email": "Email",
  "password": "Password",
  "searchCourts": "Search courts...",
  "bookNow": "Book Now",
  "myBookings": "My Bookings",
  "profile": "Profile",
  "logout": "Logout",
  "membership": "Membership",
  "community": "Community",
  "waitlist": "Waitlist",
  "reviews": "Reviews",
  "cancelBooking": "Cancel Booking",
  "confirmPayment": "Confirm Payment",
  "noBookings": "No bookings found",
  "noCourts": "No courts found",
  "errorOccurred": "An error occurred"
}
```

### Locale Provider

```dart
// lib/presentation/providers/locale_provider.dart
@riverpod
class LocaleState extends _$LocaleState {
  @override
  Locale build() {
    final prefs = ref.read(preferencesStorageProvider);
    return Locale(prefs.getLocale());
  }

  void setLocale(String localeCode) {
    final prefs = ref.read(preferencesStorageProvider);
    prefs.setLocale(localeCode);
    state = Locale(localeCode);
  }
}
```

---

## 17. Testing Strategy

### Unit Tests

- **Models:** Test `fromJson` / `toJson` for all models
- **Providers:** Test state transitions with mocked API services
- **Utils:** Test `PriceCalculator`, `Validators`, `Formatters`

### Widget Tests

- Screen renders correctly
- Form validation works
- Loading/error states display
- Navigation between screens

### Integration Tests

- Full auth flow (register → login → profile)
- Court discovery (search → filter → detail)
- Booking flow (select date → time → equipment → payment → confirmation)
- Booking management (view → cancel → review)

### Test Directory Structure

```
test/
├── unit/
│   ├── models/
│   │   ├── user_test.dart
│   │   ├── court_test.dart
│   │   ├── booking_test.dart
│   │   └── ...
│   ├── providers/
│   │   ├── auth_provider_test.dart
│   │   ├── court_provider_test.dart
│   │   └── ...
│   └── utils/
│       ├── price_calculator_test.dart
│       ├── validators_test.dart
│       └── formatters_test.dart
├── widget/
│   ├── screens/
│   │   ├── login_screen_test.dart
│   │   ├── home_screen_test.dart
│   │   └── ...
│   └── widgets/
│       ├── court_card_test.dart
│       └── ...
integration_test/
└── app_test.dart
```

---

## Quick Reference

| Item             | Value                                         |
| ---------------- | --------------------------------------------- |
| App Name         | Pro Badminton                                 |
| Package Name     | com.folkliygrunt.probadminton                 |
| Backend Base URL | `http://10.0.2.2:8080/api` (Android emulator) |
| Currency         | Thai Baht (฿)                                 |
| Min Android      | 5.0 (API 21)                                  |
| Min iOS          | 12.0                                          |
| Framework        | Flutter 3.x                                   |
| Language         | Dart 3.x                                      |
| Architecture     | Clean Architecture + Riverpod                 |
| UI               | Material 3                                    |
| Auth             | Supabase (email/password, JWT)                |
| Payments         | Stripe, Bank Transfer, PromptPay              |
| Maps             | google_maps_flutter                           |
| State Management | Riverpod                                      |
| Navigation       | GoRouter                                      |
