import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/remote/api/community_api.dart';
import '../../domain/models/community_post.dart';
import 'auth_provider.dart';

// Community API provider
final communityApiProvider = Provider<CommunityApi>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return CommunityApi(apiClient.dio);
});

// ── Party List (Community Feed) ──

sealed class PartyListState {
  const PartyListState();
}

class PartyListInitial extends PartyListState {
  const PartyListInitial();
}

class PartyListLoading extends PartyListState {
  const PartyListLoading();
}

class PartyListLoaded extends PartyListState {
  final List<Party> parties;
  const PartyListLoaded(this.parties);
}

class PartyListError extends PartyListState {
  final String message;
  const PartyListError(this.message);
}

class PartyListNotifier extends StateNotifier<PartyListState> {
  final CommunityApi _api;

  PartyListNotifier(this._api) : super(const PartyListInitial());

  Future<void> loadParties() async {
    state = const PartyListLoading();
    try {
      final response = await _api.getParties();
      dynamic data = response.data;
      if (data is String) data = jsonDecode(data);
      if (data is List) {
        final parties = data
            .map((j) => Party.fromJson(Map<String, dynamic>.from(j as Map)))
            .toList();
        state = PartyListLoaded(parties);
      } else {
        state = const PartyListLoaded([]);
      }
    } catch (e) {
      state = PartyListError('Failed to load parties: $e');
    }
  }
}

final partyListProvider =
    StateNotifierProvider<PartyListNotifier, PartyListState>((ref) {
      final api = ref.watch(communityApiProvider);
      final notifier = PartyListNotifier(api);
      notifier.loadParties();
      return notifier;
    });

// ── My Parties ──

sealed class MyPartiesState {
  const MyPartiesState();
}

class MyPartiesInitial extends MyPartiesState {
  const MyPartiesInitial();
}

class MyPartiesLoading extends MyPartiesState {
  const MyPartiesLoading();
}

class MyPartiesLoaded extends MyPartiesState {
  final List<Party> parties;
  const MyPartiesLoaded(this.parties);
}

class MyPartiesError extends MyPartiesState {
  final String message;
  const MyPartiesError(this.message);
}

class MyPartiesNotifier extends StateNotifier<MyPartiesState> {
  final CommunityApi _api;

  MyPartiesNotifier(this._api) : super(const MyPartiesInitial());

  Future<void> loadMyParties() async {
    state = const MyPartiesLoading();
    try {
      final response = await _api.getMyParties();
      dynamic data = response.data;
      if (data is String) data = jsonDecode(data);
      if (data is List) {
        final parties = data
            .map((j) => Party.fromJson(Map<String, dynamic>.from(j as Map)))
            .toList();
        state = MyPartiesLoaded(parties);
      } else {
        state = const MyPartiesLoaded([]);
      }
    } catch (e) {
      state = MyPartiesError('Failed to load my parties: $e');
    }
  }
}

final myPartiesProvider =
    StateNotifierProvider<MyPartiesNotifier, MyPartiesState>((ref) {
      final api = ref.watch(communityApiProvider);
      return MyPartiesNotifier(api);
    });

// ── Create Party ──

sealed class CreatePartyState {
  const CreatePartyState();
}

class CreatePartyIdle extends CreatePartyState {
  const CreatePartyIdle();
}

class CreatePartySubmitting extends CreatePartyState {
  const CreatePartySubmitting();
}

class CreatePartySuccess extends CreatePartyState {
  final Party party;
  const CreatePartySuccess(this.party);
}

class CreatePartyError extends CreatePartyState {
  final String message;
  const CreatePartyError(this.message);
}

class CreatePartyNotifier extends StateNotifier<CreatePartyState> {
  final CommunityApi _api;

  CreatePartyNotifier(this._api) : super(const CreatePartyIdle());

  Future<void> createParty({
    required String title,
    required String gameName,
    required DateTime gameDateTime,
    required String location,
    required int capacity,
    String? description,
  }) async {
    state = const CreatePartySubmitting();
    try {
      final body = <String, dynamic>{
        'title': title,
        'game_name': gameName,
        'game_date_time': gameDateTime.toUtc().toIso8601String(),
        'location': location,
        'capacity': capacity,
        'description': description ?? '',
      };

      final response = await _api.createParty(body);
      dynamic data = response.data;
      if (data is String) data = jsonDecode(data);

      if (data is Map && data['party'] != null) {
        final party = Party.fromJson(
          Map<String, dynamic>.from(data['party'] as Map),
        );
        state = CreatePartySuccess(party);
      } else if (data is Map && data['id'] != null) {
        final party = Party.fromJson(Map<String, dynamic>.from(data));
        state = CreatePartySuccess(party);
      } else {
        state = const CreatePartyError('Failed to create party');
      }
    } catch (e) {
      state = CreatePartyError('Failed to create party: $e');
    }
  }

  void reset() => state = const CreatePartyIdle();
}

final createPartyProvider =
    StateNotifierProvider<CreatePartyNotifier, CreatePartyState>((ref) {
      final api = ref.watch(communityApiProvider);
      return CreatePartyNotifier(api);
    });

// ── Join Party ──

sealed class JoinPartyState {
  const JoinPartyState();
}

class JoinPartyIdle extends JoinPartyState {
  const JoinPartyIdle();
}

class JoinPartyJoining extends JoinPartyState {
  final String partyId;
  const JoinPartyJoining(this.partyId);
}

class JoinPartySuccess extends JoinPartyState {
  final String partyId;
  final String message;
  const JoinPartySuccess(this.partyId, this.message);
}

class JoinPartyError extends JoinPartyState {
  final String partyId;
  final String message;
  const JoinPartyError(this.partyId, this.message);
}

class JoinPartyNotifier extends StateNotifier<JoinPartyState> {
  final CommunityApi _api;

  JoinPartyNotifier(this._api) : super(const JoinPartyIdle());

  Future<void> joinParty(String partyId) async {
    state = JoinPartyJoining(partyId);
    try {
      final response = await _api.joinParty(partyId);
      dynamic data = response.data;
      if (data is String) data = jsonDecode(data);

      final msg = data is Map
          ? (data['message']?.toString() ?? 'Joined successfully')
          : 'Joined successfully';
      state = JoinPartySuccess(partyId, msg);
    } catch (e) {
      String errorMsg = 'Failed to join party';
      if (e.toString().contains('409') || e.toString().contains('full')) {
        errorMsg = 'Party is full or already joined';
      } else if (e.toString().contains('400')) {
        errorMsg = 'Party is not open for joins';
      } else if (e.toString().contains('404')) {
        errorMsg = 'Party not found';
      }
      state = JoinPartyError(partyId, errorMsg);
    }
  }

  void reset() => state = const JoinPartyIdle();
}

final joinPartyProvider =
    StateNotifierProvider<JoinPartyNotifier, JoinPartyState>((ref) {
      final api = ref.watch(communityApiProvider);
      return JoinPartyNotifier(api);
    });
