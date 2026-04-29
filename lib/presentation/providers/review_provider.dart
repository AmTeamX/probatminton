import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/remote/api/booking_api.dart';
import '../../data/remote/api/review_api.dart';
import '../../domain/models/booking.dart';
import '../../domain/models/review.dart';
import 'auth_provider.dart';
import 'booking_provider.dart';

// Review API provider
final reviewApiProvider = Provider<ReviewApi>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ReviewApi(apiClient.dio);
});

// Review list state
sealed class ReviewListState {
  const ReviewListState();
}

class ReviewListLoading extends ReviewListState {
  const ReviewListLoading();
}

class ReviewListLoaded extends ReviewListState {
  final List<Review> reviews;
  const ReviewListLoaded(this.reviews);
}

class ReviewListError extends ReviewListState {
  final String message;
  const ReviewListError(this.message);
}

// Review list notifier
class ReviewListNotifier extends StateNotifier<ReviewListState> {
  final ReviewApi _reviewApi;

  ReviewListNotifier(this._reviewApi) : super(const ReviewListLoading());

  Future<void> loadReviews(String courtId) async {
    state = const ReviewListLoading();
    try {
      final response = await _reviewApi.getReviews(courtId);
      dynamic data = response.data;
      if (data is String) data = jsonDecode(data);
      if (data is Map && data['reviews'] != null) {
        final raw = data['reviews'];
        final List<dynamic> list = raw is List ? raw : [];
        final reviews = list
            .map(
              (j) => Review.fromJson(
                j is Map<String, dynamic>
                    ? j
                    : Map<String, dynamic>.from(j as Map),
              ),
            )
            .toList();
        state = ReviewListLoaded(reviews);
      } else if (data is List) {
        final reviews = data
            .map((j) => Review.fromJson(Map<String, dynamic>.from(j as Map)))
            .toList();
        state = ReviewListLoaded(reviews);
      } else {
        state = const ReviewListLoaded([]);
      }
    } catch (e) {
      state = ReviewListError('Failed to load reviews: $e');
    }
  }
}

// Review list provider family (parameterized by courtId)
final reviewListProvider =
    StateNotifierProvider.family<ReviewListNotifier, ReviewListState, String>((
      ref,
      courtId,
    ) {
      final reviewApi = ref.watch(reviewApiProvider);
      final notifier = ReviewListNotifier(reviewApi);
      notifier.loadReviews(courtId);
      return notifier;
    });

// ── Review Creation ──

sealed class ReviewCreationState {
  const ReviewCreationState();
}

class ReviewCreationIdle extends ReviewCreationState {
  const ReviewCreationIdle();
}

class ReviewCreationSubmitting extends ReviewCreationState {
  const ReviewCreationSubmitting();
}

class ReviewCreationSuccess extends ReviewCreationState {
  final Review review;
  const ReviewCreationSuccess(this.review);
}

class ReviewCreationError extends ReviewCreationState {
  final String message;
  const ReviewCreationError(this.message);
}

class ReviewCreationNotifier extends StateNotifier<ReviewCreationState> {
  final ReviewApi _reviewApi;

  ReviewCreationNotifier(this._reviewApi) : super(const ReviewCreationIdle());

  Future<void> submitReview({
    required String courtId,
    required int rating,
    String? comment,
  }) async {
    state = const ReviewCreationSubmitting();
    try {
      final body = <String, dynamic>{
        'court_id': courtId,
        'rating': rating,
        if (comment != null && comment.isNotEmpty) 'comment': comment,
      };

      final response = await _reviewApi.createReview(body);
      dynamic data = response.data;
      if (data is String) data = jsonDecode(data);
      if (data is Map && data['review'] != null) {
        final review = Review.fromJson(
          Map<String, dynamic>.from(data['review'] as Map),
        );
        state = ReviewCreationSuccess(review);
      } else {
        state = const ReviewCreationError('Failed to submit review');
      }
    } catch (e) {
      state = ReviewCreationError('Failed to submit review: $e');
    }
  }

  void reset() {
    state = const ReviewCreationIdle();
  }
}

final reviewCreationProvider =
    StateNotifierProvider<ReviewCreationNotifier, ReviewCreationState>((ref) {
      final reviewApi = ref.watch(reviewApiProvider);
      return ReviewCreationNotifier(reviewApi);
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
      } else {
        state = const BookingDetailError('Booking not found');
      }
    } catch (e) {
      state = BookingDetailError('Failed to load booking: $e');
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
