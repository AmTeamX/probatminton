import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../providers/waitlist_provider.dart';
import '../../widgets/empty_state.dart';

class WaitlistScreen extends ConsumerWidget {
  const WaitlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(waitlistListProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('My Waitlist'),
        backgroundColor: AppTheme.surface,
        elevation: 0,
      ),
      body: switch (state) {
        WaitlistListLoading() => const Center(
          child: CircularProgressIndicator(),
        ),
        WaitlistListError(:final message) => Center(
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
                    ref.read(waitlistListProvider.notifier).loadWaitlist(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        WaitlistListLoaded(:final entries) =>
          entries.isEmpty
              ? const EmptyState(
                  icon: Icons.schedule_outlined,
                  title: 'No Waitlist Entries',
                  subtitle:
                      'When a court is fully booked, you can join the waitlist to get notified when a slot opens up.',
                )
              : RefreshIndicator(
                  onRefresh: () =>
                      ref.read(waitlistListProvider.notifier).loadWaitlist(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: entries.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      return _WaitlistCard(
                        entry: entry,
                        onLeave: () => _leaveWaitlist(context, ref, entry.id),
                      );
                    },
                  ),
                ),
      },
    );
  }

  Future<void> _leaveWaitlist(
    BuildContext context,
    WidgetRef ref,
    String entryId,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave Waitlist?'),
        content: const Text(
          'You will lose your position in the waitlist. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Leave', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final success = await ref
          .read(waitlistListProvider.notifier)
          .leaveWaitlist(entryId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Left waitlist successfully'
                  : 'Failed to leave waitlist',
            ),
            backgroundColor: success ? AppTheme.success : AppTheme.error,
          ),
        );
      }
    }
  }
}

class _WaitlistCard extends StatelessWidget {
  final dynamic entry;
  final VoidCallback onLeave;

  const _WaitlistCard({required this.entry, required this.onLeave});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    entry.courtName ?? 'Court',
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
                    color: entry.status == 'notified'
                        ? const Color(0xFFE8F5E9)
                        : entry.status == 'expired'
                        ? const Color(0xFFFFEBEE)
                        : const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _statusLabel(entry.status),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: entry.status == 'notified'
                          ? AppTheme.success
                          : entry.status == 'expired'
                          ? AppTheme.error
                          : Colors.orange.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  Formatters.date(
                    DateTime.tryParse(entry.date) ?? DateTime.now(),
                  ),
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
                  '${Formatters.time(entry.startTime)} - ${Formatters.time(entry.endTime)}',
                  style: const TextStyle(color: AppTheme.textSecondary),
                ),
              ],
            ),
            if (entry.position != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.people_outline,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Position: #${entry.position}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (entry.status != 'expired')
                  TextButton.icon(
                    onPressed: onLeave,
                    icon: const Icon(Icons.exit_to_app, size: 18),
                    label: const Text('Leave Waitlist'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.error,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _statusLabel(String? status) {
    return switch (status) {
      'notified' => 'Notified',
      'expired' => 'Expired',
      _ => 'Waiting',
    };
  }
}
