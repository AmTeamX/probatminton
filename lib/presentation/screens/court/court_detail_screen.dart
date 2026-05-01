import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/constants/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../providers/court_provider.dart';
import '../../providers/review_provider.dart';
import '../../providers/waitlist_provider.dart';

class CourtDetailScreen extends ConsumerWidget {
  final String courtId;
  const CourtDetailScreen({super.key, required this.courtId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courtState = ref.watch(courtDetailProvider(courtId));
    final reviewState = ref.watch(reviewListProvider(courtId));

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: switch (courtState) {
        CourtDetailLoading() => _buildLoadingBody(context),
        CourtDetailError(:final message) => _buildErrorBody(
          context,
          ref,
          message,
        ),
        CourtDetailLoaded(:final court) => _buildLoadedBody(
          context,
          ref,
          court: court,
          reviewState: reviewState,
        ),
      },
      bottomNavigationBar: switch (courtState) {
        CourtDetailLoaded(:final court) => Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accent,
                      ),
                      onPressed: () => context.push('/book?courtId=$courtId'),
                      child: Text(
                        'Book Now — ${Formatters.currency(court.pricePerHour)}/hr',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: Consumer(
                      builder: (context, ref, _) {
                        final wlState = ref.watch(joinWaitlistProvider);
                        return OutlinedButton(
                          onPressed: wlState is JoinWaitlistJoining
                              ? null
                              : () => _joinWaitlist(context, ref),
                          child: wlState is JoinWaitlistJoining
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Waitlist'),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        _ => null,
      },
    );
  }

  Widget _buildLoadingBody(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero placeholder
          Container(
            width: double.infinity,
            height: 200,
            color: AppTheme.surfaceVariant,
            child: const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Shimmer.fromColors(
              baseColor: AppTheme.surfaceVariant,
              highlightColor: AppTheme.dividerColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 24, width: 200, color: Colors.white),
                  const SizedBox(height: 8),
                  Container(height: 14, width: 250, color: Colors.white),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Container(height: 60, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(height: 60, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(height: 60, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(height: 18, width: 80, color: Colors.white),
                  const SizedBox(height: 8),
                  Container(
                    height: 14,
                    width: double.infinity,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 14,
                    width: double.infinity,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBody(BuildContext context, WidgetRef ref, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppTheme.error),
          const SizedBox(height: 16),
          const Text(
            'Failed to load court',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => ref
                .read(courtDetailProvider(courtId).notifier)
                .loadCourt(courtId),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedBody(
    BuildContext context,
    WidgetRef ref, {
    required dynamic court,
    required ReviewListState reviewState,
  }) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Image
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.primary, AppTheme.primaryDark],
                  ),
                  image: court.imageUrl != null
                      ? DecorationImage(
                          image: NetworkImage(court.imageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: court.imageUrl == null
                    ? const Center(
                        child: Icon(
                          Icons.sports_tennis,
                          size: 64,
                          color: Colors.white54,
                        ),
                      )
                    : null,
              ),
              // Back & Share buttons
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => context.pop(),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black26,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.favorite_border,
                              color: Colors.white,
                            ),
                            onPressed: () {},
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.black26,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.share, color: Colors.white),
                            onPressed: () {},
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.black26,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title & Rating
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        court.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        ...List.generate(
                          5,
                          (i) => Icon(
                            Icons.star,
                            size: 20,
                            color: i < (court.avgRating ?? 0).floor()
                                ? Colors.amber
                                : const Color(0xFFE0E0E0),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${court.avgRating ?? 0}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 14,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      court.location,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Info Cards
                Row(
                  children: [
                    _infoCard(
                      Formatters.currency(court.pricePerHour),
                      'Per Hour',
                      AppTheme.accent,
                    ),
                    const SizedBox(width: 12),
                    _infoCard(
                      court.distanceKm != null
                          ? Formatters.distance(court.distanceKm!)
                          : '--',
                      'Distance',
                      AppTheme.primary,
                    ),
                    const SizedBox(width: 12),
                    _infoCard(
                      '${court.reviewCount ?? 0}',
                      'Reviews',
                      AppTheme.info,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // About
                const Text(
                  'About',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  court.description ?? 'No description available.',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),

                // Mini Map
                if (court.latitude != null && court.longitude != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      height: 150,
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(court.latitude!, court.longitude!),
                          zoom: 15,
                        ),
                        markers: {
                          Marker(
                            markerId: MarkerId(court.id),
                            position: LatLng(court.latitude!, court.longitude!),
                            infoWindow: InfoWindow(title: court.name),
                          ),
                        },
                        zoomControlsEnabled: false,
                        scrollGesturesEnabled: false,
                        tiltGesturesEnabled: false,
                        rotateGesturesEnabled: false,
                        myLocationButtonEnabled: false,
                        mapToolbarEnabled: false,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ] else ...[
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8E8E8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.map,
                            size: 32,
                            color: AppTheme.textDisabled,
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Court Location',
                            style: TextStyle(color: AppTheme.textDisabled),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Reviews
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Reviews (${court.reviewCount ?? 0})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/review/$courtId'),
                      child: const Row(
                        children: [
                          Icon(Icons.edit, size: 16),
                          SizedBox(width: 4),
                          Text('Write a Review'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Reviews list based on state
                switch (reviewState) {
                  ReviewListLoading() => _buildReviewsShimmer(),
                  ReviewListLoaded(:final reviews) =>
                    reviews.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: Text(
                                'No reviews yet. Be the first!',
                                style: TextStyle(color: AppTheme.textSecondary),
                              ),
                            ),
                          )
                        : Column(
                            children: reviews
                                .map(
                                  (r) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _reviewCard(r),
                                  ),
                                )
                                .toList(),
                          ),
                  ReviewListError() => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'Could not load reviews',
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                    ),
                  ),
                },

                // Extra bottom padding for sticky bar
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsShimmer() {
    return Column(
      children: List.generate(
        2,
        (_) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Shimmer.fromColors(
            baseColor: AppTheme.surfaceVariant,
            highlightColor: AppTheme.dividerColor,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(height: 14, width: 100, color: Colors.white),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 12,
                    width: double.infinity,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoCard(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.dividerColor),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _reviewCard(dynamic review) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppTheme.primaryLight,
                  child: Text(
                    review.userName?[0] ?? '?',
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    review.userName ?? 'User',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  _timeAgo(review.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                ...List.generate(
                  5,
                  (i) => Icon(
                    Icons.star,
                    size: 14,
                    color: i < review.rating
                        ? Colors.amber
                        : const Color(0xFFE0E0E0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              review.comment ?? '',
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _joinWaitlist(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _JoinWaitlistSheet(courtId: courtId),
    );
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return 'Just now';
  }
}

class _JoinWaitlistSheet extends ConsumerStatefulWidget {
  final String courtId;
  const _JoinWaitlistSheet({required this.courtId});

  @override
  ConsumerState<_JoinWaitlistSheet> createState() => _JoinWaitlistSheetState();
}

class _JoinWaitlistSheetState extends ConsumerState<_JoinWaitlistSheet> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  final _startTime = TextEditingController(text: '09:00');
  final _endTime = TextEditingController(text: '10:00');

  @override
  void dispose() {
    _startTime.dispose();
    _endTime.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(joinWaitlistProvider);

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Join Waitlist',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'You\'ll be notified when a slot becomes available.',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 20),

          // Date picker
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calendar_today),
            title: Text(
              'Date: ${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: _pickDate,
          ),
          const SizedBox(height: 8),

          // Time inputs
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _startTime,
                  decoration: const InputDecoration(
                    labelText: 'Start Time',
                    hintText: '09:00',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _endTime,
                  decoration: const InputDecoration(
                    labelText: 'End Time',
                    hintText: '10:00',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Error
          if (state is JoinWaitlistError)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 20,
                    color: AppTheme.error,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      state.message,
                      style: const TextStyle(
                        color: AppTheme.error,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Submit
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: state is JoinWaitlistJoining ? null : _submit,
              child: state is JoinWaitlistJoining
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : const Text('Join Waitlist'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _submit() async {
    final dateStr =
        '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

    final timeSlot = '${_startTime.text.trim()}-${_endTime.text.trim()}';

    await ref
        .read(joinWaitlistProvider.notifier)
        .joinWaitlist(
          courtId: widget.courtId,
          requestedDate: dateStr,
          preferredTimeSlot: timeSlot,
        );

    final state = ref.read(joinWaitlistProvider);
    if (state is JoinWaitlistSuccess && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Added to waitlist!'),
          backgroundColor: AppTheme.success,
        ),
      );
    }
  }
}
