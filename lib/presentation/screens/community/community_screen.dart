import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/constants/app_theme.dart';
import '../../../domain/models/community_post.dart';
import '../../providers/auth_provider.dart';
import '../../providers/community_provider.dart';

class CommunityScreen extends ConsumerWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final partyListState = ref.watch(partyListProvider);
    final authState = ref.watch(authProvider);
    final isAuthenticated = authState.value is Authenticated;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Community',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.primary, AppTheme.primaryDark],
                  ),
                ),
              ),
            ),
            actions: [
              if (isAuthenticated)
                IconButton(
                  icon: const Icon(Icons.person_outline, color: Colors.white),
                  tooltip: 'My Parties',
                  onPressed: () => _showMyParties(context, ref),
                ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Game Sessions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  if (isAuthenticated)
                    FilledButton.icon(
                      onPressed: () => _showCreateParty(context),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Create'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          switch (partyListState) {
            PartyListLoading() => SliverToBoxAdapter(child: _buildShimmer()),
            PartyListError(:final message) => SliverToBoxAdapter(
              child: _buildError(context, ref, message),
            ),
            PartyListLoaded(:final parties) =>
              parties.isEmpty
                  ? const SliverToBoxAdapter(child: _EmptyState())
                  : SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (ctx, i) => _PartyCard(party: parties[i]),
                          childCount: parties.length,
                        ),
                      ),
                    ),
            _ => const SliverToBoxAdapter(child: SizedBox()),
          },
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: AppTheme.surfaceVariant,
      highlightColor: AppTheme.dividerColor,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 4,
        itemBuilder: (_, _) => Container(
          height: 180,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref, String message) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppTheme.error),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => ref.read(partyListProvider.notifier).loadParties(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showCreateParty(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const _CreatePartySheet(),
    );
  }

  void _showMyParties(BuildContext context, WidgetRef ref) {
    ref.read(myPartiesProvider.notifier).loadMyParties();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const _MyPartiesSheet(),
    );
  }
}

// ── Party Card ──

class _PartyCard extends ConsumerWidget {
  final Party party;
  const _PartyCard({required this.party});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final joinState = ref.watch(joinPartyProvider);
    final isJoining =
        joinState is JoinPartyJoining && joinState.partyId == party.id;
    final authState = ref.watch(authProvider);
    final isAuthenticated = authState.value is Authenticated;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppTheme.primaryLight,
                  child: Text(
                    party.hostName.isNotEmpty ? party.hostName[0] : '?',
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        party.hostName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        _formatDateTime(party.gameDateTime),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                _statusChip(party.status),
              ],
            ),
            const SizedBox(height: 12),

            // Title & Game
            Text(
              party.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.sports_tennis,
                  size: 14,
                  color: AppTheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  party.gameName,
                  style: const TextStyle(color: AppTheme.primary),
                ),
                const SizedBox(width: 12),
                const Icon(
                  Icons.location_on,
                  size: 14,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    party.location,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (party.description != null && party.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                party.description!,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 12),

            // Footer: capacity + join button
            Row(
              children: [
                Icon(Icons.people, size: 16, color: _capacityColor),
                const SizedBox(width: 4),
                Text(
                  '${party.participantCount}/${party.capacity}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _capacityColor,
                  ),
                ),
                const Spacer(),
                if (isAuthenticated && party.isOpen)
                  SizedBox(
                    height: 36,
                    child: FilledButton(
                      onPressed: isJoining
                          ? null
                          : () => _handleJoin(context, ref),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: isJoining
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text('Join'),
                    ),
                  )
                else if (party.isFull)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      'Full',
                      style: TextStyle(
                        color: AppTheme.error,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  )
                else if (party.isCancelled)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      'Cancelled',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color get _capacityColor {
    if (party.isFull) return AppTheme.error;
    if (party.participantCount >= party.capacity * 0.75) return Colors.orange;
    return AppTheme.primary;
  }

  Widget _statusChip(String status) {
    Color bg, text;
    switch (status) {
      case 'OPEN':
        bg = const Color(0xFFE8F5E9);
        text = const Color(0xFF2E7D32);
      case 'FULL':
        bg = const Color(0xFFFFEBEE);
        text = const Color(0xFFC62828);
      case 'CANCELLED':
        bg = const Color(0xFFFFF3E0);
        text = Colors.orange;
      default:
        bg = AppTheme.surfaceVariant;
        text = AppTheme.textSecondary;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: text,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final hour = dt.hour > 12 ? dt.hour - 12 : dt.hour;
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${months[dt.month]} ${dt.day}, ${dt.year} at $hour:${dt.minute.toString().padLeft(2, '0')} $ampm';
  }

  Future<void> _handleJoin(BuildContext context, WidgetRef ref) async {
    await ref.read(joinPartyProvider.notifier).joinParty(party.id);

    final state = ref.read(joinPartyProvider);
    if (state is JoinPartySuccess) {
      // Refresh party list
      ref.read(partyListProvider.notifier).loadParties();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.message),
            backgroundColor: AppTheme.success,
          ),
        );
      }
      ref.read(joinPartyProvider.notifier).reset();
    } else if (state is JoinPartyError) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.message),
            backgroundColor: AppTheme.error,
          ),
        );
      }
      ref.read(joinPartyProvider.notifier).reset();
    }
  }
}

