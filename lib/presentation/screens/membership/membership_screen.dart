import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../providers/membership_provider.dart';

class MembershipScreen extends ConsumerStatefulWidget {
  const MembershipScreen({super.key});

  @override
  ConsumerState<MembershipScreen> createState() => _MembershipScreenState();
}

class _MembershipScreenState extends ConsumerState<MembershipScreen> {
  final _monthlyBookings = TextEditingController(text: '4');

  @override
  void dispose() {
    _monthlyBookings.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final memberState = ref.watch(membershipProvider);
    final subState = ref.watch(subscribeProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Membership'),
        backgroundColor: AppTheme.surface,
        elevation: 0,
      ),
      body: switch (memberState) {
        MembershipLoading() => const Center(child: CircularProgressIndicator()),
        MembershipError(:final message) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppTheme.error),
              const SizedBox(height: 12),
              Text(
                message,
                style: const TextStyle(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () =>
                    ref.read(membershipProvider.notifier).loadStatus(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        MembershipLoaded(:final isMember, :final expiresAt) =>
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: isMember
                        ? const LinearGradient(
                            colors: [AppTheme.primary, Color(0xFF1B5E20)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : const LinearGradient(
                            colors: [Color(0xFF9E9E9E), Color(0xFF616161)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        isMember
                            ? Icons.verified
                            : Icons.card_membership_outlined,
                        color: Colors.white,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        isMember ? 'Active Member' : 'Not a Member',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isMember && expiresAt != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Valid until ${Formatters.date(expiresAt)}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        '฿199 / month',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Benefits
                const Text(
                  'Member Benefits',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _benefitTile(
                  Icons.local_offer,
                  'Discounted Rates',
                  '฿150/hr instead of ฿200/hr (25% off)',
                ),
                _benefitTile(
                  Icons.priority_high,
                  'Priority Booking',
                  'Book courts 48 hours before non-members',
                ),
                _benefitTile(
                  Icons.event_available,
                  'Exclusive Access',
                  'Access to member-only courts and events',
                ),
                _benefitTile(
                  Icons.card_giftcard,
                  'Equipment Discounts',
                  '10% off all equipment rentals',
                ),
                const SizedBox(height: 24),

                // Savings Calculator
                const Text(
                  'Savings Calculator',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Bookings per month',
                                style: TextStyle(fontSize: 15),
                              ),
                            ),
                            SizedBox(
                              width: 80,
                              child: TextFormField(
                                controller: _monthlyBookings,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                decoration: const InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                ),
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        _calcRow('Standard cost', _standardCost()),
                        _calcRow('Member cost', _memberCost()),
                        const Divider(height: 24),
                        _calcRow(
                          'Monthly savings',
                          _savings(),
                          highlight: true,
                        ),
                        _calcRow(
                          'After ฿199 fee',
                          _netSavings(),
                          highlight: true,
                          isNet: true,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Subscribe button
                if (!isMember) ...[
                  if (subState is SubscribeError)
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
                              subState.message,
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
                    height: 52,
                    child: ElevatedButton(
                      onPressed: subState is SubscribeProcessing
                          ? null
                          : _subscribe,
                      child: subState is SubscribeProcessing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Subscribe Now — ฿199/month',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                ] else ...[
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => context.pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.success,
                      ),
                      child: const Text(
                        'You\'re all set!',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
              ],
            ),
          ),
      },
    );
  }

  int get _bookings {
    return int.tryParse(_monthlyBookings.text) ?? 0;
  }

  double _standardCost() => _bookings * 200.0;
  double _memberCost() => _bookings * 150.0;
  double _savings() => _standardCost() - _memberCost();
  double _netSavings() => _savings() - 199.0;

  Widget _benefitTile(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: AppTheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _calcRow(
    String label,
    double amount, {
    bool highlight = false,
    bool isNet = false,
  }) {
    final isPositive = amount >= 0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: highlight ? FontWeight.w600 : FontWeight.normal,
              fontSize: 15,
            ),
          ),
          Text(
            '${isPositive ? "" : "-"}${Formatters.currency(amount.abs())}',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: isNet
                  ? (isPositive ? AppTheme.success : AppTheme.error)
                  : highlight
                  ? AppTheme.primary
                  : AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _subscribe() async {
    final method = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Choose Payment Method',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.credit_card),
                title: const Text('Credit Card'),
                onTap: () => Navigator.pop(ctx, 'credit_card'),
              ),
              ListTile(
                leading: const Icon(Icons.account_balance),
                title: const Text('Bank Transfer'),
                onTap: () => Navigator.pop(ctx, 'bank_transfer'),
              ),
              ListTile(
                leading: const Icon(Icons.qr_code),
                title: const Text('PromptPay'),
                onTap: () => Navigator.pop(ctx, 'promptpay'),
              ),
            ],
          ),
        ),
      ),
    );

    if (method != null && mounted) {
      await ref
          .read(subscribeProvider.notifier)
          .subscribe(paymentMethod: method);

      final state = ref.read(subscribeProvider);
      if (state is SubscribeSuccess && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Welcome! Membership activated.'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    }
  }
}
