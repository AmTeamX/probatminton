import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../domain/models/booking.dart';
import 'status_badge.dart';

class BookingCard extends StatelessWidget {
  final Booking booking;
  const BookingCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/booking/${booking.id}'),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StatusBadge(status: booking.status),
                  Text(
                    Formatters.currency(booking.totalPrice),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _infoRow(Icons.sports_tennis, booking.courtName ?? 'Court'),
              const SizedBox(height: 6),
              _infoRow(Icons.calendar_today_outlined, booking.bookingDate),
              const SizedBox(height: 6),
              _infoRow(
                Icons.access_time,
                '${booking.startTime} - ${booking.endTime} (${booking.durationHours}h)',
              ),
              if (booking.equipmentRentals != null &&
                  (booking.equipmentRentals!.rackets > 0 ||
                      booking.equipmentRentals!.shuttlecocks > 0 ||
                      booking.equipmentRentals!.shoes > 0))
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: _infoRow(
                    Icons.sports,
                    _equipmentSummary(booking.equipmentRentals!),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppTheme.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _equipmentSummary(EquipmentRentals eq) {
    final parts = <String>[];
    if (eq.rackets > 0) parts.add('${eq.rackets}R');
    if (eq.shuttlecocks > 0) parts.add('${eq.shuttlecocks}S');
    if (eq.shoes > 0) parts.add('${eq.shoes}Sh');
    return 'Equipment: ${parts.join(", ")}';
  }
}
