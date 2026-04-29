import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/models/booking.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/status_badge.dart';

class BookingDetailScreen extends ConsumerStatefulWidget {
  final String bookingId;
  const BookingDetailScreen({super.key, required this.bookingId});

  @override
  ConsumerState<BookingDetailScreen> createState() =>
      _BookingDetailScreenState();
}

class _BookingDetailScreenState extends ConsumerState<BookingDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Ensure the list is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final listState = ref.read(bookingListProvider);
      if (listState is! BookingListLoaded) {
        ref.read(bookingListProvider.notifier).loadBookings();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final listState = ref.watch(bookingListProvider);
    Booking? booking;
    if (listState is BookingListLoaded) {
      try {
        booking = listState.bookings.firstWhere(
          (b) => b.id == widget.bookingId,
        );
      } catch (_) {}
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Booking Details'),
        backgroundColor: AppTheme.surface,
        elevation: 0,
      ),
      body: () {
        if (listState is BookingListLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primary),
          );
        }
        if (booking == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: AppTheme.error,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Booking not found',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => context.go('/bookings'),
                  child: const Text('Back to Bookings'),
                ),
              ],
            ),
          );
        }
        return _buildContent(booking);
      }(),
    );
  }

  Widget _buildContent(Booking booking) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Booking #${booking.id.length > 8 ? booking.id.substring(0, 8) : booking.id}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      StatusBadge(status: booking.status),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _detailRow(
                    Icons.sports_tennis,
                    'Court',
                    booking.courtName ?? 'Court',
                  ),
                  _detailRow(
                    Icons.calendar_today,
                    'Date',
                    Formatters.date(
                      DateTime.tryParse(booking.bookingDate) ?? DateTime.now(),
                    ),
                  ),
                  _detailRow(
                    Icons.access_time,
                    'Time',
                    '${Formatters.time(booking.startTime)} - ${Formatters.time(booking.endTime)}',
                  ),
                  _detailRow(
                    Icons.hourglass_bottom,
                    'Duration',
                    '${booking.durationHours} hour(s)',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Equipment card
          if (booking.equipmentRentals != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Equipment',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (booking.equipmentRentals!.rackets > 0)
                      _equipmentRow(
                        '🏸 Rackets',
                        '× ${booking.equipmentRentals!.rackets}',
                      ),
                    if (booking.equipmentRentals!.shuttlecocks > 0)
                      _equipmentRow(
                        '🪶 Shuttlecocks',
                        '× ${booking.equipmentRentals!.shuttlecocks}',
                      ),
                    if (booking.equipmentRentals!.shoes > 0)
                      _equipmentRow(
                        '👟 Shoes',
                        '× ${booking.equipmentRentals!.shoes}',
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          // Payment card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Payment',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  if (booking.paymentMethod != null)
                    _detailRow(Icons.payment, 'Method', booking.paymentMethod!),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Amount'),
                      Text(
                        Formatters.currency(booking.totalPrice),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppTheme.accent,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Created at
          Center(
            child: Text(
              'Booked on ${Formatters.dateTime(booking.createdAt)}',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Action buttons
          if (booking.isUpcoming) ...[
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () => context.push('/review/${booking.courtId}'),
                child: const Text('Leave a Review'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () => _cancelBooking(context, booking),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.error,
                  side: const BorderSide(color: AppTheme.error),
                ),
                child: const Text('Cancel Booking'),
              ),
            ),
          ],
          if (booking.isCompleted) ...[
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => context.push('/review/${booking.courtId}'),
                child: const Text('Leave a Review'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.textSecondary),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: AppTheme.textSecondary)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _equipmentRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Future<void> _cancelBooking(BuildContext context, Booking booking) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Booking?'),
        content: const Text(
          'Are you sure you want to cancel this booking? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Yes, Cancel',
              style: TextStyle(color: AppTheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final success = await ref
          .read(bookingListProvider.notifier)
          .cancelBooking(booking.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Booking cancelled' : 'Failed to cancel'),
            backgroundColor: success ? AppTheme.success : AppTheme.error,
          ),
        );
        if (success) {
          context.go('/bookings');
        }
      }
    }
  }
}
