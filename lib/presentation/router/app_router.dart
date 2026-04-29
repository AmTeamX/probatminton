import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_theme.dart';
import '../screens/admin/admin_screen.dart';
import '../screens/admin/manage_bookings_screen.dart';
import '../screens/admin/manage_community_screen.dart';
import '../screens/admin/manage_courts_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/booking/booking_flow_screen.dart';
import '../screens/bookings/booking_detail_screen.dart';
import '../screens/bookings/bookings_screen.dart';
import '../screens/community/community_screen.dart';
import '../screens/court/court_detail_screen.dart';
import '../screens/court/review_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/map/map_screen.dart';
import '../screens/membership/membership_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/waitlist/waitlist_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),
      ShellRoute(
        builder: (_, _, child) => MainScaffold(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
          GoRoute(path: '/map', builder: (_, _) => const MapScreen()),
          GoRoute(path: '/bookings', builder: (_, _) => const BookingsScreen()),
          GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen()),
        ],
      ),
      GoRoute(
        path: '/court/:id',
        builder: (_, state) =>
            CourtDetailScreen(courtId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/book',
        builder: (_, state) =>
            BookingFlowScreen(courtId: state.uri.queryParameters['courtId']),
      ),
      GoRoute(
        path: '/booking/:id',
        builder: (_, state) =>
            BookingDetailScreen(bookingId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/review/:courtId',
        builder: (_, state) =>
            ReviewScreen(courtId: state.pathParameters['courtId']!),
      ),
      GoRoute(path: '/membership', builder: (_, _) => const MembershipScreen()),
      GoRoute(path: '/waitlist', builder: (_, _) => const WaitlistScreen()),
      GoRoute(path: '/community', builder: (_, _) => const CommunityScreen()),
      GoRoute(
        path: '/edit-profile',
        builder: (_, _) => const EditProfileScreen(),
      ),
      GoRoute(path: '/admin', builder: (_, _) => const AdminScreen()),
      GoRoute(
        path: '/admin/courts',
        builder: (_, _) => const ManageCourtsScreen(),
      ),
      GoRoute(
        path: '/admin/bookings',
        builder: (_, _) => const ManageBookingsScreen(),
      ),
      GoRoute(
        path: '/admin/community',
        builder: (_, _) => const ManageCommunityScreen(),
      ),
    ],
  );
});

class MainScaffold extends StatelessWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  static const _tabs = [
    (path: '/home', icon: Icons.sports_tennis, label: 'Home'),
    (path: '/map', icon: Icons.map_outlined, label: 'Map'),
    (path: '/bookings', icon: Icons.calendar_today_outlined, label: 'Bookings'),
    (path: '/profile', icon: Icons.person_outline, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppTheme.dividerColor)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_tabs.length, (i) {
                final selected = i == currentIndex;
                return GestureDetector(
                  onTap: () => context.go(_tabs[i].path),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppTheme.primaryLight
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _tabs[i].icon,
                          color: selected
                              ? AppTheme.primary
                              : AppTheme.textDisabled,
                          size: 24,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _tabs[i].label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: selected
                                ? AppTheme.primary
                                : AppTheme.textDisabled,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    for (int i = 0; i < _tabs.length; i++) {
      if (location == _tabs[i].path) return i;
    }
    return 0;
  }
}
