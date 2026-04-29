import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/remote/api/booking_api.dart';
import '../../data/remote/api/court_api.dart';
import '../../domain/models/booking.dart';
import '../../domain/models/court.dart';
import 'auth_provider.dart';
import 'court_provider.dart';

// Booking API provider
final bookingApiProvider = Provider<BookingApi>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return BookingApi(apiClient.dio);
});

// ── Booking List ──

sealed class BookingListState {
  const BookingListState();
}

class BookingListInitial extends BookingListState {
  const BookingListInitial();
}

class BookingListLoading extends BookingListState {
  const BookingListLoading();
}

class BookingListLoaded extends BookingListState {
  final List<Booking> bookings;
  const BookingListLoaded(this.bookings);
}

class BookingListError extends BookingListState {
  final String message;
  const BookingListError(this.message);
}

class BookingListNotifier extends StateNotifier<BookingListState> {
  final BookingApi _bookingApi;

  BookingListNotifier(this._bookingApi) : super(const BookingListInitial());

  Future<void> loadBookings() async {
    state = const BookingListLoading();
    try {
      final response = await _bookingApi.getBookings();
      dynamic data = response.data;
      if (data is String) data = jsonDecode(data);
      if (data is Map && data['bookings'] != null) {
        final raw = data['bookings'];
        final List<dynamic> list = raw is List ? raw : [];
        final bookings = list
            .map(
              (j) => Booking.fromJson(
                j is Map<String, dynamic>
                    ? j
                    : Map<String, dynamic>.from(j as Map),
              ),
            )
            .toList();
        state = BookingListLoaded(bookings);
      } else if (data is List) {
        final bookings = data
            .map((j) => Booking.fromJson(Map<String, dynamic>.from(j as Map)))
            .toList();
        state = BookingListLoaded(bookings);
      } else {
        state = const BookingListLoaded([]);
      }
    } catch (e) {
      state = BookingListError('Failed to load bookings: $e');
    }
  }

  Future<bool> cancelBooking(String bookingId) async {
    try {
      await _bookingApi.cancelBooking(bookingId);
      // Refresh the list after cancel
      await loadBookings();
      return true;
    } catch (e) {
      return false;
    }
  }
}

final bookingListProvider =
    StateNotifierProvider<BookingListNotifier, BookingListState>((ref) {
      final bookingApi = ref.watch(bookingApiProvider);
      return BookingListNotifier(bookingApi);
    });

// ── Court Availability ──

sealed class AvailabilityState {
  const AvailabilityState();
}

class AvailabilityInitial extends AvailabilityState {
  const AvailabilityInitial();
}

class AvailabilityLoading extends AvailabilityState {
  const AvailabilityLoading();
}

class AvailabilityLoaded extends AvailabilityState {
  final List<TimeSlot> slots;
  const AvailabilityLoaded(this.slots);
}

class AvailabilityError extends AvailabilityState {
  final String message;
  const AvailabilityError(this.message);
}

class AvailabilityNotifier extends StateNotifier<AvailabilityState> {
  final CourtApi _courtApi;

  AvailabilityNotifier(this._courtApi) : super(const AvailabilityInitial());

  Future<void> loadAvailability(String courtId, String date) async {
    state = const AvailabilityLoading();
    try {
      final response = await _courtApi.getCourtAvailability(courtId, date);
      dynamic data = response.data;
      if (data is String) data = jsonDecode(data);
      if (data is Map && data['slots'] != null) {
        final raw = data['slots'];
        final List<dynamic> list = raw is List ? raw : [];
        final slots = list
            .map(
              (j) => TimeSlot.fromJson(
                j is Map<String, dynamic>
                    ? j
                    : Map<String, dynamic>.from(j as Map),
              ),
            )
            .toList();
        state = AvailabilityLoaded(slots);
      } else if (data is Map && data['availability'] != null) {
        final raw = data['availability'];
        final List<dynamic> list = raw is List ? raw : [];
        final slots = list
            .map(
              (j) => TimeSlot.fromJson(
                j is Map<String, dynamic>
                    ? j
                    : Map<String, dynamic>.from(j as Map),
              ),
            )
            .toList();
        state = AvailabilityLoaded(slots);
      } else {
        state = const AvailabilityLoaded([]);
      }
    } catch (e) {
      state = AvailabilityError('Failed to load availability: $e');
    }
  }
}

final availabilityProvider =
    StateNotifierProvider.family<
      AvailabilityNotifier,
      AvailabilityState,
      String
    >((ref, courtId) {
      final courtApi = ref.watch(courtApiProvider);
      return AvailabilityNotifier(courtApi);
    });

// ── Booking Creation ──

sealed class BookingCreationState {
  const BookingCreationState();
}

class BookingCreationIdle extends BookingCreationState {
  const BookingCreationIdle();
}

