import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../providers/admin_provider.dart';

class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsState = ref.watch(adminStatsProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(adminStatsProvider.notifier).loadStats(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => context.pop(),
                    ),
                    const Text(
                      'Admin Dashboard',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.admin_panel_settings, color: AppTheme.accent),
                  ],
                ),
                const SizedBox(height: 16),

                // Stats grid
                switch (statsState) {
                  AdminStatsLoading() => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  AdminStatsError(:final message) => Center(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: AppTheme.error,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          message,
                          style: const TextStyle(color: AppTheme.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton(
                          onPressed: () =>
                              ref.read(adminStatsProvider.notifier).loadStats(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                  AdminStatsLoaded(
                    :final totalCourts,
                    :final totalBookings,
                    :final totalUsers,
                    :final revenue,
                  ) =>
                    Column(
                      children: [
                        Row(
                          children: [
                            _statCard(
                              Icons.sports_tennis,
                              '$totalCourts',
                              'Courts',
                            ),
                            const SizedBox(width: 12),
                            _statCard(
                              Icons.calendar_today,
                              '$totalBookings',
                              'Bookings',
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _statCard(Icons.people, '$totalUsers', 'Users'),
                            const SizedBox(width: 12),
                            _statCard(
                              Icons.attach_money,
                              Formatters.currency(revenue),
                              'Revenue',
                            ),
                          ],
                        ),
                      ],
                    ),
                },

                const SizedBox(height: 24),

                // Quick Actions
                const Text(
                  'Quick Actions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Column(
                    children: [
                      _actionItem(
                        Icons.sports_tennis,
                        'Manage Courts',
                        () => context.push('/admin/courts'),
                      ),
                      const Divider(indent: 16, endIndent: 16),
                      _actionItem(
                        Icons.calendar_today_outlined,
                        'All Bookings',
                        () => context.push('/admin/bookings'),
                      ),
                      const Divider(indent: 16, endIndent: 16),
                      _actionItem(
                        Icons.forum_outlined,
                        'Community Posts',
                        () => context.push('/admin/community'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statCard(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.dividerColor),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: AppTheme.accent),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.accent,
              ),
            ),
            Text(
              label,
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

  Widget _actionItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.textPrimary),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, color: AppTheme.textDisabled),
      onTap: onTap,
    );
  }
}
