import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/remote/api/booking_api.dart';
import '../../data/remote/api/court_api.dart';
import '../../domain/models/booking.dart';
import '../../domain/models/court.dart';
import 'auth_provider.dart';

// API providers
final adminCourtApiProvider = Provider<CourtApi>((ref) {
  return CourtApi(ref.watch(apiClientProvider).dio);
});

final adminBookingApiProvider = Provider<BookingApi>((ref) {
  return BookingApi(ref.watch(apiClientProvider).dio);
});

// ── Admin Stats ──

sealed class AdminStatsState {
  const AdminStatsState();
}

class AdminStatsLoading extends AdminStatsState {
  const AdminStatsLoading();
}

class AdminStatsLoaded extends AdminStatsState {
  final int totalCourts;
  final int totalBookings;
  final int totalUsers;
  final double revenue;
  const AdminStatsLoaded({
    required this.totalCourts,
    required this.totalBookings,
    required this.totalUsers,
    required this.revenue,
  });
}

class AdminStatsError extends AdminStatsState {
  final String message;
  const AdminStatsError(this.message);
}

class AdminStatsNotifier extends StateNotifier<AdminStatsState> {
  final CourtApi _courtApi;
  final BookingApi _bookingApi;

  AdminStatsNotifier(this._courtApi, this._bookingApi)
    : super(const AdminStatsLoading());

  Future<void> loadStats() async {
    state = const AdminStatsLoading();
    try {
      final courtsRes = await _courtApi.getCourts();
      final bookingsRes = await _bookingApi.getBookings();
      dynamic courtsData = courtsRes.data;
      dynamic bookingsData = bookingsRes.data;
      if (courtsData is String) courtsData = jsonDecode(courtsData);
      if (bookingsData is String) bookingsData = jsonDecode(bookingsData);

      int totalCourts = 0;
      int totalBookings = 0;
      int totalUsers = 0;
      double revenue = 0;

      if (courtsData is Map) {
        final list = courtsData['courts'] ?? courtsData;
        if (list is List) totalCourts = list.length;
      } else if (courtsData is List) {
        totalCourts = courtsData.length;
      }

      if (bookingsData is Map) {
        final list = bookingsData['bookings'] ?? bookingsData;
        if (list is List) {
          totalBookings = list.length;
          for (final b in list) {
            if (b is Map) {
              final amount = b['total_amount'] ?? b['total_price'];
              if (amount is num) {
                revenue += amount.toDouble();
              } else if (amount is String) {
                revenue += double.tryParse(amount) ?? 0;
              }
            }
          }
        }
        final tu = bookingsData['total_users'];
        totalUsers = tu is int ? tu : (tu is num ? tu.toInt() : 0);
      } else if (bookingsData is List) {
        totalBookings = bookingsData.length;
      }

      state = AdminStatsLoaded(
        totalCourts: totalCourts,
        totalBookings: totalBookings,
        totalUsers: totalUsers,
        revenue: revenue,
      );
    } catch (e) {
      state = AdminStatsError('Failed to load stats: $e');
    }
  }
}

final adminStatsProvider =
    StateNotifierProvider<AdminStatsNotifier, AdminStatsState>((ref) {
      final courtApi = ref.watch(adminCourtApiProvider);
      final bookingApi = ref.watch(adminBookingApiProvider);
      final notifier = AdminStatsNotifier(courtApi, bookingApi);
      notifier.loadStats();
      return notifier;
    });

// ── Manage Courts ──

sealed class ManageCourtsState {
  const ManageCourtsState();
}

class ManageCourtsLoading extends ManageCourtsState {
  const ManageCourtsLoading();
}

class ManageCourtsLoaded extends ManageCourtsState {
  final List<dynamic> courts;
  const ManageCourtsLoaded(this.courts);
}

class ManageCourtsError extends ManageCourtsState {
  final String message;
  const ManageCourtsError(this.message);
}

class ManageCourtsNotifier extends StateNotifier<ManageCourtsState> {
  final CourtApi _courtApi;

  ManageCourtsNotifier(this._courtApi) : super(const ManageCourtsLoading());