class BookingCreationCreating extends BookingCreationState {
  const BookingCreationCreating();
}

class BookingCreationCreated extends BookingCreationState {
  final Booking booking;
  const BookingCreationCreated(this.booking);
}

class BookingCreationError extends BookingCreationState {
  final String message;
  const BookingCreationError(this.message);
}

class BookingCreationNotifier extends StateNotifier<BookingCreationState> {
  final BookingApi _bookingApi;

  BookingCreationNotifier(this._bookingApi)
    : super(const BookingCreationIdle());

  Future<void> createBooking({
    required String courtId,
    required String startTime,
    required int durationHours,
    required String paymentMethod,
    int rackets = 0,
    int shuttlecocks = 0,
    int shoes = 0,
  }) async {
    state = const BookingCreationCreating();
    try {
      final body = <String, dynamic>{
        'court_id': courtId,
        'start_time': startTime,
        'duration_hours': durationHours,
        'payment_method': paymentMethod.toUpperCase(),
      };

      // Build equipment array matching API spec
      final equipment = <Map<String, dynamic>>[];
      if (rackets > 0) {
        equipment.add({'equipment_type': 'RACKET', 'quantity': rackets});
      }
      if (shuttlecocks > 0) {
        equipment.add({
          'equipment_type': 'SHUTTLECOCK',
          'quantity': shuttlecocks,
        });
      }
      if (shoes > 0) {
        equipment.add({'equipment_type': 'SHOES', 'quantity': shoes});
      }
      if (equipment.isNotEmpty) {
        body['equipment'] = equipment;
      }

      final response = await _bookingApi.createBooking(body);
      dynamic data = response.data;
      if (data is String) data = jsonDecode(data);

      // API returns booking directly (201) or wrapped in {booking: ...}
      if (data is Map && data['booking'] != null) {
        final booking = Booking.fromJson(
          Map<String, dynamic>.from(data['booking'] as Map),
        );
        state = BookingCreationCreated(booking);
      } else if (data is Map && data['id'] != null) {
        // Booking returned directly (not wrapped)
        final booking = Booking.fromJson(Map<String, dynamic>.from(data));
        state = BookingCreationCreated(booking);
      } else if (data is Map && data['checkout_url'] != null) {
        // Stripe checkout redirect — treat as success for now
        state = const BookingCreationError(
          'Credit card checkout redirect — not yet supported in app',
        );
      } else {
        state = const BookingCreationError('Failed to create booking');
      }
    } catch (e) {
      state = BookingCreationError('Failed to create booking: $e');
    }
  }

  void reset() {
    state = const BookingCreationIdle();
  }
}

final bookingCreationProvider =
    StateNotifierProvider<BookingCreationNotifier, BookingCreationState>((ref) {
      final bookingApi = ref.watch(bookingApiProvider);
      return BookingCreationNotifier(bookingApi);
    });

// ── Booking Detail ──

sealed class BookingDetailState {
  const BookingDetailState();
}

class BookingDetailInitial extends BookingDetailState {
  const BookingDetailInitial();
}

class BookingDetailLoading extends BookingDetailState {
  const BookingDetailLoading();
}

class BookingDetailLoaded extends BookingDetailState {
  final Booking booking;
  const BookingDetailLoaded(this.booking);
}

class BookingDetailError extends BookingDetailState {
  final String message;
  const BookingDetailError(this.message);
}

class BookingDetailNotifier extends StateNotifier<BookingDetailState> {
  final BookingApi _bookingApi;

  BookingDetailNotifier(this._bookingApi) : super(const BookingDetailInitial());

  Future<void> loadBooking(String bookingId) async {
    state = const BookingDetailLoading();
    try {
      final response = await _bookingApi.getBookingDetail(bookingId);
      dynamic data = response.data;
      if (data is String) data = jsonDecode(data);
      if (data is Map && data['booking'] != null) {
        final booking = Booking.fromJson(
          Map<String, dynamic>.from(data['booking'] as Map),
        );
        state = BookingDetailLoaded(booking);
      } else if (data is Map && data['id'] != null) {
        final booking = Booking.fromJson(Map<String, dynamic>.from(data));
        state = BookingDetailLoaded(booking);
      } else {
        state = const BookingDetailError('Booking not found');
      }
    } catch (e) {
      state = BookingDetailError('Failed to load booking: $e');
    }
  }

  Future<bool> cancelBooking(String bookingId) async {
    try {
      await _bookingApi.cancelBooking(bookingId);
      // Reload after cancel
      await loadBooking(bookingId);
      return true;
    } catch (e) {
      return false;
    }
  }
}

final bookingDetailProvider =
    StateNotifierProvider.family<
      BookingDetailNotifier,
      BookingDetailState,
      String
    >((ref, bookingId) {
      final bookingApi = ref.watch(bookingApiProvider);
      return BookingDetailNotifier(bookingApi);
    });
