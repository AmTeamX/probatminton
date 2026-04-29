import 'dart:convert';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../data/remote/api/court_api.dart';
import '../../domain/models/court.dart';
import 'auth_provider.dart';

// Court API provider
final courtApiProvider = Provider<CourtApi>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return CourtApi(apiClient.dio);
});

// Court list state
sealed class CourtListState {
  const CourtListState();
}

class CourtListInitial extends CourtListState {
  const CourtListInitial();
}

class CourtListLoading extends CourtListState {
  const CourtListLoading();
}

class CourtListLoaded extends CourtListState {
  final List<Court> courts;
  const CourtListLoaded(this.courts);
}

class CourtListError extends CourtListState {
  final String message;
  const CourtListError(this.message);
}

// Court list notifier
class CourtListNotifier extends StateNotifier<CourtListState> {
  final CourtApi _courtApi;

  CourtListNotifier(this._courtApi) : super(const CourtListInitial());

  Future<void> loadCourts({
    String? search,
    double? maxPrice,
    double? lat,
    double? lng,
    double? radius,
  }) async {
    state = const CourtListLoading();
    try {
      final hasFilters =
          search != null ||
          maxPrice != null ||
          (lat != null && lng != null && radius != null);
      final response = hasFilters
          ? await _courtApi.searchCourts(
              name: search,
              maxPrice: maxPrice,
              lat: lat,
              lng: lng,
              radius: radius,
            )
          : await _courtApi.getCourts();
      dynamic data = response.data;
      // Handle case where Dio didn't auto-parse JSON (response is a String)
      if (data is String) {
        data = jsonDecode(data);
      }
      log('Courts API response type: ${data.runtimeType}');
      if (data is! Map && data is! List) {
        log('Courts API unexpected response: $data');
        state = const CourtListLoaded([]);
        return;
      }
      if (data != null && data is Map && data['courts'] != null) {
        final raw = data['courts'];
        final List<dynamic> list;
        if (raw is List) {
          list = raw;
        } else if (raw is Map) {
          list = raw.values.toList();
        } else {
          list = [];
        }
        final courts = list
            .map(
              (j) => Court.fromJson(
                (j is Map<String, dynamic>)
                    ? j
                    : Map<String, dynamic>.from(j as Map),
              ),
            )
            .toList();
        state = CourtListLoaded(courts);
      } else if (data != null && data is List) {
        // Response might be a direct list
        final courts = (data)
            .map((j) => Court.fromJson(Map<String, dynamic>.from(j as Map)))
            .toList();
        state = CourtListLoaded(courts);
      } else {
        state = const CourtListLoaded([]);
      }
    } catch (e) {
      state = CourtListError('Failed to load courts: $e');
    }
  }
}

// Court list provider
final courtListProvider =
    StateNotifierProvider<CourtListNotifier, CourtListState>((ref) {
      final courtApi = ref.watch(courtApiProvider);
      return CourtListNotifier(courtApi);
    });

// Court detail state
sealed class CourtDetailState {
  const CourtDetailState();
}

class CourtDetailLoading extends CourtDetailState {
  const CourtDetailLoading();
}

class CourtDetailLoaded extends CourtDetailState {
  final Court court;
  const CourtDetailLoaded(this.court);
}

class CourtDetailError extends CourtDetailState {
  final String message;
  const CourtDetailError(this.message);
}

// Court detail notifier
class CourtDetailNotifier extends StateNotifier<CourtDetailState> {
  final CourtApi _courtApi;

  CourtDetailNotifier(this._courtApi) : super(const CourtDetailLoading());

  Future<void> loadCourt(String courtId) async {
    state = const CourtDetailLoading();
    try {
      final response = await _courtApi.getCourtDetail(courtId);
      dynamic data = response.data;
      if (data is String) data = jsonDecode(data);
      if (data is Map && data['court'] != null) {
        final court = Court.fromJson(
          Map<String, dynamic>.from(data['court'] as Map),
        );
        state = CourtDetailLoaded(court);
      } else if (data is Map) {
        // Response might be the court directly
        final court = Court.fromJson(Map<String, dynamic>.from(data));
        state = CourtDetailLoaded(court);
      } else {
        state = const CourtDetailError('Court not found');
      }
    } catch (e) {
      state = CourtDetailError('Failed to load court: $e');
    }
  }
}

// Court detail provider family (parameterized by courtId)
final courtDetailProvider =
    StateNotifierProvider.family<CourtDetailNotifier, CourtDetailState, String>(
      (ref, courtId) {
        final courtApi = ref.watch(courtApiProvider);
        final notifier = CourtDetailNotifier(courtApi);
        notifier.loadCourt(courtId);
        return notifier;
      },
    );

// Current location provider
final currentLocationProvider = FutureProvider<Position?>((ref) async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) return null;

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) return null;
  }
  if (permission == LocationPermission.deniedForever) return null;

  return await Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.medium,
      timeLimit: Duration(seconds: 10),
    ),
  );
});
