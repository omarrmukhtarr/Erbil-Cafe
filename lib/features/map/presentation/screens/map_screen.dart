import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/di/injector.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_motion.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/location/location_service.dart';
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
  late Future<bool> _mapsAvailable;

  /// Pins, loaded alongside the map rather than before it. The map used to
  /// wait behind a spinner for every café to download; the platform view is
  /// the slow part to create, so it now starts at once and the pins drop in.
  List<CafeMarker>? _pins;
  Failure? _pinsFailure;

  CafeMarker? _selected;

  /// The café the card was last showing. Kept after deselecting so the card
  /// slides away with its content, instead of emptying and then moving.
  CafeMarker? _lastSelected;

  /// A marker rebuild in progress. Camera-idle can fire again while one is
  /// awaiting bitmaps, and the older one finishing last used to put back a
  /// stale set of pins.
  int _rebuildGeneration = 0;

  /// Whether the blue dot is on. It needs permission, so it stays off until
  /// location is known to be allowed — asking at the moment the map opens
  /// would spend the one permission dialog on someone who only wanted to look.
  bool _showMyLocation = false;
  bool _locating = false;
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
    _mapsAvailable = PlatformConfig.mapsConfigured();
    _loadPins();
    LocationService.instance.access().then((access) {
      if (mounted && access == LocationAccess.granted) {
        setState(() => _showMyLocation = true);
      }
    });
  }

  /// Centres the map on the phone, asking for permission if it has to.
  Future<void> _goToMyLocation() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);

    setState(() => _locating = true);
    final (access, where) = await LocationService.instance.locate();
    if (!mounted) return;
    setState(() => _locating = false);

    if (where == null) {
      final blocked = access == LocationAccess.deniedForever ||
          access == LocationAccess.serviceOff;
      messenger.showSnackBar(
        SnackBar(
          content: Text(switch (access) {
            LocationAccess.deniedForever => l10n.locationDeniedBody,
            LocationAccess.serviceOff => l10n.locationServiceOffBody,
            LocationAccess.notDetermined => l10n.locationPromptBody,
            _ => l10n.locationUnavailable,
          }),
          action: blocked
              ? SnackBarAction(
                  label: l10n.openSettings,
                  onPressed: () =>
                      LocationService.instance.openSettingsFor(access),
                )
              : null,
        ),
      );
      return;
    }

    HapticFeedback.selectionClick();
    setState(() => _showMyLocation = true);
    // Street level: close enough that the nearest cafés separate from their
    // clusters, far enough to still see a few blocks around.
    await _controller?.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(where.lat, where.lng), 15.5),
    );
  }

  Future<void> _loadPins() async {
    if (_pinsFailure != null) setState(() => _pinsFailure = null);

    try {
      final pins = await sl<CafeRepository>().markers();
      if (!mounted) return;
      _cafes = pins;
      setState(() => _pins = pins);
      if (await _mapsAvailable && mounted) await _rebuildMarkers();
    } on Failure catch (failure) {
      if (!mounted) return;
      setState(() => _pinsFailure = failure);
    }
  }

  Future<void> _rebuildMarkers() async {
    if (_cafes.isEmpty) return;
    final generation = ++_rebuildGeneration;

    final clusters = CafeClustering.cluster(_cafes, _zoom);

    // Cheap identity for "the same set of pins": if it has not changed, the
    // bitmaps and marker set can be reused as-is. Selection is part of that
    // identity because the selected pin is drawn larger.
    final signature =
        Object.hash(Object.hashAll(clusters.map((c) => c.id)), _selected?.id);
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
              selected: cafe.id == _selected?.id,
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

    if (!mounted || generation != _rebuildGeneration) return;
    setState(() => _markers = markers);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _focus(CafeMarker marker) async {
    HapticFeedback.selectionClick();
    setState(() => _selected = _lastSelected = marker);
    // Redraw so the chosen pin grows; the camera move is independent of it.
    unawaited(_rebuildMarkers());
    await _controller?.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(marker.lat, marker.lng), 16),
    );
  }

  void _clearSelection() {
    if (_selected == null) return;
    setState(() => _selected = null);
    unawaited(_rebuildMarkers());
  }

  Future<void> _onClusterTap(MapCluster cluster) async {
    final members = cluster.members;

    // Spread across a neighbourhood: zooming will separate them, so do that.
    final bounds = _boundsOf(members);
    final spread =
        (bounds.northeast.latitude - bounds.southwest.latitude).abs() +
            (bounds.northeast.longitude - bounds.southwest.longitude).abs();

    // Effectively the same spot, or already as close as clustering goes:
    // listing them is the only way to reach each one.
    if (spread < 0.0004 || _zoom >= CafeClustering.maxClusterZoom - 0.5) {
      await _showClusterSheet(members);
      return;
    }

    // A zero-area box gives fitBounds nothing to work with, so step in on the
    // centroid instead.
    final degenerate = bounds.southwest.latitude == bounds.northeast.latitude &&
        bounds.southwest.longitude == bounds.northeast.longitude;

    await _controller?.animateCamera(
      degenerate
          ? CameraUpdate.newLatLngZoom(cluster.position, _zoom + 2)
          : CameraUpdate.newLatLngBounds(bounds, 80),
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
                  l10n.cafeCount(members.length),
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
                        context.push(
                          Routes.cafe(cafe.slug),
                          extra: cafe.toPreview(),
                        );
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
      body: FutureBuilder<bool>(
        future: _mapsAvailable,
        builder: (context, snapshot) {
          // A platform-channel round trip, not a download — a few frames.
          if (!snapshot.hasData) {
            return const ColoredBox(color: AppColors.creamSunken);
          }

          // No key: list the cafés rather than crash on a map we cannot draw.
          if (!snapshot.data!) {
            final pins = _pins;
            if (pins == null) {
              return _pinsFailure == null
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.accent),
                    )
                  : SafeArea(
                      child: ErrorView(
                        failure: _pinsFailure!,
                        onRetry: _loadPins,
                      ),
                    );
            }
            return _MapUnavailable(markers: pins);
          }

          final topInset = MediaQuery.paddingOf(context).top;
          final shown = _selected ?? _lastSelected;

          return Stack(
            children: [
              GoogleMap(
                initialCameraPosition: _erbil,
                style: _theme.style,
                myLocationEnabled: _showMyLocation,
                // Google's own button sits in a corner the tab bar covers and
                // cannot ask for permission; ours does both.
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                padding: EdgeInsets.only(
                  top: topInset + AppSpacing.jumbo,
                  bottom:
                      _selected != null ? 190 : AppSpacing.bottomBarClearance,
                ),
                markers: _markers,
                onMapCreated: (controller) => _controller = controller,
                onCameraMove: (position) => _zoom = position.zoom,
                // Recluster when the camera settles, not on every frame of a
                // pan — rebuilding markers mid-gesture stutters.
                onCameraIdle: _rebuildMarkers,
                onTap: (_) => _clearSelection(),
              ),

              Positioned(
                top: topInset + AppSpacing.md,
                left: AppSpacing.page,
                right: AppSpacing.page,
                child: Row(
                  children: [
                    _Pill(
                      dark: _theme.isDark,
                      onTap: _pinsFailure == null ? null : _loadPins,
                      // The count stands in for a loading state: a small
                      // spinner in the pill while pins download, the number
                      // once they land, and a retry if they did not.
                      child: AnimatedSize(
                        duration: AppMotion.fast,
                        curve: AppMotion.standard,
                        child: SafeSwitcher(
                          duration: AppMotion.fast,
                          child: _pins != null
                              ? Text(
                                  l10n.cafeCount(_pins!.length),
                                  key: const ValueKey('count'),
                                  style: _pillText,
                                )
                              : _pinsFailure != null
                                  ? Row(
                                      key: const ValueKey('retry'),
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.refresh,
                                            size: 16, color: _pillInk),
                                        const HGap(6),
                                        Text(l10n.retry, style: _pillText),
                                      ],
                                    )
                                  : SizedBox.square(
                                      key: const ValueKey('loading'),
                                      dimension: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: _pillInk,
                                      ),
                                    ),
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
                          Icon(Icons.layers_outlined, size: 16, color: _pillInk),
                          const HGap(6),
                          Text(_theme.label, style: _pillText),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              AnimatedPositioned(
                duration: AppMotion.medium,
                curve: AppMotion.standard,
                right: AppSpacing.page,
                // Rides above the café card when one is open.
                bottom: AppSpacing.bottomBarClearance +
                    (_selected != null ? 112 : AppSpacing.md),
                child: Semantics(
                  button: true,
                  label: l10n.myLocation,
                  child: Material(
                    color: _theme.isDark ? AppColors.cardDark : AppColors.cream,
                    shape: const CircleBorder(),
                    elevation: 4,
                    shadowColor: AppColors.shadow.withValues(alpha: 0.4),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: _locating ? null : _goToMyLocation,
                      child: SizedBox.square(
                        dimension: 48,
                        child: Center(
                          child: SafeSwitcher(
                            duration: AppMotion.fast,
                            child: _locating
                                ? const SizedBox.square(
                                    key: ValueKey('locating'),
                                    dimension: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.accent,
                                    ),
                                  )
                                : const Icon(
                                    Icons.my_location_rounded,
                                    key: ValueKey('icon'),
                                    color: AppColors.accent,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // The card rises from behind the tab bar rather than appearing
              // on top of the map, so it reads as belonging to the pin that
              // was just tapped. It keeps showing the last café on the way
              // back down.
              AnimatedPositioned(
                duration: AppMotion.medium,
                curve: _selected != null ? AppMotion.spring : AppMotion.standard,
                left: AppSpacing.page,
                right: AppSpacing.page,
                bottom:
                    _selected != null ? AppSpacing.bottomBarClearance : -180,
                child: AnimatedOpacity(
                  duration: AppMotion.fast,
                  opacity: _selected != null ? 1 : 0,
                  child: shown == null
                      ? const SizedBox(height: 84)
                      : IgnorePointer(
                          ignoring: _selected == null,
                          child: AppCard(
                            onTap: () => context.push(
                              Routes.cafe(shown.slug),
                              extra: shown.toPreview(),
                            ),
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            // Crossfades when a different pin is tapped while
                            // the card is already up.
                            child: SafeSwitcher(
                              duration: AppMotion.fast,
                              child: _CafeRow(
                                key: ValueKey(shown.id),
                                marker: shown,
                                showChevron: true,
                              ),
                            ),
                          ),
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Color get _pillInk => _theme.isDark ? AppColors.onCard : AppColors.onCream;

  TextStyle get _pillText => TextStyle(
        color: _pillInk,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      );
}

/// Shared row for the selected-pin card and the cluster sheet.
class _CafeRow extends StatelessWidget {
  const _CafeRow({required this.marker, this.showChevron = false, super.key});

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

/// The style sheet's contents, for a widget test.
///
/// The picker is an implementation detail of this screen and stays private;
/// this is the one door into it, because the layout bug it had — the selected
/// swatch collapsing to the width of its tick — is invisible to anything that
/// does not measure the rendered boxes.
@visibleForTesting
Widget mapThemePickerForTest(MapTheme current) => _ThemePicker(current: current);

/// Restores v1's map-theme picker, which the first rebuild had dropped.
///
/// The swatches are laid out on a grid rather than a [Wrap] of fixed-width
/// boxes. The `Wrap` version collapsed the *selected* swatch to the width of
/// its tick: a `Container` with no child fills the loose constraints a `Column`
/// hands it, and one with a child shrinks to fit that child — so selecting a
/// theme visibly shrank it to a sliver while its neighbours stayed full width.
class _ThemePicker extends StatelessWidget {
  const _ThemePicker({required this.current});

  final MapTheme current;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

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
            Text(l10n.mapStyle, style: theme.textTheme.titleLarge),
            const Gap.lg(),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.md,
              // Swatch plus its caption. Tighter than square, because the
              // caption is one line and a square tile wastes half the sheet.
              childAspectRatio: 0.82,
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
      label: option.label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: AnimatedContainer(
                duration: AppMotion.fast,
                curve: AppMotion.standard,
                decoration: BoxDecoration(
                  borderRadius: AppRadius.inputR,
                  border: Border.all(
                    color:
                        selected ? AppColors.accent : theme.colorScheme.outline,
                    width: selected ? 2.5 : 1,
                  ),
                  // A ring around the whole swatch says "this one" without
                  // covering the colour it is there to show.
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: AppColors.accent.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : const [],
                ),
                child: ClipRRect(
                  borderRadius: AppRadius.inputR,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ColoredBox(color: option.swatch),

                      // Two strokes in the style's own road colour: enough for
                      // a flat rectangle to read as a piece of map.
                      CustomPaint(painter: _SwatchRoads(option: option)),

                      // The tick sits in the corner rather than the middle, so
                      // it never hides the colour being chosen.
                      PositionedDirectional(
                        end: 4,
                        top: 4,
                        child: AnimatedScale(
                          duration: AppMotion.fast,
                          curve: AppMotion.spring,
                          scale: selected ? 1 : 0,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: AppColors.accent,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(2),
                            child: const Icon(Icons.check_rounded,
                                color: Colors.white, size: 13),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
    );
  }
}

/// Two roads across a swatch, drawn in that style's own road colour.
///
/// A flat rectangle of beige tells you very little about what the map will
/// look like; the same rectangle with a road through it is instantly a map.
class _SwatchRoads extends CustomPainter {
  const _SwatchRoads({required this.option});

  final MapTheme option;

  @override
  void paint(Canvas canvas, Size size) {
    final road = Paint()
      ..color = option.roadColor
      ..strokeWidth = size.width * 0.09
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas
      ..drawLine(
        Offset(-2, size.height * 0.68),
        Offset(size.width + 2, size.height * 0.34),
        road,
      )
      ..drawLine(
        Offset(size.width * 0.62, -2),
        Offset(size.width * 0.34, size.height + 2),
        road..strokeWidth = size.width * 0.06,
      );
  }

  @override
  bool shouldRepaint(_SwatchRoads oldDelegate) => oldDelegate.option != option;
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
