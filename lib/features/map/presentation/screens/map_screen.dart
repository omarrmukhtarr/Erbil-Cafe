import 'dart:math' as math;

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
import '../../../../core/storage/app_preferences.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_states.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../cafes/data/models/cafe.dart';
import '../../../cafes/data/repositories/cafe_repository.dart';
import 'cafe_clustering.dart';
import 'map_markers.dart';
import 'map_style.dart';

/// The map.
///
/// v1 hardcoded 15 cafés and embedded a Maps key in the source; pins now come
/// from the API and the key lives in platform config.
///
/// Pins are **clustered**. Plotting every café individually works at 15 and
/// collapses at 300 — the city becomes a wall of identical dots with no sense
/// of where cafés actually concentrate. Bubbles carry a count, grow and darken
/// with density, and split apart as you zoom.
///
/// The clustering is done in [CafeClustering] rather than by Google's own
/// ClusterManager, which exposes no way to style its bubbles — they render in
/// the SDK's default blue and fight the palette. Tapping a bubble zooms to its
/// members; once they are already at street level a sheet lists them, so no
/// café is ever stuck behind a pin that cannot be opened.
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
  late MapTheme _theme;
  double _zoom = _erbil.zoom;

  List<CafeMarker> _cafes = const [];
  Set<Marker> _markers = const {};

  /// Rebuilding markers touches the platform channel, so skip it when the
  /// camera moved without changing which pins would merge.
  int _lastClusterSignature = -1;

  @override
  void initState() {
    super.initState();
    _theme = MapTheme.fromName(sl<AppPreferences>().mapTheme);
    _future = _load();
  }

  Future<_MapData> _load() async {
    final results = await Future.wait([
      PlatformConfig.mapsConfigured(),
      sl<CafeRepository>().markers(),
    ]);

    final data = _MapData(
      mapsAvailable: results[0] as bool,
      markers: results[1] as List<CafeMarker>,
    );

    _cafes = data.markers;
    if (data.mapsAvailable && mounted) {
      await _rebuildMarkers();
    }
    return data;
  }

  Future<void> _rebuildMarkers() async {
    if (_cafes.isEmpty) return;

    final clusters = CafeClustering.cluster(_cafes, _zoom);

    // Cheap identity for "the same set of pins": if it has not changed, the
    // bitmaps and marker set can be reused as-is.
    final signature = Object.hashAll(clusters.map((c) => c.id));
    if (signature == _lastClusterSignature && _markers.isNotEmpty) return;
    _lastClusterSignature = signature;

    final ratio = MediaQuery.devicePixelRatioOf(context);
    final markers = <Marker>{};

    for (final cluster in clusters) {
      if (cluster.isSingle) {
        final cafe = cluster.first;
        markers.add(
          Marker(
            markerId: MarkerId(cafe.id),
            position: cluster.position,
            icon: await MapMarkers.pin(
              open: cafe.isOpenNow,
              devicePixelRatio: ratio,
            ),
            anchor: const Offset(0.5, 1),
            consumeTapEvents: true,
            onTap: () => _focus(cafe),
          ),
        );
      } else {
        markers.add(
          Marker(
            markerId: MarkerId(cluster.id),
            position: cluster.position,
            icon: await MapMarkers.cluster(
              count: cluster.count,
              devicePixelRatio: ratio,
            ),
            anchor: const Offset(0.5, 0.5),
            consumeTapEvents: true,
            onTap: () => _onClusterTap(cluster),
          ),
        );
      }
    }

    if (!mounted) return;
    setState(() => _markers = markers);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _focus(CafeMarker marker) async {
    setState(() => _selected = marker);
    await _controller?.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(marker.lat, marker.lng), 16),
    );
  }

  Future<void> _onClusterTap(MapCluster cluster) async {
    final members = cluster.members;

    // Spread across a neighbourhood: zooming will separate them, so do that.
    final bounds = _boundsOf(members);
    final spread = (bounds.northeast.latitude - bounds.southwest.latitude).abs() +
        (bounds.northeast.longitude - bounds.southwest.longitude).abs();

    // Effectively the same spot, or already as close as clustering goes:
    // listing them is the only way to reach each one.
    if (spread < 0.0004 || _zoom >= CafeClustering.maxClusterZoom - 0.5) {
      await _showClusterSheet(members);
      return;
    }

    await _controller?.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 80),
    );
  }

  static LatLngBounds _boundsOf(List<CafeMarker> members) {
    var minLat = members.first.lat;
    var maxLat = members.first.lat;
    var minLng = members.first.lng;
    var maxLng = members.first.lng;

    for (final m in members) {
      minLat = math.min(minLat, m.lat);
      maxLat = math.max(maxLat, m.lat);
      minLng = math.min(minLng, m.lng);
      maxLng = math.max(maxLng, m.lng);
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  Future<void> _showClusterSheet(List<CafeMarker> members) async {
    final l10n = AppLocalizations.of(context);

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.6,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  0,
                  AppSpacing.page,
                  AppSpacing.md,
                ),
                child: Text(
                  '${members.length} ${l10n.allCafes.toLowerCase()}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Flexible(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.page,
                    0,
                    AppSpacing.page,
                    AppSpacing.xl,
                  ),
                  shrinkWrap: true,
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    final cafe = members[index];
                    return AppCard(
                      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      onTap: () {
                        Navigator.of(context).pop();
                        context.push(Routes.cafe(cafe.slug));
                      },
                      child: _CafeRow(marker: cafe),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickTheme() async {
    final chosen = await showModalBottomSheet<MapTheme>(
      context: context,
      showDragHandle: true,
      builder: (context) => _ThemePicker(current: _theme),
    );

    if (chosen == null || !mounted) return;

    setState(() => _theme = chosen);
    await sl<AppPreferences>().setMapTheme(chosen.name);
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

          final topInset = MediaQuery.paddingOf(context).top;

          return Stack(
            children: [
              GoogleMap(
                initialCameraPosition: _erbil,
                style: _theme.style,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                padding: EdgeInsets.only(
                  top: topInset + AppSpacing.jumbo,
                  bottom: _selected != null
                      ? 190
                      : AppSpacing.bottomBarClearance,
                ),
                markers: _markers,
                onMapCreated: (controller) => _controller = controller,
                onCameraMove: (position) => _zoom = position.zoom,
                // Recluster when the camera settles, not on every frame of a
                // pan — rebuilding markers mid-gesture stutters.
                onCameraIdle: _rebuildMarkers,
                onTap: (_) => setState(() => _selected = null),
              ),

              Positioned(
                top: topInset + AppSpacing.md,
                left: AppSpacing.page,
                right: AppSpacing.page,
                child: Row(
                  children: [
                    _Pill(
                      dark: _theme.isDark,
                      child: Text(
                        '${data.markers.length} ${l10n.allCafes.toLowerCase()}',
                        style: TextStyle(
                          color: _theme.isDark
                              ? AppColors.onCard
                              : AppColors.onCream,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    _Pill(
                      dark: _theme.isDark,
                      onTap: _pickTheme,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.layers_outlined,
                            size: 16,
                            color: _theme.isDark
                                ? AppColors.onCard
                                : AppColors.onCream,
                          ),
                          const HGap(6),
                          Text(
                            _theme.label,
                            style: TextStyle(
                              color: _theme.isDark
                                  ? AppColors.onCard
                                  : AppColors.onCream,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              if (_selected != null)
                Positioned(
                  left: AppSpacing.page,
                  right: AppSpacing.page,
                  bottom: AppSpacing.bottomBarClearance,
                  child: AppCard(
                    onTap: () => context.push(Routes.cafe(_selected!.slug)),
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: _CafeRow(marker: _selected!, showChevron: true),
                  ),
                ),
            ],
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

/// Shared row for the selected-pin card and the cluster sheet.
class _CafeRow extends StatelessWidget {
  const _CafeRow({required this.marker, this.showChevron = false});

  final CafeMarker marker;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Row(
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
              Wrap(
                spacing: AppSpacing.md,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (marker.reviewCount > 0)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
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
                      ],
                    ),
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
                  if (marker.area != null)
                    Text(
                      marker.area!,
                      style: const TextStyle(
                          color: AppColors.onCardMuted, fontSize: 13),
                    ),
                ],
              ),
            ],
          ),
        ),
        if (showChevron) ...[
          const HGap.sm(),
          const Icon(Icons.chevron_right, color: AppColors.accent),
        ],
      ],
    );
  }
}

/// A control floating over the map, legible on either a light or dark style.
class _Pill extends StatelessWidget {
  const _Pill({required this.child, required this.dark, this.onTap});

  final Widget child;
  final bool dark;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: dark ? AppColors.cardDark : AppColors.cream,
      borderRadius: AppRadius.pillR,
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      shadowColor: AppColors.shadow.withValues(alpha: 0.4),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm + 1,
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Restores v1's map-theme picker, which the first rebuild had dropped.
class _ThemePicker extends StatelessWidget {
  const _ThemePicker({required this.current});

  final MapTheme current;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          0,
          AppSpacing.page,
          AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Map style', style: theme.textTheme.titleLarge),
            const Gap.lg(),
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: [
                for (final option in MapTheme.values)
                  _ThemeSwatch(
                    option: option,
                    selected: option == current,
                    onTap: () => Navigator.of(context).pop(option),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeSwatch extends StatelessWidget {
  const _ThemeSwatch({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final MapTheme option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.inputR,
        child: SizedBox(
          width: 84,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 58,
                decoration: BoxDecoration(
                  color: option.swatch,
                  borderRadius: AppRadius.inputR,
                  border: Border.all(
                    color: selected
                        ? AppColors.accent
                        : theme.colorScheme.outline,
                    width: selected ? 2.5 : 1,
                  ),
                ),
                child: selected
                    ? const Icon(Icons.check_circle,
                        color: AppColors.accent, size: 22)
                    : null,
              ),
              const Gap.sm(),
              Text(
                option.label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: selected ? AppColors.accent : null,
                  fontWeight: selected ? FontWeight.w700 : null,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Fallback when no Maps key is configured.
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
                  Expanded(child: _CafeRow(marker: marker)),
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