  Future<void> loadCourts() async {
    state = const ManageCourtsLoading();
    try {
      final res = await _courtApi.getCourts();
      dynamic data = res.data;
      if (data is String) data = jsonDecode(data);
      if (data is Map && data['courts'] != null) {
        final raw = data['courts'];
        final list = raw is List ? raw : [];
        final courts = list
            .map(
              (j) => Court.fromJson(
                j is Map<String, dynamic>
                    ? j
                    : Map<String, dynamic>.from(j as Map),
              ),
            )
            .toList();
        state = ManageCourtsLoaded(courts);
      } else if (data is List) {
        final courts = data
            .map((j) => Court.fromJson(Map<String, dynamic>.from(j as Map)))
            .toList();
        state = ManageCourtsLoaded(courts);
      } else {
        state = const ManageCourtsLoaded([]);
      }
    } catch (e) {
      state = ManageCourtsError('Failed: $e');
    }
  }

  Future<bool> deleteCourt(String courtId) async {
    try {
      await _courtApi.deleteCourt(courtId);
      await loadCourts();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> createCourt(Map<String, dynamic> body) async {
    try {
      await _courtApi.createCourt(body);
      await loadCourts();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateCourt(String courtId, Map<String, dynamic> body) async {
    try {
      await _courtApi.updateCourt(courtId, body);
      await loadCourts();
      return true;
    } catch (e) {
      return false;
    }
  }
}

final manageCourtsProvider =
    StateNotifierProvider<ManageCourtsNotifier, ManageCourtsState>((ref) {
      final courtApi = ref.watch(adminCourtApiProvider);
      final notifier = ManageCourtsNotifier(courtApi);
      notifier.loadCourts();
      return notifier;
    });

// ── Manage Bookings ──

sealed class ManageBookingsState {
  const ManageBookingsState();
}

class ManageBookingsLoading extends ManageBookingsState {
  const ManageBookingsLoading();
}

class ManageBookingsLoaded extends ManageBookingsState {
  final List<Booking> bookings;
  const ManageBookingsLoaded(this.bookings);
}

class ManageBookingsError extends ManageBookingsState {
  final String message;
  const ManageBookingsError(this.message);
}

class ManageBookingsNotifier extends StateNotifier<ManageBookingsState> {
  final BookingApi _bookingApi;

  ManageBookingsNotifier(this._bookingApi)
    : super(const ManageBookingsLoading());

  Future<void> loadBookings() async {
    state = const ManageBookingsLoading();
    try {
      final res = await _bookingApi.getBookings();
      dynamic data = res.data;
      if (data is String) data = jsonDecode(data);
      if (data is Map && data['bookings'] != null) {
        final raw = data['bookings'];
        final list = raw is List ? raw : [];
        final bookings = list
            .map(
              (j) => Booking.fromJson(
                j is Map<String, dynamic>
                    ? j
                    : Map<String, dynamic>.from(j as Map),
              ),
            )
            .toList();
        state = ManageBookingsLoaded(bookings);
      } else if (data is List) {
        final bookings = data
            .map((j) => Booking.fromJson(Map<String, dynamic>.from(j as Map)))
            .toList();
        state = ManageBookingsLoaded(bookings);
      } else {
        state = const ManageBookingsLoaded([]);
      }
    } catch (e) {
      state = ManageBookingsError('Failed: $e');
    }
  }

  Future<bool> updateStatus(String bookingId, String status) async {
    try {
      // API only supports cancellation via DELETE /bookings/:id
      if (status == 'CANCELLED') {
        await _bookingApi.cancelBooking(bookingId);
      }
      await loadBookings();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> cancelBooking(String bookingId) async {
    try {
      await _bookingApi.cancelBooking(bookingId);
      await loadBookings();
      return true;
    } catch (e) {
      return false;
    }
  }
}

final manageBookingsProvider =
    StateNotifierProvider<ManageBookingsNotifier, ManageBookingsState>((ref) {
      final bookingApi = ref.watch(adminBookingApiProvider);
      final notifier = ManageBookingsNotifier(bookingApi);
      notifier.loadBookings();
      return notifier;
    });
