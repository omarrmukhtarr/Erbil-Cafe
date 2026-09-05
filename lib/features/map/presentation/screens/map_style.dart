/// Google Maps styles.
///
/// v1 carried a 965-line `map_style.dart` with six themes, of which the UI only
/// ever used two. These are the dark and light variants, tuned to the app's own
/// surfaces so the map does not look pasted in.
abstract final class MapStyles {
  /// Matches the app's #141921 ground.
  static const dark = '''
[
  {"elementType":"geometry","stylers":[{"color":"#141921"}]},
  {"elementType":"labels.icon","stylers":[{"visibility":"off"}]},
  {"elementType":"labels.text.fill","stylers":[{"color":"#aeaeae"}]},
  {"elementType":"labels.text.stroke","stylers":[{"color":"#141921"}]},
  {"featureType":"administrative","elementType":"geometry","stylers":[{"color":"#52555a"}]},
  {"featureType":"administrative.land_parcel","stylers":[{"visibility":"off"}]},
  {"featureType":"poi","elementType":"labels.text.fill","stylers":[{"color":"#9a8478"}]},
  {"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#17191f"}]},
  {"featureType":"road","elementType":"geometry.fill","stylers":[{"color":"#231715"}]},
  {"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#8a8a8a"}]},
  {"featureType":"road.arterial","elementType":"geometry","stylers":[{"color":"#2c2c2c"}]},
  {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#30221f"}]},
  {"featureType":"road.highway","elementType":"labels.text.fill","stylers":[{"color":"#d17842"}]},
  {"featureType":"transit","elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},
  {"featureType":"water","elementType":"geometry","stylers":[{"color":"#0e1116"}]},
  {"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#3d3d3d"}]}
]
''';

  /// Warm, low-contrast daylight map on the cream side of the palette.
  static const light = '''
[
  {"elementType":"geometry","stylers":[{"color":"#f7f4f0"}]},
  {"elementType":"labels.icon","stylers":[{"visibility":"off"}]},
  {"elementType":"labels.text.fill","stylers":[{"color":"#6b6f76"}]},
  {"elementType":"labels.text.stroke","stylers":[{"color":"#f7f4f0"}]},
  {"featureType":"administrative.land_parcel","stylers":[{"visibility":"off"}]},
  {"featureType":"poi","elementType":"geometry","stylers":[{"color":"#f1ebe3"}]},
  {"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#e4ecdf"}]},
  {"featureType":"road","elementType":"geometry","stylers":[{"color":"#ffffff"}]},
  {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#e6ccb2"}]},
  {"featureType":"road.highway","elementType":"labels.text.fill","stylers":[{"color":"#b25e2b"}]},
  {"featureType":"water","elementType":"geometry","stylers":[{"color":"#c9d8dd"}]}
]
''';
}
