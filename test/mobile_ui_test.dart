import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasbih_app/main.dart';
import 'package:tasbih_app/counter_widgets.dart';
import 'package:tasbih_app/reading_content.dart';
import 'package:tasbih_app/storage.dart';

import 'test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadAppFonts);
  setUp(() async {
    await saves.idle;
  });
  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    for (final size in [
      const Size(320, 568),
      const Size(360, 640),
      const Size(390, 844),
      const Size(412, 915),
      const Size(844, 390),
    ]) {
      for (final scale in [1.0, 1.3, 2.0]) {
        testWidgets('all screens $platform $size text=$scale', (tester) async {
          debugDefaultTargetPlatformOverride = platform;
          try {
            tester.view.physicalSize = size;
            tester.view.devicePixelRatio = 1;
            tester.view.padding = const FakeViewPadding(
              top: 24,
              bottom: 24,
              left: 8,
              right: 8,
            );
            tester.view.viewPadding = const FakeViewPadding(
              top: 24,
              bottom: 24,
              left: 8,
              right: 8,
            );
            tester.platformDispatcher.textScaleFactorTestValue = scale;
            addTearDown(() {
              debugDefaultTargetPlatformOverride = null;
              tester.view.reset();
              tester.platformDispatcher.clearTextScaleFactorTestValue();
            });
            SharedPreferences.setMockInitialValues({'tasbih_count': 999999999});
            saves.error.value = null;
            await tester.pumpWidget(const MyApp());
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            final counter = find.byKey(const ValueKey('counter-circle'));
            final width = tester.getSize(counter).width;
            expect(width, lessThanOrEqualTo(232));
            if (size.width >= 320) expect(width, greaterThanOrEqualTo(220));
            await tapText(tester, 'Tap to count');
            await tapText(tester, 'Reset count');
            await tapText(tester, 'Cancel');
            await tapText(tester, 'Custom');
            tester.view.viewInsets = FakeViewPadding(bottom: size.height * .4);
            await tester.pumpAndSettle();
            await tester.enterText(find.byType(TextField), '10000');
            await tapText(tester, 'Set target');
            tester.view.resetViewInsets();
            await tester.pumpAndSettle();

            await tapText(tester, 'Daily Dhikr');
            await tapText(tester, 'Fajr');
            await tapText(tester, 'Ayatul Kursi');
            final reading = tester.widget<ReadingText>(
              find.byType(ReadingText),
            );
            expect(reading.arabic, ayatulKursi);
            expect(reading.arabic.length, greaterThan(400));
            final arabicText = tester.widget<Text>(find.text(ayatulKursi));
            expect(arabicText.textDirection, TextDirection.rtl);
            expect(arabicText.style!.fontFamily, 'NotoNaskhArabic');
            final readingScroll = find.descendant(
              of: find.byType(BoundedReading),
              matching: find.byType(Scrollable),
            );
            await tester.drag(readingScroll, const Offset(0, -600));
            await tester.pumpAndSettle();
            await tapText(tester, 'Tap to count');
            await tapText(tester, 'Done');
            await tapText(tester, 'Add custom dhikr or dua');
            const name =
                'A long personal remembrance for my family and everyone I love';
            await enterField(tester, 'Dhikr or Dua', name);
            tester.view.viewInsets = FakeViewPadding(bottom: size.height * .4);
            await tester.pumpAndSettle();
            await enterField(tester, 'Target', '10000');
            await tapText(tester, 'Save');
            tester.view.resetViewInsets();
            await tester.pumpAndSettle();
            await tapText(tester, name);
            await tapText(tester, 'Tap to count');
            await back(tester);
            await tapText(tester, 'Reset session');
            await tapText(tester, 'Reset');
            await back(tester);

            await tapText(tester, 'Dhikr List');
            await enterField(tester, 'Search dhikr', 'no match');
            await tester.pumpAndSettle();
            await tapText(tester, 'Add new dhikr');
            tester.view.viewInsets = FakeViewPadding(bottom: size.height * .4);
            await tester.pumpAndSettle();
            await enterField(tester, 'Dhikr name', name);
            await tapText(tester, 'Save');
            tester.view.resetViewInsets();
            await tester.pumpAndSettle();
            await enterField(tester, 'Search dhikr', name);
            await tester.pumpAndSettle();
            await tapText(tester, name);
            await tapText(tester, 'Tap to count');
            await tapText(tester, 'Undo');
            await back(tester);
            await tapVisible(tester, find.byTooltip('Actions for $name'));
            await tapText(tester, 'Delete');
            await tapText(tester, 'Delete');
            await saves.idle;
            expect(tester.takeException(), isNull);
          } finally {
            debugDefaultTargetPlatformOverride = null;
          }
        });
      }
    }
  }
}
