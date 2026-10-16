import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasbih_app/main.dart';
import 'package:tasbih_app/counter_widgets.dart';
import 'package:tasbih_app/storage.dart';

import 'test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadAppFonts);
  for (final size in [
    const Size(320, 568),
    const Size(360, 640),
    const Size(390, 844),
    const Size(412, 915),
    const Size(844, 390),
  ]) {
    for (final scale in [1.0, 1.3, 2.0]) {
      testWidgets('counter geometry stable $size text=$scale', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(() {
          tester.view.reset();
          tester.platformDispatcher.clearTextScaleFactorTestValue();
        });
        SharedPreferences.setMockInitialValues({'zikir_layout_count': 2});
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(fontFamily: 'Lato'),
            home: ZikirTasbihPage(
              zikir: const ZikirItem(
                id: 'layout',
                name: 'SubhanAllah',
                arabic: 'سُبْحَانَ اللَّهِ',
                transliteration: 'SubhanAllah',
                meaning: 'Glory be to Allah.',
                target: 3,
              ),
              onNext: () {},
            ),
          ),
        );
        await tester.pumpAndSettle();
        final circle = find.byKey(const ValueKey('counter-circle'));
        final reading = find.byType(DhikrReadingCard);
        final scroll = find
            .descendant(
              of: find.byKey(const ValueKey('dhikr-counter-scroll')),
              matching: find.byType(Scrollable),
            )
            .first;
        Rect contentRect(Finder finder) {
          final offset = tester.state<ScrollableState>(scroll).position.pixels;
          return tester.getRect(finder).shift(Offset(0, offset));
        }

        final initialCircle = contentRect(circle);
        final initialReading = contentRect(reading);
        expect(initialCircle.width, 232);
        expect(initialCircle.center.dx, closeTo(size.width / 2, .01));
        expect(initialReading.center.dx, closeTo(size.width / 2, .01));
        expect(initialReading.width, size.width - 40);
        void checkGeometry() {
          expect(contentRect(circle), initialCircle);
          expect(contentRect(reading), initialReading);
          expect(tester.takeException(), isNull);
        }

        await tapText(tester, 'Tap to count'); // target
        checkGeometry();
        expect(find.text('Alhamdulillah! Completed.'), findsOneWidget);
        await tapText(tester, 'Undo'); // below
        checkGeometry();
        expect(find.text('Done').hitTestable(), findsNothing);
        await tapText(tester, 'Tap to count'); // target
        checkGeometry();
        await tapText(tester, 'Tap to count'); // above
        checkGeometry();
        expect(
          tester.widget<CounterSurface>(find.byType(CounterSurface)).count,
          4,
        );
        await tapText(tester, 'Undo');
        checkGeometry();
        await tapText(tester, 'Next dhikr');
        await saves.idle;
      });
    }
  }
}
