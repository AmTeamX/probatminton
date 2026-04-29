import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/constants/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/models/court.dart';
import '../../providers/court_provider.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  GoogleMapController? _mapController;
  Court? _selectedCourt;
  final Set<Marker> _markers = {};

  static const _bangkok = LatLng(13.7563, 100.5018);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCourts();
    });
  }

  Future<void> _loadCourts() async {
    // Load ALL courts (no location filter) so they all show on map
    ref.read(courtListProvider.notifier).loadCourts();
  }

  void _updateMarkers(List<Court> courts) {
    _markers.clear();
    for (final court in courts) {
      if (court.latitude != null && court.longitude != null) {
        _markers.add(
          Marker(
            markerId: MarkerId(court.id),
            position: LatLng(court.latitude!, court.longitude!),
            infoWindow: InfoWindow(title: court.name),
            onTap: () => _onCourtSelected(court),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              _selectedCourt?.id == court.id
                  ? BitmapDescriptor.hueOrange
                  : BitmapDescriptor.hueGreen,
            ),
          ),
        );
      }
    }
  }

  void _onCourtSelected(Court court) {
    setState(() => _selectedCourt = court);
    // Animate camera to court
    if (court.latitude != null &&
        court.longitude != null &&
        _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(court.latitude!, court.longitude!),
          15,
        ),
      );
    }
    // Rebuild markers to highlight selected
    final courtState = ref.read(courtListProvider);
    if (courtState is CourtListLoaded) {
      _updateMarkers(courtState.courts);
    }
  }

  Future<void> _goToMyLocation() async {
    final location = ref.read(currentLocationProvider).valueOrNull;
    if (location != null && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(LatLng(location.latitude, location.longitude)),
      );
    }
  }

  Future<void> _fitAllMarkers(List<Court> courts) async {
    final courtsWithLocation = courts
        .where((c) => c.latitude != null && c.longitude != null)
        .toList();
    if (courtsWithLocation.isEmpty || _mapController == null) return;

    if (courtsWithLocation.length == 1) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(
            courtsWithLocation.first.latitude!,
            courtsWithLocation.first.longitude!,
          ),
          14,
        ),
      );
      return;
    }

    final bounds = _computeBounds(courtsWithLocation);
    _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
  }

  LatLngBounds _computeBounds(List<Court> courts) {
    double minLat = double.infinity;
    double maxLat = -double.infinity;
    double minLng = double.infinity;
    double maxLng = -double.infinity;

    for (final court in courts) {
      if (court.latitude != null && court.longitude != null) {
        if (court.latitude! < minLat) minLat = court.latitude!;
        if (court.latitude! > maxLat) maxLat = court.latitude!;
        if (court.longitude! < minLng) minLng = court.longitude!;
        if (court.longitude! > maxLng) maxLng = court.longitude!;
      }
    }

    // Add some padding if all courts are at the same location
    if (minLat == maxLat) {
      minLat -= 0.01;
      maxLat += 0.01;
    }
    if (minLng == maxLng) {
      minLng -= 0.01;
      maxLng += 0.01;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  @override
  Widget build(BuildContext context) {
    final courtState = ref.watch(courtListProvider);
    final locationAsync = ref.watch(currentLocationProvider);

    final initialPosition = locationAsync.whenOrNull<LatLng>(
      data: (pos) => pos != null ? LatLng(pos.latitude, pos.longitude) : null,
    );

    // Update markers when courts load
    if (courtState is CourtListLoaded) {
      _updateMarkers(courtState.courts);
      // Fit all markers on first load
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fitAllMarkers(courtState.courts);
      });
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.go('/home'),
                ),
                const Text(
                  'Map View',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                if (courtState is CourtListLoaded)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Text(
                      '${courtState.courts.length} courts',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Map area (60% of screen)
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.55,
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: initialPosition ?? _bangkok,
                    zoom: 11,
                  ),
                  markers: _markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  onTap: (_) {
                    setState(() => _selectedCourt = null);
                    final cs = ref.read(courtListProvider);
                    if (cs is CourtListLoaded) _updateMarkers(cs.courts);
                  },
                ),

                // My location button
                Positioned(
                  right: 16,
                  top: 16,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.my_location),
                      color: AppTheme.primary,
                      onPressed: _goToMyLocation,
                    ),
                  ),
                ),

                // Fit all button
                Positioned(
                  right: 16,
                  top: 72,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.zoom_out_map),
                      color: AppTheme.primary,
                      onPressed: () {
                        final cs = ref.read(courtListProvider);
                        if (cs is CourtListLoaded) _fitAllMarkers(cs.courts);
                      },
                    ),
                  ),
                ),

                // Loading overlay
                if (courtState is CourtListLoading)
                  Container(
                    color: Colors.white70,
                    child: const Center(
                      child: CircularProgressIndicator(color: AppTheme.primary),
                    ),
                  ),

                // Error overlay
                if (courtState is CourtListError)
                  Center(
                    child: Container(
                      margin: const EdgeInsets.all(20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 40,
                            color: AppTheme.error,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            courtState.message,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            onPressed: _loadCourts,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Selected court card (shown above the list)
          if (_selectedCourt != null)
            GestureDetector(
              onTap: () => context.push('/court/${_selectedCourt!.id}'),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: _selectedCourt!.imageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                _selectedCourt!.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => const Icon(
                                  Icons.sports_tennis,
                                  color: AppTheme.primary,
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.sports_tennis,
                              color: AppTheme.primary,
                              size: 24,
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedCourt!.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _selectedCourt!.location,
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                size: 14,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${_selectedCourt!.avgRating ?? 0}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${Formatters.currency(_selectedCourt!.pricePerHour)}/hr',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.accent,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Book',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Bottom court list
          Expanded(
            child: courtState is CourtListLoaded
                ? courtState.courts.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.sports_tennis,
                                size: 40,
                                color: AppTheme.textDisabled,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'No courts found',
                                style: TextStyle(color: AppTheme.textSecondary),
                              ),
                            ],
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
                              child: Text(
                                'Courts Nearby',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ),
                            Expanded(
                              child: ListView.separated(
                                padding: const EdgeInsets.fromLTRB(
                                  12,
                                  4,
                                  12,
                                  16,
                                ),
                                itemCount: courtState.courts.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(height: 6),
                                itemBuilder: (context, index) {
                                  final court = courtState.courts[index];
                                  return _CourtListTile(
                                    court: court,
                                    isSelected: _selectedCourt?.id == court.id,
                                    onTap: () => _onCourtSelected(court),
                                  );
                                },
                              ),
                            ),
                          ],
                        )
                : const SizedBox(),
          ),
        ],
      ),
    );
  }
}

class _CourtListTile extends StatelessWidget {
  final Court court;
  final bool isSelected;
  final VoidCallback onTap;

  const _CourtListTile({
    required this.court,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryLight : AppTheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.dividerColor,
            width: isSelected ? 1.5 : 0.5,
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primary : AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.sports_tennis,
                size: 20,
                color: isSelected ? Colors.white : AppTheme.primary,
              ),
            ),
            const SizedBox(width: 10),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    court.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: isSelected ? AppTheme.primary : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    court.location,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Price & navigate icon
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${Formatters.currency(court.pricePerHour)}/hr',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: AppTheme.accent,
                  ),
                ),
                const SizedBox(height: 2),
                Icon(
                  Icons.navigation,
                  size: 14,
                  color: isSelected ? AppTheme.primary : AppTheme.textDisabled,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
