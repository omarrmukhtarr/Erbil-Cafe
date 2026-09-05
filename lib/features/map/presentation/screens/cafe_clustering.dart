import 'dart:math' as math;

import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../cafes/data/models/cafe.dart';

/// One pin on the map: either a single café or several collapsed together.
class MapCluster {
  const MapCluster({required this.position, required this.members});

  final LatLng position;
  final List<CafeMarker> members;

  bool get isSingle => members.length == 1;
  int get count => members.length;

  CafeMarker get first => members.first;

  /// Stable across rebuilds so Google Maps animates rather than re-adding.
  String get id => isSingle
      ? first.id
      : 'cluster-${members.map((m) => m.id).reduce((a, b) => a.compareTo(b) < 0 ? a : b)}'
          '-${members.length}';
}

/// Grid clustering in Web Mercator space.
///
/// Google Maps' own ClusterManager would do this natively, but it exposes no
/// way to style the cluster icon — the bubbles come out as the SDK's default
/// blue, which fights the palette. Doing it here costs one O(n) pass per camera
/// move and, in exchange, the clusters are ours to draw.
///
/// Grid cells are sized in screen pixels, so markers merge when they would
/// actually overlap rather than at some fixed distance in degrees that means
/// something different at every latitude and zoom.
abstract final class CafeClustering {
  /// Cell size in logical pixels. Roughly two pin-widths, so pins separate
  /// as soon as they stop colliding.
  static const _cellPixels = 88.0;

  /// Beyond this the map is showing a single street; keep every café distinct
  /// so nothing is hidden behind a bubble the user cannot open.
  static const maxClusterZoom = 17.0;

  static List<MapCluster> cluster(List<CafeMarker> cafes, double zoom) {
    if (cafes.isEmpty) return const [];

    if (zoom >= maxClusterZoom) {
      return [
        for (final cafe in cafes)
          MapCluster(position: LatLng(cafe.lat, cafe.lng), members: [cafe]),
      ];
    }

    // World size in pixels at this zoom, per the standard tile scheme.
    final worldPixels = 256.0 * math.pow(2, zoom);
    final buckets = <({int x, int y}), List<CafeMarker>>{};

    for (final cafe in cafes) {
      final point = _project(cafe.lat, cafe.lng, worldPixels);
      final key = (
        x: (point.dx / _cellPixels).floor(),
        y: (point.dy / _cellPixels).floor(),
      );
      buckets.putIfAbsent(key, () => []).add(cafe);
    }

    return [
      for (final members in buckets.values)
        MapCluster(position: _centroid(members), members: members),
    ];
  }

  /// Web Mercator. Latitude is clamped to the projection's valid range —
  /// beyond ±85.05° the formula diverges.
  static _Point _project(double lat, double lng, double worldPixels) {
    final clamped = lat.clamp(-85.05112878, 85.05112878);
    final sinLat = math.sin(clamped * math.pi / 180);

    return _Point(
      (lng + 180) / 360 * worldPixels,
      (0.5 - math.log((1 + sinLat) / (1 - sinLat)) / (4 * math.pi)) * worldPixels,
    );
  }

  /// Mean position of the members, so the bubble sits among its cafés rather
  /// than in the corner of its grid cell.
  static LatLng _centroid(List<CafeMarker> members) {
    if (members.length == 1) {
      return LatLng(members.first.lat, members.first.lng);
    }

    var lat = 0.0;
    var lng = 0.0;
    for (final m in members) {
      lat += m.lat;
      lng += m.lng;
    }
    return LatLng(lat / members.length, lng / members.length);
  }
}

class _Point {
  const _Point(this.dx, this.dy);
  final double dx;
  final double dy;
}
