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
      final response = await _waitlistApi.getWaitlist();
      dynamic data = response.data;
      if (data is String) data = jsonDecode(data);
      if (data is Map && data['waitlist'] != null) {
        final raw = data['waitlist'];
        final list = raw is List ? raw : [];
        final entries = list
            .map(
              (j) => WaitlistEntry.fromJson(
                j is Map<String, dynamic>
                    ? j
                    : Map<String, dynamic>.from(j as Map),
              ),
            )
            .toList();
        state = WaitlistListLoaded(entries);
      } else if (data is Map && data['entries'] != null) {
        final raw = data['entries'];
        final list = raw is List ? raw : [];
        final entries = list
            .map(
              (j) => WaitlistEntry.fromJson(
                j is Map<String, dynamic>
                    ? j
                    : Map<String, dynamic>.from(j as Map),
              ),
            )
            .toList();
        state = WaitlistListLoaded(entries);
      } else {
        state = const WaitlistListLoaded([]);
      }
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

  Future<void> joinWaitlist({
    required String courtId,
    required String date,
    required String startTime,
    required String endTime,
  }) async {
    state = const JoinWaitlistJoining();
    try {
      final response = await _waitlistApi.joinWaitlist({
        'court_id': courtId,
        'date': date,
        'start_time': startTime,
        'end_time': endTime,
      });
      dynamic data = response.data;
      if (data is String) data = jsonDecode(data);
      if (data is Map && data['entry'] != null) {
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
