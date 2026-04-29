import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/constants/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/court_provider.dart';
import '../../widgets/court_card.dart';
import '../../widgets/empty_state.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();
  int _selectedFilter = 0;
  final _filters = ['All', 'Nearby', '< ฿300/hr', 'Top Rated ⭐'];

  @override
  void initState() {
    super.initState();
    // Load courts on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCourts();
    });
  }

  void _loadCourts() {
    final location = ref.read(currentLocationProvider).valueOrNull;
    final search = _searchController.text.trim();

    ref
        .read(courtListProvider.notifier)
        .loadCourts(
          search: search.isEmpty ? null : search,
          maxPrice: _selectedFilter == 2 ? 300 : null,
          lat: location?.latitude,
          lng: location?.longitude,
          radius: _selectedFilter == 1 ? 10 : null,
        );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.value is Authenticated
        ? (authState.value as Authenticated).user
        : null;
    final courtState = ref.watch(courtListProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.primary,
          onRefresh: () async {
            _loadCourts();
          },
          child: CustomScrollView(
            slivers: [
              // Custom App Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.sports_tennis,
                            color: AppTheme.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Pro Badminton',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => context.go('/profile'),
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: AppTheme.primaryLight,
                          child: Text(
                            user?.fullName.isNotEmpty == true
                                ? user!.fullName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onSubmitted: (_) => _loadCourts(),
                      decoration: InputDecoration(
                        hintText: 'Search courts...',
                        hintStyle: const TextStyle(
                          color: AppTheme.textDisabled,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          size: 20,
                          color: AppTheme.textSecondary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(26),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Filter Chips
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 0, 0),
                  child: SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(right: 20),
                      itemCount: _filters.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final selected = _selectedFilter == index;
                        return GestureDetector(
                          onTap: () {
                            setState(() => _selectedFilter = index);
                            _loadCourts();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppTheme.primary
                                  : AppTheme.surface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: selected
                                    ? AppTheme.primary
                                    : AppTheme.dividerColor,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _filters[index],
                              style: TextStyle(
                                color: selected
                                    ? Colors.white
                                    : AppTheme.textSecondary,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              // Section Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: Row(
                    children: [
                      const Text(
                        'Nearby Courts',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Divider(color: AppTheme.dividerColor),
                      ),
                    ],
                  ),
                ),
              ),

              // Content based on state
              switch (courtState) {
                CourtListInitial() => const SliverToBoxAdapter(
                  child: SizedBox.shrink(),
                ),
                CourtListLoading() => SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, _) => _buildShimmerCard(),
                      childCount: 3,
                    ),
                  ),
                ),
                CourtListLoaded(:final courts) =>
                  courts.isEmpty
                      ? SliverFillRemaining(
                          child: EmptyState(
                            icon: Icons.sports_tennis,
                            title: 'No courts found',
                            subtitle: 'Try adjusting your filters or search',
                            actionLabel: 'Refresh',
                            onAction: _loadCourts,
                          ),
                        )
                      : SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: CourtCard(court: courts[index]),
                              ),
                              childCount: courts.length,
                            ),
                          ),
                        ),
                CourtListError(:final message) => SliverFillRemaining(
                  child: EmptyState(
                    icon: Icons.error_outline,
                    title: 'Something went wrong',
                    subtitle: message,
                    actionLabel: 'Retry',
                    onAction: _loadCourts,
                  ),
                ),
              },

              // Bottom spacing for nav bar
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/map'),
        icon: const Icon(Icons.map_outlined),
        label: const Text('Map View'),
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Shimmer.fromColors(
        baseColor: AppTheme.surfaceVariant,
        highlightColor: AppTheme.dividerColor,
        child: Row(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 12,
                    width: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 14,
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
