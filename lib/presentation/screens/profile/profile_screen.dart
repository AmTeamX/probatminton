import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_theme.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.value is Authenticated
        ? (authState.value as Authenticated).user
        : null;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with gradient
            Container(
              width: double.infinity,
              height: 180,
              decoration: const BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppTheme.primary, AppTheme.primaryDark],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.sports_tennis,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Pro Badminton',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Avatar overlapping header
            Transform.translate(
              offset: const Offset(0, -32),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppTheme.surface,
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: AppTheme.primaryLight,
                      child: Text(
                        user?.fullName.isNotEmpty == true
                            ? user!.fullName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user?.fullName ?? 'User',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    user?.email ?? '',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  if (user?.isMember == true) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.emoji_events,
                            size: 16,
                            color: AppTheme.primary,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Member',
                            style: TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Menu items
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Card(
                child: Column(
                  children: [
                    _menuItem(
                      Icons.person_outline,
                      'Edit Profile',
                      onTap: () => context.push('/edit-profile'),
                    ),
                    const Divider(indent: 16, endIndent: 16),
                    _menuItem(
                      Icons.card_membership,
                      'Membership',
                      onTap: () => context.push('/membership'),
                    ),
                    const Divider(indent: 16, endIndent: 16),
                    _menuItem(
                      Icons.access_time,
                      'My Waitlists',
                      onTap: () => context.push('/waitlist'),
                    ),
                    const Divider(indent: 16, endIndent: 16),
                    _menuItem(
                      Icons.forum_outlined,
                      'Community',
                      onTap: () => context.push('/community'),
                    ),
                    const Divider(indent: 16, endIndent: 16),
                    _menuItem(
                      Icons.language,
                      'Language',
                      subtitle: 'English',
                      onTap: () {},
                    ),
                    if (user?.isAdmin == true) ...[
                      const Divider(indent: 16, endIndent: 16),
                      _menuItem(
                        Icons.admin_panel_settings,
                        'Admin Panel',
                        onTap: () => context.push('/admin'),
                      ),
                    ],
                    const Divider(indent: 16, endIndent: 16),
                    _menuItem(
                      Icons.info_outline,
                      'About',
                      onTap: () {
                        showAboutDialog(
                          context: context,
                          applicationName: 'Pro Badminton',
                          applicationVersion: '1.0.0',
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Logout
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Card(
                child: ListTile(
                  leading: const Icon(Icons.logout, color: AppTheme.error),
                  title: const Text(
                    'Logout',
                    style: TextStyle(color: AppTheme.error),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppTheme.error,
                  ),
                  onTap: () async {
                    await ref.read(authProvider.notifier).logout();
                    if (context.mounted) context.go('/login');
                  },
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(
    IconData icon,
    String title, {
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.textPrimary, size: 24),
      title: Text(title),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            )
          : null,
      trailing: const Icon(Icons.chevron_right, color: AppTheme.textDisabled),
      onTap: onTap,
    );
  }
}
