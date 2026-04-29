import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/models/booking.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/empty_state.dart';

class ManageBookingsScreen extends ConsumerWidget {
  const ManageBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(manageBookingsProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('All Bookings'),
        backgroundColor: AppTheme.surface,
        elevation: 0,
      ),
      body: switch (state) {
        ManageBookingsLoading() => const Center(
          child: CircularProgressIndicator(),
        ),
        ManageBookingsError(:final message) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppTheme.error),
              const SizedBox(height: 12),
              Text(
                message,
                style: const TextStyle(color: AppTheme.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () =>
                    ref.read(manageBookingsProvider.notifier).loadBookings(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        ManageBookingsLoaded(:final bookings) =>
          bookings.isEmpty
              ? const EmptyState(
                  icon: Icons.calendar_today,
                  title: 'No Bookings',
                  subtitle: 'No bookings have been made yet.',
                )
              : RefreshIndicator(
                  onRefresh: () =>
                      ref.read(manageBookingsProvider.notifier).loadBookings(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: bookings.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) =>
                        _BookingCard(booking: bookings[index]),
                  ),
                ),
      },
    );
  }
}

class _BookingCard extends ConsumerWidget {
  final Booking booking;
  const _BookingCard({required this.booking});

  Color _statusColor(String status) {
    switch (status) {
      case 'confirmed':
        return AppTheme.success;
      case 'pending':
        return AppTheme.warning;
      case 'completed':
        return AppTheme.primary;
      case 'cancelled':
        return AppTheme.error;
      default:
        return AppTheme.textDisabled;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusColor = _statusColor(booking.status);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    booking.courtName ?? 'Court',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    booking.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  booking.bookingDate,
                  style: const TextStyle(color: AppTheme.textSecondary),
                ),
                const SizedBox(width: 16),
                const Icon(
                  Icons.access_time,
                  size: 16,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  '${Formatters.time(booking.startTime)} - ${Formatters.time(booking.endTime)}',
                  style: const TextStyle(color: AppTheme.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  Formatters.currency(booking.totalPrice),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
                const Spacer(),
                if (booking.status == 'pending' ||
                    booking.status == 'confirmed') ...[
                  TextButton(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Cancel Booking?'),
                          content: const Text(
                            'Are you sure you want to cancel this booking?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('No'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text(
                                'Cancel Booking',
                                style: TextStyle(color: AppTheme.error),
                              ),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true && context.mounted) {
                        final success = await ref
                            .read(manageBookingsProvider.notifier)
                            .cancelBooking(booking.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                success
                                    ? 'Booking cancelled'
                                    : 'Failed to cancel',
                              ),
                              backgroundColor: success
                                  ? AppTheme.success
                                  : AppTheme.error,
                            ),
                          );
                        }
                      }
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.error,
                    ),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 4),
                ],
                if (booking.status == 'pending')
                  ElevatedButton(
                    onPressed: () async {
                      final success = await ref
                          .read(manageBookingsProvider.notifier)
                          .updateStatus(booking.id, 'confirmed');
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              success
                                  ? 'Booking confirmed'
                                  : 'Failed to confirm',
                            ),
                            backgroundColor: success
                                ? AppTheme.success
                                : AppTheme.error,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      minimumSize: const Size(0, 32),
                    ),
                    child: const Text('Confirm'),
                  ),
                if (booking.status == 'confirmed')
                  ElevatedButton(
                    onPressed: () async {
                      final success = await ref
                          .read(manageBookingsProvider.notifier)
                          .updateStatus(booking.id, 'completed');
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              success
                                  ? 'Marked as completed'
                                  : 'Failed to update',
                            ),
                            backgroundColor: success
                                ? AppTheme.success
                                : AppTheme.error,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      minimumSize: const Size(0, 32),
                    ),
                    child: const Text('Complete'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
