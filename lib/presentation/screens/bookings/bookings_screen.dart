import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/constants/app_theme.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/booking_card.dart';
import '../../widgets/empty_state.dart';

class BookingsScreen extends ConsumerStatefulWidget {
  const BookingsScreen({super.key});

  @override
  ConsumerState<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends ConsumerState<BookingsScreen> {
  int _selectedTab = 0;
  final _tabs = ['Upcoming', 'Completed', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bookingListProvider.notifier).loadBookings();
    });
  }

  List<dynamic> _filterByTab(List<dynamic> bookings) {
    switch (_selectedTab) {
      case 0:
        return bookings.where((b) => b.isUpcoming).toList();
      case 1:
        return bookings.where((b) => b.isCompleted).toList();
      case 2:
        return bookings.where((b) => b.isCancelled).toList();
      default:
        return bookings;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(bookingListProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Text(
                'My Bookings',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            // Tab bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: List.generate(
                    _tabs.length,
                    (i) => Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTab = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: _selectedTab == i
                                ? AppTheme.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _tabs[i],
                            style: TextStyle(
                              color: _selectedTab == i
                                  ? Colors.white
                                  : AppTheme.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Bookings list
            Expanded(
              child: switch (bookingState) {
                BookingListLoading() => _buildShimmerList(),
                BookingListLoaded(:final bookings) => _buildBookingsList(
                  _filterByTab(bookings),
                ),
                BookingListError(:final message) => EmptyState(
                  icon: Icons.error_outline,
                  title: 'Failed to load bookings',
                  subtitle: message,
                  actionLabel: 'Retry',
                  onAction: () =>
                      ref.read(bookingListProvider.notifier).loadBookings(),
                ),
                _ => EmptyState(
                  icon: Icons.calendar_today_outlined,
                  title: 'No bookings yet',
                  subtitle: 'Book a court to get started!',
                  actionLabel: 'Refresh',
                  onAction: () =>
                      ref.read(bookingListProvider.notifier).loadBookings(),
                ),
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
      itemCount: 3,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, _) => Shimmer.fromColors(
        baseColor: AppTheme.surfaceVariant,
        highlightColor: AppTheme.dividerColor,
        child: Card(
          child: Container(
            height: 140,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 80,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    Container(
                      width: 60,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 200,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 160,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookingsList(List bookings) {
    if (bookings.isEmpty) {
      return EmptyState(
        icon: Icons.calendar_today_outlined,
        title: 'No ${_tabs[_selectedTab].toLowerCase()} bookings',
        subtitle:
            'Your ${_tabs[_selectedTab].toLowerCase()} bookings will appear here.',
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(bookingListProvider.notifier).loadBookings(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
        itemCount: bookings.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) => Dismissible(
          key: ValueKey(bookings[index].id),
          direction: _selectedTab == 0
              ? DismissDirection.endToStart
              : DismissDirection.none,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: AppTheme.error,
              borderRadius: BorderRadius.circular(AppTheme.radiusCard),
            ),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          confirmDismiss: (_) async {
            return await showDialog(
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
                      'Yes',
                      style: TextStyle(color: AppTheme.error),
                    ),
                  ),
                ],
              ),
            );
          },
          onDismissed: (_) async {
            final success = await ref
                .read(bookingListProvider.notifier)
                .cancelBooking(bookings[index].id);
            if (!context.mounted) return;
            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Booking cancelled')),
              );
            }
          },
          child: BookingCard(booking: bookings[index]),
        ),
      ),
    );
  }
}