// ── Empty State ──

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Icon(Icons.groups, size: 64, color: AppTheme.textDisabled),
          const SizedBox(height: 12),
          const Text(
            'No game sessions yet',
            style: TextStyle(fontSize: 16, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 4),
          const Text(
            'Create one and invite others to play!',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ── Create Party Sheet ──

class _CreatePartySheet extends ConsumerStatefulWidget {
  const _CreatePartySheet();

  @override
  ConsumerState<_CreatePartySheet> createState() => _CreatePartySheetState();
}

class _CreatePartySheetState extends ConsumerState<_CreatePartySheet> {
  final _titleCtrl = TextEditingController();
  final _gameCtrl = TextEditingController(text: 'Badminton');
  final _locationCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _capacityCtrl = TextEditingController(text: '4');
  DateTime _dateTime = DateTime.now().add(const Duration(days: 1));

  @override
  void dispose() {
    _titleCtrl.dispose();
    _gameCtrl.dispose();
    _locationCtrl.dispose();
    _descCtrl.dispose();
    _capacityCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createPartyProvider);

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Create Game Session',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Title *',
                hintText: 'Friday Night Badminton',
              ),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _gameCtrl,
              decoration: const InputDecoration(
                labelText: 'Game/Sport *',
                hintText: 'Badminton',
              ),
            ),
            const SizedBox(height: 12),

            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: Text(
                'Date & Time: ${_dateTime.day}/${_dateTime.month}/${_dateTime.year} at ${_dateTime.hour}:${_dateTime.minute.toString().padLeft(2, '0')}',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: _pickDateTime,
            ),
            const SizedBox(height: 8),

            TextFormField(
              controller: _locationCtrl,
              decoration: const InputDecoration(
                labelText: 'Location *',
                hintText: 'Court A, Sukhumvit',
              ),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _capacityCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Max Players *',
                hintText: '4',
              ),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _descCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Looking for players!',
              ),
            ),
            const SizedBox(height: 16),

            if (state is CreatePartyError)
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

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: state is CreatePartySubmitting ? null : _submit,
                child: state is CreatePartySubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : const Text('Create Party'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dateTime),
    );
    if (time == null || !mounted) return;

    setState(() {
      _dateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _submit() async {
    if (_titleCtrl.text.trim().isEmpty ||
        _gameCtrl.text.trim().isEmpty ||
        _locationCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    await ref
        .read(createPartyProvider.notifier)
        .createParty(
          title: _titleCtrl.text.trim(),
          gameName: _gameCtrl.text.trim(),
          gameDateTime: _dateTime,
          location: _locationCtrl.text.trim(),
          capacity: int.tryParse(_capacityCtrl.text.trim()) ?? 4,
          description: _descCtrl.text.trim(),
        );

    final state = ref.read(createPartyProvider);
    if (state is CreatePartySuccess && mounted) {
      ref.read(partyListProvider.notifier).loadParties();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Party created!'),
          backgroundColor: AppTheme.success,
        ),
      );
      ref.read(createPartyProvider.notifier).reset();
    }
  }
}

// ── My Parties Sheet ──

class _MyPartiesSheet extends ConsumerWidget {
  const _MyPartiesSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myPartiesProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.3,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'My Joined Parties',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: switch (state) {
                MyPartiesLoading() => const Center(
                  child: CircularProgressIndicator(color: AppTheme.primary),
                ),
                MyPartiesError(:final message) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        message,
                        style: const TextStyle(color: AppTheme.error),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () => ref
                            .read(myPartiesProvider.notifier)
                            .loadMyParties(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
                MyPartiesLoaded(:final parties) =>
                  parties.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.groups,
                                size: 48,
                                color: AppTheme.textDisabled,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'You haven\'t joined any parties yet',
                                style: TextStyle(color: AppTheme.textSecondary),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: parties.length,
                          itemBuilder: (_, i) => _PartyCard(party: parties[i]),
                        ),
                _ => const SizedBox(),
              },
            ),
          ],
        );
      },
    );
  }
}
