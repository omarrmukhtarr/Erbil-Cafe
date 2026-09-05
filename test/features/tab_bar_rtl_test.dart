import 'package:erbilcafe/features/home/presentation/widgets/app_shell.dart';
import 'package:flutter_test/flutter_test.dart';

/// The iOS tab bar is a native UIKit view, and UIKit mirrors one only when the
/// *app bundle* is right-to-left — which ours is not, since it ships only an
/// English localization. The app's language is chosen in Dart instead, so
/// without this mapping a Kurdish or Arabic user saw a mirrored Flutter UI
/// above an unmirrored native bar, with Home stuck on the wrong side.
void main() {
  group('mirrorTabIndex', () {
    test('leaves left-to-right untouched', () {
      for (var i = 0; i < 5; i++) {
        expect(mirrorTabIndex(i, 5, isRtl: false), i);
      }
    });

    test('reverses right-to-left', () {
      expect(mirrorTabIndex(0, 5, isRtl: true), 4);
      expect(mirrorTabIndex(4, 5, isRtl: true), 0);
      expect(mirrorTabIndex(2, 5, isRtl: true), 2);
    });

    test('is its own inverse, so one function serves both directions', () {
      // The widget uses it for currentIndex and for onTap; if it were not
      // symmetric, tapping a tab would select a different one.
      for (var i = 0; i < 5; i++) {
        final there = mirrorTabIndex(i, 5, isRtl: true);
        expect(mirrorTabIndex(there, 5, isRtl: true), i);
      }
    });

    test('handles an empty bar without going out of range', () {
      expect(mirrorTabIndex(0, 0, isRtl: true), 0);
    });
  });
}
