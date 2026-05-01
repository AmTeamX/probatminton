import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/remote/api/waitlist_api.dart';
import '../../domain/models/waitlist_entry.dart';
import 'auth_provider.dart';

// Waitlist API provider
final waitlistApiProvider = Provider<WaitlistApi>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return WaitlistApi(apiClient.dio);
});

// ── Waitlist List ──

sealed class WaitlistListState {
  const WaitlistListState();
}

class WaitlistListLoading extends WaitlistListState {
  const WaitlistListLoading();
}

class WaitlistListLoaded extends WaitlistListState {
  final List<WaitlistEntry> entries;
  const WaitlistListLoaded(this.entries);
}

class WaitlistListError extends WaitlistListState {
  final String message;
  const WaitlistListError(this.message);
}

class WaitlistListNotifier extends StateNotifier<WaitlistListState> {
  final WaitlistApi _waitlistApi;

  WaitlistListNotifier(this._waitlistApi) : super(const WaitlistListLoading());

  Future<void> loadWaitlist() async {
    state = const WaitlistListLoading();
    try {
      // GET /api/waitlist/my returns a flat JSON array
      final response = await _waitlistApi.getMyWaitlist();
      dynamic data = response.data;
      if (data is String) data = jsonDecode(data);

      final List<WaitlistEntry> entries;

      if (data is List) {
        // Backend returns a flat array
        entries = data
            .whereType<Map<String, dynamic>>()
            .map((j) => WaitlistEntry.fromJson(j))
            .toList();
      } else if (data is Map && data['entries'] != null) {
        // Fallback: wrapped in { "entries": [...] }
        final raw = data['entries'];
        final list = raw is List ? raw : [];
        entries = list
            .map(
              (j) => WaitlistEntry.fromJson(
                j is Map<String, dynamic>
                    ? j
                    : Map<String, dynamic>.from(j as Map),
              ),
            )
            .toList();
      } else if (data is Map && data['waitlist'] != null) {
        // Fallback: wrapped in { "waitlist": [...] }
        final raw = data['waitlist'];
        final list = raw is List ? raw : [];
        entries = list
            .map(
              (j) => WaitlistEntry.fromJson(
                j is Map<String, dynamic>
                    ? j
                    : Map<String, dynamic>.from(j as Map),
              ),
            )
            .toList();
      } else {
        entries = [];
      }

      state = WaitlistListLoaded(entries);
    } catch (e) {
      state = WaitlistListError('Failed to load waitlist: $e');
    }
  }

  Future<bool> leaveWaitlist(String entryId) async {
    try {
      await _waitlistApi.leaveWaitlist(entryId);
      await loadWaitlist();
      return true;
    } catch (e) {
      return false;
    }
  }
}

final waitlistListProvider =
    StateNotifierProvider<WaitlistListNotifier, WaitlistListState>((ref) {
      final waitlistApi = ref.watch(waitlistApiProvider);
      final notifier = WaitlistListNotifier(waitlistApi);
      notifier.loadWaitlist();
      return notifier;
    });

// ── Join Waitlist ──

sealed class JoinWaitlistState {
  const JoinWaitlistState();
}

class JoinWaitlistIdle extends JoinWaitlistState {
  const JoinWaitlistIdle();
}

class JoinWaitlistJoining extends JoinWaitlistState {
  const JoinWaitlistJoining();
}

class JoinWaitlistSuccess extends JoinWaitlistState {
  final WaitlistEntry entry;
  const JoinWaitlistSuccess(this.entry);
}

class JoinWaitlistError extends JoinWaitlistState {
  final String message;
  const JoinWaitlistError(this.message);
}

class JoinWaitlistNotifier extends StateNotifier<JoinWaitlistState> {
  final WaitlistApi _waitlistApi;

  JoinWaitlistNotifier(this._waitlistApi) : super(const JoinWaitlistIdle());

