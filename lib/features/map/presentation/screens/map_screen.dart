import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../app/di/injector.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/widgets/app_states.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../cafes/data/models/cafe.dart';
import '../../../cafes/data/repositories/cafe_repository.dart';
import 'map_style.dart';

/// The map.
///
/// v1 hardcoded 15 cafés as a `List<dynamic>` of names and coordinates, and
/// embedded a Google Maps API key in the source. Pins now come from the API and
/// the key lives in platform config.
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  /// Erbil city centre — the same camera position v1 opened on.
  static const _erbil = CameraPosition(
    target: LatLng(36.191111, 44.009167),
    zoom: 12.5,
  );

  GoogleMapController? _controller;
  late Future<List<CafeMarker>> _future;
  CafeMarker? _selected;

  @override
  void initState() {
    super.initState();
    _future = sl<CafeRepository>().markers();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _focus(CafeMarker marker) async {
    setState(() => _selected = marker);
    await _controller?.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(marker.lat, marker.lng), 15),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: FutureBuilder<List<CafeMarker>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            final error = snapshot.error;
            return ErrorView(
              failure: error is Failure
                  ? error
                  : const ServerFailure('Could not load the map'),
              onRetry: () => setState(
                () => _future = sl<CafeRepository>().markers(),
              ),
            );
          }

          final markers = snapshot.data ?? const <CafeMarker>[];

          return Stack(
            children: [
              GoogleMap(
                initialCameraPosition: _erbil,
                style: isDark ? MapStyles.dark : MapStyles.light,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                markers: {
                  for (final marker in markers)
                    Marker(
                      markerId: MarkerId(marker.id),
                      position: LatLng(marker.lat, marker.lng),
                      onTap: () => _focus(marker),
                      infoWindow: InfoWindow(
                        title: marker.name,
                        snippet: marker.area,
                      ),
                    ),
                },
                onMapCreated: (controller) => _controller = controller,
                // Dismiss the preview card when the map itself is tapped.
                onTap: (_) => setState(() => _selected = null),
              ),

              if (snapshot.connectionState == ConnectionState.waiting)
                const Center(
                  child: CircularProgressIndicator(color: AppColors.accent),
                ),

              // Café count, so an empty map is distinguishable from a broken one.
              Positioned(
                top: MediaQuery.paddingOf(context).top + AppSpacing.md,
                left: AppSpacing.page,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: AppRadius.pillR,
                  ),
                  child: Text(
                    '${markers.length} ${l10n.allCafes.toLowerCase()}',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
              ),

              if (_selected != null)
                Positioned(
                  left: AppSpacing.page,
                  right: AppSpacing.page,
                  bottom: AppSpacing.xl,
                  child: _MarkerCard(
                    marker: _selected!,
                    onTap: () => context.push(Routes.cafe(_selected!.slug)),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Preview card for the selected pin, replacing v1's custom info window.
class _MarkerCard extends StatelessWidget {
  const _MarkerCard({required this.marker, required this.onTap});

  final CafeMarker marker;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: AppRadius.cardR,
      clipBehavior: Clip.antiAlias,
      elevation: 8,
      shadowColor: AppColors.shadow,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(marker.name, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (marker.reviewCount > 0) ...[
                          const Icon(Icons.star_rounded,
                              size: 14, color: AppColors.accent),
                          const SizedBox(width: 2),
                          Text(
                            marker.ratingAvg.toStringAsFixed(1),
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(width: AppSpacing.md),
                        ],
                        Text(
                          marker.isOpenNow ? l10n.openNow : l10n.closed,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: marker.isOpenNow
                                ? AppColors.success
                                : AppColors.textMuted,
                          ),
                        ),
                        if (marker.area != null) ...[
                          const SizedBox(width: AppSpacing.md),
                          Text(marker.area!, style: theme.textTheme.bodySmall),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.accent),
            ],
          ),
        ),
      ),
    );
  }
}
