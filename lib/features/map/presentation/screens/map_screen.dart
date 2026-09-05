import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/di/injector.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/platform/platform_config.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_states.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../cafes/data/models/cafe.dart';
import '../../../cafes/data/repositories/cafe_repository.dart';
import 'map_style.dart';

/// The map.
///
/// v1 hardcoded 15 cafés as a `List<dynamic>` and embedded a Google Maps key in
/// the source. Pins now come from the API and the key lives in platform config.
///
/// The map is only built once the host confirms a key is configured. Without
/// one the iOS SDK raises an uncaught native exception on the first map view —
/// uncatchable from Dart — which is what crashed this tab.
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  /// Erbil city centre — the camera position v1 opened on.
  static const _erbil = CameraPosition(
    target: LatLng(36.191111, 44.009167),
    zoom: 12.4,
  );

  GoogleMapController? _controller;
  late Future<_MapData> _future;
  CafeMarker? _selected;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_MapData> _load() async {
    // Resolve both together so one round of loading covers the whole screen.
    final results = await Future.wait([
      PlatformConfig.mapsConfigured(),
      sl<CafeRepository>().markers(),
    ]);

    return _MapData(
      mapsAvailable: results[0] as bool,
      markers: results[1] as List<CafeMarker>,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _focus(CafeMarker marker) async {
    setState(() => _selected = marker);
    await _controller?.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(marker.lat, marker.lng), 15.5),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: FutureBuilder<_MapData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            );
          }

          if (snapshot.hasError) {
            final error = snapshot.error;
            return SafeArea(
              child: ErrorView(
                failure: error is Failure
                    ? error
                    : const ServerFailure('Could not load the map'),
                onRetry: () => setState(() => _future = _load()),
              ),
            );
          }

          final data = snapshot.data!;

          // No key: list the cafés rather than crash on a map we cannot draw.
          if (!data.mapsAvailable) {
            return _MapUnavailable(markers: data.markers);
          }

          return _MapView(
            markers: data.markers,
            selected: _selected,
            initialCamera: _erbil,
            onMapCreated: (c) => _controller = c,
            onMarkerTap: _focus,
            onDismiss: () => setState(() => _selected = null),
            countLabel: '${data.markers.length} ${l10n.allCafes.toLowerCase()}',
          );
        },
      ),
    );
  }
}

class _MapData {
  const _MapData({required this.mapsAvailable, required this.markers});

  final bool mapsAvailable;
  final List<CafeMarker> markers;
}

class _MapView extends StatelessWidget {
  const _MapView({
    required this.markers,
    required this.selected,
    required this.initialCamera,
    required this.onMapCreated,
    required this.onMarkerTap,
    required this.onDismiss,
    required this.countLabel,
  });

  final List<CafeMarker> markers;
  final CafeMarker? selected;
  final CameraPosition initialCamera;
  final ValueChanged<GoogleMapController> onMapCreated;
  final ValueChanged<CafeMarker> onMarkerTap;
  final VoidCallback onDismiss;
  final String countLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final topInset = MediaQuery.paddingOf(context).top;

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: initialCamera,
          style: isDark ? MapStyles.dark : MapStyles.light,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          // Keeps Google's own attribution clear of the tab bar and the card.
          padding: EdgeInsets.only(
            top: topInset + AppSpacing.jumbo,
            bottom: selected != null ? 190 : AppSpacing.bottomBarClearance,
          ),
          markers: {
            for (final marker in markers)
              Marker(
                markerId: MarkerId(marker.id),
                position: LatLng(marker.lat, marker.lng),
                onTap: () => onMarkerTap(marker),
                infoWindow:
                    InfoWindow(title: marker.name, snippet: marker.area),
              ),
          },
          onMapCreated: onMapCreated,
          onTap: (_) => onDismiss(),
        ),

        Positioned(
          top: topInset + AppSpacing.md,
          left: AppSpacing.page,
          child: _CountPill(label: countLabel),
        ),

        if (selected != null)
          Positioned(
            left: AppSpacing.page,
            right: AppSpacing.page,
            bottom: AppSpacing.bottomBarClearance,
            child: _MarkerCard(marker: selected!),
          ),
      ],
    );
  }
}

class _CountPill extends StatelessWidget {
  const _CountPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: AppRadius.pillR,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.onCard,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Preview card for the selected pin, replacing v1's custom info window.
class _MarkerCard extends StatelessWidget {
  const _MarkerCard({required this.marker});

  final CafeMarker marker;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return AppCard(
      onTap: () => context.push(Routes.cafe(marker.slug)),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  marker.name,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(color: AppColors.onCard),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Gap.xs(),
                Row(
                  children: [
                    if (marker.reviewCount > 0) ...[
                      const Icon(Icons.star_rounded,
                          size: 15, color: AppColors.accent),
                      const HGap(3),
                      Text(
                        marker.ratingAvg.toStringAsFixed(1),
                        style: const TextStyle(
                          color: AppColors.onCard,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const HGap.md(),
                    ],
                    Text(
                      marker.isOpenNow ? l10n.openNow : l10n.closed,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: marker.isOpenNow
                            ? AppColors.successOnDark
                            : AppColors.onCardMuted,
                      ),
                    ),
                    if (marker.area != null) ...[
                      const HGap.md(),
                      Flexible(
                        child: Text(
                          marker.area!,
                          style: const TextStyle(
                            color: AppColors.onCardMuted,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const HGap.sm(),
          const Icon(Icons.chevron_right, color: AppColors.accent),
        ],
      ),
    );
  }
}

/// Fallback when no Maps key is configured.
///
/// Still lists every café with its area and links out to the system maps app,
/// so the tab stays useful rather than being a dead end.
class _MapUnavailable extends StatelessWidget {
  const _MapUnavailable({required this.markers});

  final List<CafeMarker> markers;

  Future<void> _openExternally(CafeMarker marker) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1'
      '&query=${marker.lat},${marker.lng}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          AppSpacing.lg,
          AppSpacing.page,
          AppSpacing.bottomBarClearance,
        ),
        children: [
          Text(l10n.map, style: theme.textTheme.displayLarge),
          const Gap.md(),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.14),
              borderRadius: AppRadius.inputR,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline,
                    size: 18, color: AppColors.warning),
                const HGap.md(),
                Expanded(
                  child: Text(
                    'The interactive map needs a Google Maps API key. '
                    'Tap a café to open it in your maps app.',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: AppColors.warning),
                  ),
                ),
              ],
            ),
          ),
          const Gap.xl(),
          for (final marker in markers)
            AppCard(
              onTap: () => _openExternally(marker),
              padding: const EdgeInsets.all(AppSpacing.lg),
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          marker.name,
                          style: theme.textTheme.titleMedium
                              ?.copyWith(color: AppColors.onCard),
                        ),
                        const Gap.xs(),
                        Text(
                          marker.area ?? '',
                          style: const TextStyle(
                            color: AppColors.onCardMuted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.open_in_new,
                      size: 18, color: AppColors.accent),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