  /// Join waitlist using backend fields:
  /// - courtId, requestedDate (YYYY-MM-DD), preferredTimeSlot (HH:MM-HH:MM)
  Future<void> joinWaitlist({
    required String courtId,
    required String requestedDate,
    required String preferredTimeSlot,
  }) async {
    state = const JoinWaitlistJoining();
    try {
      final response = await _waitlistApi.joinWaitlist({
        'court_id': courtId,
        'requested_date': requestedDate,
        'preferred_time_slot': preferredTimeSlot,
      });
      dynamic data = response.data;
      if (data is String) data = jsonDecode(data);

      // Backend returns the entry directly as a flat object
      if (data is Map<String, dynamic>) {
        final entry = WaitlistEntry.fromJson(data);
        state = JoinWaitlistSuccess(entry);
      } else if (data is Map && data['entry'] != null) {
        final entry = WaitlistEntry.fromJson(
          Map<String, dynamic>.from(data['entry'] as Map),
        );
        state = JoinWaitlistSuccess(entry);
      } else if (data is Map && data['waitlist_entry'] != null) {
        final entry = WaitlistEntry.fromJson(
          Map<String, dynamic>.from(data['waitlist_entry'] as Map),
        );
        state = JoinWaitlistSuccess(entry);
      } else {
        state = const JoinWaitlistError('Failed to join waitlist');
      }
    } catch (e) {
      state = JoinWaitlistError('Failed to join waitlist: $e');
    }
  }

  void reset() {
    state = const JoinWaitlistIdle();
  }
}

final joinWaitlistProvider =
    StateNotifierProvider<JoinWaitlistNotifier, JoinWaitlistState>((ref) {
      final waitlistApi = ref.watch(waitlistApiProvider);
      return JoinWaitlistNotifier(waitlistApi);
    });

// ── Confirm Waitlist ──

sealed class ConfirmWaitlistState {
  const ConfirmWaitlistState();
}

class ConfirmWaitlistIdle extends ConfirmWaitlistState {
  const ConfirmWaitlistIdle();
}

class ConfirmWaitlistConfirming extends ConfirmWaitlistState {
  const ConfirmWaitlistConfirming();
}

class ConfirmWaitlistSuccess extends ConfirmWaitlistState {
  final Map<String, dynamic> booking;
  const ConfirmWaitlistSuccess(this.booking);
}

class ConfirmWaitlistError extends ConfirmWaitlistState {
  final String message;
  const ConfirmWaitlistError(this.message);
}

class ConfirmWaitlistNotifier extends StateNotifier<ConfirmWaitlistState> {
  final WaitlistApi _waitlistApi;

  ConfirmWaitlistNotifier(this._waitlistApi)
    : super(const ConfirmWaitlistIdle());

  Future<void> confirm(
    String entryId, {
    String? paymentMethod,
    String? transferReference,
  }) async {
    state = const ConfirmWaitlistConfirming();
    try {
      final response = await _waitlistApi.confirmWaitlist(
        entryId,
        paymentMethod: paymentMethod,
        transferReference: transferReference,
      );
      dynamic data = response.data;
      if (data is String) data = jsonDecode(data);
      if (data is Map && data['booking'] != null) {
        state = ConfirmWaitlistSuccess(
          Map<String, dynamic>.from(data['booking'] as Map),
        );
      } else {
        state = const ConfirmWaitlistError('Failed to confirm waitlist');
      }
    } catch (e) {
      state = ConfirmWaitlistError('Failed to confirm waitlist: $e');
    }
  }

  void reset() {
    state = const ConfirmWaitlistIdle();
  }
}

final confirmWaitlistProvider =
    StateNotifierProvider<ConfirmWaitlistNotifier, ConfirmWaitlistState>((ref) {
      final waitlistApi = ref.watch(waitlistApiProvider);
      return ConfirmWaitlistNotifier(waitlistApi);
    });
