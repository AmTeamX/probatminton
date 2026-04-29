import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/constants/api_config.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/models/court.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/court_provider.dart';
import '../../providers/payment_provider.dart';

class BookingFlowScreen extends ConsumerStatefulWidget {
  final String? courtId;
  const BookingFlowScreen({super.key, this.courtId});

  @override
  ConsumerState<BookingFlowScreen> createState() => _BookingFlowScreenState();
}

class _BookingFlowScreenState extends ConsumerState<BookingFlowScreen> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String? _selectedSlot;
  int _duration = 2;
  String _paymentMethod = 'CREDIT_CARD';
  int _rackets = 0;
  int _shuttlecocks = 2;
  int _shoes = 0;
  bool _isSubmitting = false;

  String get _courtId => widget.courtId ?? '';

  bool get _isMember {
    final authState = ref.read(authProvider);
    return authState.value is Authenticated &&
        (authState.value as Authenticated).user.isMember;
  }

  Court? get _court {
    if (_courtId.isEmpty) return null;
    final state = ref.read(courtDetailProvider(_courtId));
    return state is CourtDetailLoaded ? state.court : null;
  }

  double get _standardRate =>
      (_court?.pricePerHour ?? 0) > 0 ? _court!.pricePerHour : 200;
  double get _pricePerHour =>
      _isMember ? ApiConfig.memberHourlyRate : _standardRate;
  double get _courtCost => _pricePerHour * _duration;
  double get _equipmentCost =>
      _rackets * ApiConfig.racketPrice +
      _shuttlecocks * ApiConfig.shuttlecockPrice +
      _shoes * ApiConfig.shoesPrice;
  double get _total => _courtCost + _equipmentCost;

  /// Generate available time slots based on court opening/closing hours
  List<String> get _allSlots {
    final court = _court;
    if (court == null) {
      return [
        '08:00',
        '09:00',
        '10:00',
        '11:00',
        '12:00',
        '13:00',
        '14:00',
        '15:00',
        '16:00',
        '17:00',
        '18:00',
        '19:00',
        '20:00',
        '21:00',
      ];
    }
    // Parse opening/closing times
    final openParts = (court.openingTime ?? '08:00').split(':');
    final closeParts = (court.closingTime ?? '22:00').split(':');
    final openHour = int.tryParse(openParts.first) ?? 8;
    final closeHour = int.tryParse(closeParts.first) ?? 22;

    final slots = <String>[];
    for (int h = openHour; h < closeHour; h++) {
      slots.add('${h.toString().padLeft(2, '0')}:00');
    }
    return slots;
  }

  /// Check if a time slot is within opening hours
  bool _isWithinHours(String slot) {
    final court = _court;
    if (court == null) return true;
    final openParts = (court.openingTime ?? '08:00').split(':');
    final closeParts = (court.closingTime ?? '22:00').split(':');
    final openHour = int.tryParse(openParts.first) ?? 8;
    final closeHour = int.tryParse(closeParts.first) ?? 22;

    final slotHour = int.tryParse(slot.split(':').first) ?? 0;
    // Check slot + duration doesn't exceed closing
    return slotHour >= openHour && (slotHour + _duration) <= closeHour;
  }

  @override
  void initState() {
    super.initState();
    if (_courtId.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(courtDetailProvider(_courtId).notifier).loadCourt(_courtId);
        _loadAvailability();
      });
    }
  }

  void _loadAvailability() {
    if (_courtId.isNotEmpty) {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      ref
          .read(availabilityProvider(_courtId).notifier)
          .loadAvailability(_courtId, dateStr);
    }
  }

  /// Get set of booked slot start times from API
  Set<String> get _bookedSlots {
    if (_courtId.isEmpty) return {};
    final availState = ref.read(availabilityProvider(_courtId));
    if (availState is AvailabilityLoaded) {
      return availState.slots
          .where((s) => !s.available)
          .map((s) => s.startTime)
          .toSet();
    }
    return {};
  }

  Future<void> _submitBooking() async {
    if (_courtId.isEmpty || _selectedSlot == null || _isSubmitting) return;

    setState(() => _isSubmitting = true);

    final isoStartTime =
        '${DateFormat('yyyy-MM-dd').format(_selectedDate)}T$_selectedSlot:00Z';

    try {
      await ref
          .read(bookingCreationProvider.notifier)
          .createBooking(
            courtId: _courtId,
            startTime: isoStartTime,
            durationHours: _duration,
            paymentMethod: _paymentMethod,
            rackets: _rackets,
            shuttlecocks: _shuttlecocks,
            shoes: _shoes,
          );

      final creationState = ref.read(bookingCreationProvider);
      if (creationState is BookingCreationCreated) {
        // For CREDIT_CARD, process Stripe payment
        if (_paymentMethod == 'CREDIT_CARD') {
          await ref
              .read(paymentProvider.notifier)
              .processPayment(
                bookingId: creationState.booking.id,
                paymentMethod: _paymentMethod,
                amount: _total,
              );
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Booking confirmed! ${Formatters.currency(_total)}',
              ),
              backgroundColor: AppTheme.success,
            ),
          );
          context.go('/bookings');
        }
      } else if (creationState is BookingCreationError) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(creationState.message),
              backgroundColor: AppTheme.error,
            ),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final courtDetailState = _courtId.isNotEmpty
        ? ref.watch(courtDetailProvider(_courtId))
        : null;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Book a Court'),
        backgroundColor: AppTheme.surface,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Scrollable form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subtitle
                  const Text(
                    'Select your court, choose a time, and add equipment rentals.',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Membership banner
                  _buildMembershipBanner(),
                  const SizedBox(height: 16),

                  // Court info card
                  if (courtDetailState is CourtDetailLoaded)
                    _buildCourtCard(courtDetailState.court)
                  else if (courtDetailState is CourtDetailLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(
                          color: AppTheme.primary,
                        ),
                      ),
                    )
                  else
                    _buildNoCourtCard(),
                  const SizedBox(height: 16),

                  // Date picker
                  _buildSectionTitle('Select Date'),
                  const SizedBox(height: 8),
                  _buildCalendar(),
                  const SizedBox(height: 16),

                  // Time slot
                  _buildSectionTitle('Select Time Slot'),
                  const SizedBox(height: 8),
                  _buildTimeSlots(),
                  const SizedBox(height: 16),

                  // Duration
                  _buildSectionTitle('Duration (hours)'),
                  const SizedBox(height: 8),
                  _buildDurationPicker(),
                  const SizedBox(height: 16),

                  // Payment method
                  _buildSectionTitle('Payment Method'),
                  const SizedBox(height: 8),
                  _buildPaymentMethod(),
                  const SizedBox(height: 16),

                  // Equipment rental
                  _buildSectionTitle('Equipment Rental'),
                  const SizedBox(height: 8),
                  _buildEquipment(),
                  const SizedBox(height: 16),

                  // Pricing breakdown
                  _buildPricingBreakdown(),
                  const SizedBox(height: 80), // space for bottom button
                ],
              ),
            ),
          ),

          // Bottom submit button
          _buildSubmitButton(),
        ],
      ),
    );
  }

  // ── Membership Banner ──
  Widget _buildMembershipBanner() {
    if (_isMember) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF4CAF50)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.card_membership,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Member Rate Applied',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  Text(
                    'You get ฿150/hr instead of ฿200/hr',
                    style: TextStyle(fontSize: 12, color: Color(0xFF388E3C)),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.accentLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accent.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppTheme.accent, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 13, color: AppTheme.textPrimary),
                children: [
                  TextSpan(text: 'Standard rate applies. '),
                  TextSpan(
                    text: 'Subscribe for 199 THB/month',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                  ),
                  TextSpan(text: ' to unlock 150 THB/hour.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Court Card ──
  Widget _buildCourtCard(Court court) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: court.imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      court.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.sports_tennis,
                        color: AppTheme.primary,
                      ),
                    ),
                  )
                : const Icon(
                    Icons.sports_tennis,
                    color: AppTheme.primary,
                    size: 24,
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  court.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  court.location,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Colors.amber),
                    const SizedBox(width: 2),
                    Text(
                      '${court.avgRating ?? 0}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${Formatters.currency(court.pricePerHour)}/hr',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.accent,
                        fontSize: 13,
                      ),
                    ),
                    if (court.openingTime != null) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: AppTheme.textDisabled,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${court.openingTime!.substring(0, 5)}-${court.closingTime!.substring(0, 5)}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textDisabled,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          // Standard badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariant,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'Standard',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoCourtCard() {
    return GestureDetector(
      onTap: () => context.go('/home'),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppTheme.dividerColor,
            style: BorderStyle.solid,
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, color: AppTheme.primary),
            SizedBox(width: 8),
            Text(
              'Select a Court from Home',
              style: TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Section Title ──
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
    );
  }

  // ── Calendar ──
  Widget _buildCalendar() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TableCalendar(
        firstDay: DateTime.now(),
        lastDay: DateTime.now().add(const Duration(days: 90)),
        focusedDay: _selectedDate,
        selectedDayPredicate: (d) => isSameDay(_selectedDate, d),
        onDaySelected: (s, _) {
          setState(() {
            _selectedDate = s;
            _selectedSlot = null;
          });
          _loadAvailability();
        },
        calendarStyle: const CalendarStyle(
          selectedDecoration: BoxDecoration(
            color: AppTheme.primary,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: AppTheme.accent,
            shape: BoxShape.circle,
          ),
        ),
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
        ),
      ),
    );
  }

  // ── Time Slots ──
  Widget _buildTimeSlots() {
    final availState = _courtId.isNotEmpty
        ? ref.watch(availabilityProvider(_courtId))
        : null;
    final bookedSet = _bookedSlots;
    final slots = _allSlots;

    if (slots.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Text(
          'No time slots available for this court',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: slots.map((slot) {
            final isSelected = _selectedSlot == slot;
            final isBooked = bookedSet.contains(slot);
            final isClosed = !_isWithinHours(slot);
            final isDisabled = isBooked || isClosed;

            Color bg, border, text;
            if (isSelected) {
              bg = AppTheme.primary;
              border = AppTheme.primary;
              text = Colors.white;
            } else if (isClosed) {
              bg = const Color(0xFFF5F5F5);
              border = const Color(0xFFBDBDBD);
              text = const Color(0xFF9E9E9E);
            } else if (isBooked) {
              bg = const Color(0xFFFFEBEE);
              border = const Color(0xFFC62828);
              text = const Color(0xFFC62828);
            } else {
              bg = const Color(0xFFE8F5E9);
              border = const Color(0xFF2E7D32);
              text = const Color(0xFF2E7D32);
            }

            return GestureDetector(
              onTap: isDisabled
                  ? null
                  : () => setState(() {
                      _selectedSlot = slot;
                      // Adjust duration if it exceeds closing time
                      if (!_isWithinHours(slot)) {
                        final court = _court;
                        if (court?.closingTime != null) {
                          final closeHour =
                              int.tryParse(
                                court!.closingTime!.split(':').first,
                              ) ??
                              22;
                          final slotHour =
                              int.tryParse(slot.split(':').first) ?? 0;
                          final maxDuration = closeHour - slotHour;
                          if (_duration > maxDuration) {
                            _duration = maxDuration > 0 ? maxDuration : 1;
                          }
                        }
                      }
                    }),
              child: Container(
                width: 76,
                height: 42,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: border),
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      slot,
                      style: TextStyle(
                        color: text,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        decoration: isBooked
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    if (isClosed)
                      const Text(
                        'Closed',
                        style: TextStyle(fontSize: 8, color: Color(0xFF9E9E9E)),
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        if (availState is AvailabilityLoading)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppTheme.primary,
              ),
            ),
          ),
        const SizedBox(height: 8),
        Row(
          children: [
            _legendBox(
              const Color(0xFFE8F5E9),
              const Color(0xFF2E7D32),
              'Available',
            ),
            const SizedBox(width: 12),
            _legendBox(
              const Color(0xFFFFEBEE),
              const Color(0xFFC62828),
              'Booked',
            ),
            const SizedBox(width: 12),
            _legendBox(
              const Color(0xFFF5F5F5),
              const Color(0xFFBDBDBD),
              'Closed',
            ),
          ],
        ),
      ],
    );
  }

  Widget _legendBox(Color bg, Color border, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: border),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 11, color: border)),
      ],
    );
  }

  // ── Duration Picker ──
  Widget _buildDurationPicker() {
    // Calculate max duration based on selected slot and closing time
    int maxDuration = 4;
    if (_selectedSlot != null &&
        _court != null &&
        _court!.closingTime != null) {
      final closeHour =
          int.tryParse(_court!.closingTime!.split(':').first) ?? 22;
      final slotHour = int.tryParse(_selectedSlot!.split(':').first) ?? 0;
      maxDuration = (closeHour - slotHour).clamp(1, 4);
    }

    return Row(
      children: List.generate(maxDuration, (i) {
        final h = i + 1;
        final sel = _duration == h;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            label: Text('${h}h'),
            selected: sel,
            onSelected: (_) => setState(() => _duration = h),
            selectedColor: AppTheme.primaryLight,
          ),
        );
      }),
    );
  }

  // ── Payment Method ──
  Widget _buildPaymentMethod() {
    final methods = [
      ('CREDIT_CARD', '💳', 'Credit Card', 'Stripe (Google Pay, Apple Pay)'),
      ('BANK_TRANSFER', '🏦', 'Bank Transfer', 'Transfer to our account'),
      ('PROMPTPAY', '📱', 'PromptPay', 'Scan QR to pay'),
    ];

    return Column(
      children: [
        ...methods.map((m) {
          final sel = _paymentMethod == m.$1;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () => setState(() => _paymentMethod = m.$1),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: sel ? AppTheme.primaryLight : AppTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: sel ? AppTheme.primary : AppTheme.dividerColor,
                    width: sel ? 1.5 : 0.5,
                  ),
                ),
                child: Row(
                  children: [
                    Text(m.$2, style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            m.$3,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: sel ? AppTheme.primary : null,
                            ),
                          ),
                          Text(
                            m.$4,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: sel ? AppTheme.primary : Colors.transparent,
                        border: Border.all(
                          color: sel ? AppTheme.primary : AppTheme.dividerColor,
                          width: 2,
                        ),
                      ),
                      child: sel
                          ? const Icon(
                              Icons.check,
                              size: 14,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        if (_paymentMethod == 'CREDIT_CARD')
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.open_in_new,
                  size: 14,
                  color: Color(0xFF1565C0),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'You will be redirected to securely complete your payment with Stripe (Google Pay, Apple Pay, saved cards, or add a new card).',
                    style: TextStyle(
                      fontSize: 11,
                      color: const Color(0xFF1565C0),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ── Equipment Rental ──
  Widget _buildEquipment() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          _equipmentRow(
            '🏸',
            'Racket',
            ApiConfig.racketPrice,
            _rackets,
            (v) => setState(() => _rackets = v),
          ),
          const Divider(height: 20),
          _equipmentRow(
            '🪶',
            'Shuttlecock',
            ApiConfig.shuttlecockPrice,
            _shuttlecocks,
            (v) => setState(() => _shuttlecocks = v),
          ),
          const Divider(height: 20),
          _equipmentRow(
            '👟',
            'Shoes',
            ApiConfig.shoesPrice,
            _shoes,
            (v) => setState(() => _shoes = v),
          ),
        ],
      ),
    );
  }

  Widget _equipmentRow(
    String emoji,
    String name,
    double price,
    int count,
    Function(int) onChanged,
  ) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Text(
                '${Formatters.currency(price)} each',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            _circleBtn(
              Icons.remove,
              () => onChanged(count > 0 ? count - 1 : 0),
              count > 0,
            ),
            SizedBox(
              width: 36,
              child: Text(
                '$count',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            _circleBtn(Icons.add, () => onChanged(count + 1), true),
          ],
        ),
      ],
    );
  }

  Widget _circleBtn(IconData icon, VoidCallback onTap, bool active) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active ? AppTheme.primary : AppTheme.surfaceVariant,
          border: active ? null : Border.all(color: AppTheme.dividerColor),
        ),
        child: Icon(
          icon,
          size: 16,
          color: active ? Colors.white : AppTheme.textDisabled,
        ),
      ),
    );
  }

  // ── Pricing Breakdown ──
  Widget _buildPricingBreakdown() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rate applied
          _priceRow(
            'Rate Applied',
            _isMember
                ? 'Member rate: ฿${ApiConfig.memberHourlyRate.toInt()}/hr'
                : 'Standard rate: ฿${_standardRate.toInt()}/hr',
            valueColor: _isMember ? const Color(0xFF2E7D32) : null,
            isBold: false,
          ),
          const SizedBox(height: 10),
          _priceRow('Court Fee', Formatters.currency(_courtCost)),
          const SizedBox(height: 10),
          _priceRow('Equipment', Formatters.currency(_equipmentCost)),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                '฿${_total.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: AppTheme.accent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _priceRow(
    String label,
    String value, {
    Color? valueColor,
    bool isBold = true,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
            color: AppTheme.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
            color: valueColor ?? AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  // ── Submit Button ──
  Widget _buildSubmitButton() {
    final canSubmit =
        _courtId.isNotEmpty &&
        _selectedSlot != null &&
        _isWithinHours(_selectedSlot ?? '') &&
        !_isSubmitting;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 52,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: canSubmit ? _submitBooking : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              disabledBackgroundColor: AppTheme.textDisabled,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : Text(
                    _selectedSlot == null
                        ? 'Select a time slot'
                        : 'Book ${Formatters.currency(_total)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

// Keep RadioGroup widget for compatibility
class RadioGroup<T> extends StatelessWidget {
  final T groupValue;
  final ValueChanged<T?> onChanged;
  final Widget child;
  const RadioGroup({
    super.key,
    required this.groupValue,
    required this.onChanged,
    required this.child,
  });

  static InheritedRadioGroup<T>? maybeOf<T>(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<InheritedRadioGroup<T>>();
  }

  @override
  Widget build(BuildContext context) {
    return InheritedRadioGroup<T>(
      groupValue: groupValue,
      onChanged: onChanged,
      child: child,
    );
  }
}

class InheritedRadioGroup<T> extends InheritedWidget {
  final T groupValue;
  final ValueChanged<T?> onChanged;
  const InheritedRadioGroup({
    super.key,
    required this.groupValue,
    required this.onChanged,
    required super.child,
  });

  @override
  bool updateShouldNotify(InheritedRadioGroup<T> oldWidget) {
    return groupValue != oldWidget.groupValue;
  }
}
