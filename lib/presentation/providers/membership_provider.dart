import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/remote/api/auth_api.dart';
import 'auth_provider.dart';

// Membership API provider
final membershipApiProvider = Provider<AuthApi>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthApi(apiClient.dio);
});

// ── Membership Status ──

sealed class MembershipState {
  const MembershipState();
}

class MembershipLoading extends MembershipState {
  const MembershipLoading();
}

class MembershipLoaded extends MembershipState {
  final bool isMember;
  final DateTime? startedAt;
  final DateTime? expiresAt;
  final String? lastPaid;
  const MembershipLoaded({
    required this.isMember,
    this.startedAt,
    this.expiresAt,
    this.lastPaid,
  });
}

class MembershipError extends MembershipState {
  final String message;
  const MembershipError(this.message);
}

class MembershipNotifier extends StateNotifier<MembershipState> {
  final AuthApi _authApi;

  MembershipNotifier(this._authApi) : super(const MembershipLoading());

  Future<void> loadStatus() async {
    state = const MembershipLoading();
    try {
      final response = await _authApi.getMembershipStatus();
      dynamic data = response.data;
      if (data is String) data = jsonDecode(data);
      if (data != null && data is Map) {
        final status = data['membership'] ?? data;
        state = MembershipLoaded(
          isMember: status['is_member'] == true || status['is_active'] == true,
          startedAt: status['membership_started_at'] != null
              ? DateTime.tryParse(status['membership_started_at'])
              : null,
          expiresAt: status['membership_expires_at'] != null
              ? DateTime.tryParse(status['membership_expires_at'])
              : null,
          lastPaid: status['membership_fee_last_paid']?.toString(),
        );
      } else {
        state = const MembershipLoaded(isMember: false);
      }
    } catch (e) {
      state = MembershipError('Failed to load membership: $e');
    }
  }
}

final membershipProvider =
    StateNotifierProvider<MembershipNotifier, MembershipState>((ref) {
      final authApi = ref.watch(membershipApiProvider);
      final notifier = MembershipNotifier(authApi);
      notifier.loadStatus();
      return notifier;
    });

// ── Subscribe ──

sealed class SubscribeState {
  const SubscribeState();
}

class SubscribeIdle extends SubscribeState {
  const SubscribeIdle();
}

class SubscribeProcessing extends SubscribeState {
  const SubscribeProcessing();
}

class SubscribeSuccess extends SubscribeState {
  const SubscribeSuccess();
}

class SubscribeError extends SubscribeState {
  final String message;
  const SubscribeError(this.message);
}

class SubscribeNotifier extends StateNotifier<SubscribeState> {
  final AuthApi _authApi;
  final MembershipNotifier _membershipNotifier;

  SubscribeNotifier(this._authApi, this._membershipNotifier)
    : super(const SubscribeIdle());

  Future<void> subscribe({required String paymentMethod}) async {
    state = const SubscribeProcessing();
    try {
      await _authApi.subscribeMembership({'payment_method': paymentMethod});
      state = const SubscribeSuccess();
      await _membershipNotifier.loadStatus();
    } catch (e) {
      state = SubscribeError('Subscription failed: $e');
    }
  }

  void reset() {
    state = const SubscribeIdle();
  }
}

final subscribeProvider =
    StateNotifierProvider<SubscribeNotifier, SubscribeState>((ref) {
      final authApi = ref.watch(membershipApiProvider);
      final membershipNotifier = ref.watch(membershipProvider.notifier);
      return SubscribeNotifier(authApi, membershipNotifier);
    });
