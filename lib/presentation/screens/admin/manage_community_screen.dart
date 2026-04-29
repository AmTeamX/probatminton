import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_theme.dart';
import '../../../domain/models/community_post.dart';
import '../../providers/community_provider.dart';

class ManageCommunityScreen extends ConsumerWidget {
  const ManageCommunityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(partyListProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Manage Community'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(partyListProvider.notifier).loadParties(),
        child: switch (state) {
          PartyListLoading() => const Center(
            child: CircularProgressIndicator(color: AppTheme.primary),
          ),
          PartyListError(:final message) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(message, style: const TextStyle(color: AppTheme.error)),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () =>
                      ref.read(partyListProvider.notifier).loadParties(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          PartyListLoaded(:final parties) =>
            parties.isEmpty
                ? const Center(child: Text('No parties found'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: parties.length,
                    itemBuilder: (context, index) {
                      final party = parties[index];
                      return _AdminPartyCard(party: party);
                    },
                  ),
          _ => const Center(child: Text('Unknown state')),
        },
      ),
    );
  }
}

class _AdminPartyCard extends StatelessWidget {
  final Party party;
  const _AdminPartyCard({required this.party});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    party.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
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
                    color: party.isOpen
                        ? const Color(0xFFE8F5E9)
                        : party.isFull
                        ? const Color(0xFFFFEBEE)
                        : const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    party.status,
                    style: TextStyle(
                      color: party.isOpen
                          ? const Color(0xFF2E7D32)
                          : party.isFull
                          ? const Color(0xFFC62828)
                          : Colors.orange,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Host: ${party.hostName}'),
            Text('Game: ${party.gameName}'),
            Text('Location: ${party.location}'),
            Text('Players: ${party.participantCount}/${party.capacity}'),
            if (party.description != null && party.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Description: ${party.description}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
