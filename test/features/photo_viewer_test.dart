import 'package:erbilcafe/core/widgets/photo_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';

/// The full-screen photo viewer a café's photos now open into.
///
/// A café's photos used to be 150×128 thumbnails with nothing behind the tap,
/// which is the whole reason this screen exists.
void main() {
  const photos = [
    PhotoSource(url: 'https://example.test/1.jpg', caption: 'The rooftop'),
    PhotoSource(url: 'https://example.test/2.jpg'),
    PhotoSource(url: 'https://example.test/3.jpg'),
  ];

  /// Advances past the route transition.
  ///
  /// Not `pumpAndSettle`: with no network in a widget test the images sit on
  /// their spinner placeholder forever, and a spinner never settles.
  /// The first pump schedules the route, the second runs its transition out.
  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
  }

  /// A page with a button that opens the viewer, as a café page does.
  Future<void> pumpOpener(WidgetTester tester,
      {int initialIndex = 0, List<PhotoSource> list = photos}) async {
    await tester.pumpApp(
      Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => PhotoViewer.open(
              context,
              photos: list,
              initialIndex: initialIndex,
            ),
            child: const Text('open photos'),
          ),
        ),
      ),
    );
  }

  testWidgets('a tap opens the viewer on the photo that was tapped',
      (tester) async {
    await pumpOpener(tester, initialIndex: 1);

    expect(find.byType(PhotoViewer), findsNothing);

    await tester.tap(find.text('open photos'));
    await settle(tester);

    expect(find.byType(PhotoViewer), findsOneWidget);
    // Counter is 1-based, so the second photo reads "2 / 3".
    expect(find.text('2 / 3'), findsOneWidget);
  });

  testWidgets('swiping moves to the next photo', (tester) async {
    await pumpOpener(tester);
    await tester.tap(find.text('open photos'));
    await settle(tester);

    expect(find.text('1 / 3'), findsOneWidget);

    await tester.drag(find.byType(PageView), const Offset(-400, 0));
    await settle(tester);

    expect(find.text('2 / 3'), findsOneWidget);
  });

  testWidgets('the close button dismisses it', (tester) async {
    await pumpOpener(tester);
    await tester.tap(find.text('open photos'));
    await settle(tester);

    await tester.tap(find.byIcon(Icons.close_rounded));
    await settle(tester);

    expect(find.byType(PhotoViewer), findsNothing);
  });

  testWidgets('dragging down far enough dismisses it, a short drag does not',
      (tester) async {
    await pumpOpener(tester);
    await tester.tap(find.text('open photos'));
    await settle(tester);

    // Short drag: springs back rather than losing the photo on a mis-swipe.
    await tester.drag(find.byType(PageView), const Offset(0, 40));
    await settle(tester);
    expect(find.byType(PhotoViewer), findsOneWidget);

    await tester.drag(find.byType(PageView), const Offset(0, 300));
    await settle(tester);
    expect(find.byType(PhotoViewer), findsNothing);
  });

  testWidgets('a single photo gets no counter and still opens', (tester) async {
    await pumpOpener(tester, list: const [
      PhotoSource(url: 'https://example.test/only.jpg'),
    ]);
    await tester.tap(find.text('open photos'));
    await settle(tester);

    expect(find.byType(PhotoViewer), findsOneWidget);
    expect(find.text('1 / 1'), findsNothing);
  });

  testWidgets('an empty gallery opens nothing rather than a blank screen',
      (tester) async {
    await pumpOpener(tester, list: const []);
    await tester.tap(find.text('open photos'));
    await settle(tester);

    expect(find.byType(PhotoViewer), findsNothing);
  });

  testWidgets("a photo's caption is shown over it", (tester) async {
    await pumpOpener(tester);
    await tester.tap(find.text('open photos'));
    await settle(tester);

    expect(find.text('The rooftop'), findsOneWidget);
  });
}
