import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasbih_app/main.dart';
import 'package:tasbih_app/counter_widgets.dart';
import 'package:tasbih_app/dhikr_target_choices.dart';
import 'package:tasbih_app/storage.dart';

import 'test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadAppFonts);
  for (final width in [320.0, 360.0, 390.0, 412.0]) {
    for (final scale in [1.0, 1.3, 2.0]) {
      testWidgets('Dhikr selector width=$width text=$scale', (tester) async {
        await saves.idle;
        tester.view.physicalSize = Size(width, 568);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(() {
          tester.view.reset();
          tester.platformDispatcher.clearTextScaleFactorTestValue();
        });
        SharedPreferences.setMockInitialValues({});
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();
        await tapText(tester, 'Dhikr List');
        await tapText(tester, 'Astaghfirullah');
        final selector = find.byType(DhikrTargetChoices);
        expect(selector, findsOneWidget);
        final scroll = find
            .descendant(
              of: find.byKey(const ValueKey('dhikr-counter-scroll')),
              matching: find.byType(Scrollable),
            )
            .first;
        Rect rect(Finder f) => tester
            .getRect(f)
            .shift(
              Offset(0, tester.state<ScrollableState>(scroll).position.pixels),
            );
        List<Rect> boxes() => List.generate(
          4,
          (i) => rect(
            find
                .descendant(
                  of: find.byKey(ValueKey('dhikr-target-$i')),
                  matching: find.byType(Material),
                )
                .first,
          ),
        );
        final initial = boxes();
        final circle = find.byKey(const ValueKey('counter-circle'));
        final initialCircle = rect(circle);
        void check() {
          final current = boxes();
          for (var i = 0; i < 4; i++) {
            expect(current[i].height, greaterThanOrEqualTo(48));
            expect(current[i].height, closeTo(current[0].height, .01));
            expect(current[i].top, closeTo(initial[i].top, .01));
            expect(current[i].left, closeTo(initial[i].left, .01));
            expect(current[i].width, closeTo(initial[i].width, .01));
            expect(current[i].height, closeTo(initial[i].height, .01));
            final label = find.descendant(
              of: find.byKey(ValueKey('dhikr-target-$i')),
              matching: find.byType(Text),
            );
            final paragraph = tester.renderObject<RenderParagraph>(label);
            expect(paragraph.didExceedMaxLines, isFalse);
            expect(rect(label).center.dy, closeTo(current[i].center.dy, .01));
            expect(rect(label).center.dx, closeTo(current[i].center.dx, .01));
          }
          for (final pair in [
            [0, 1],
            [2, 3],
          ]) {
            expect(current[pair[0]].top, closeTo(current[pair[1]].top, .01));
            expect(
              current[pair[0]].bottom,
              closeTo(current[pair[1]].bottom, .01),
            );
          }
          expect(
            (current.first.left + current.last.right) / 2,
            closeTo(width / 2, .01),
          );
          final horizontalGap = current[1].left - current[0].right;
          expect(horizontalGap, greaterThanOrEqualTo(8));
          if ((current[2].top - current[0].top).abs() < .01) {
            for (var i = 1; i < 4; i++) {
              expect(current[i].top, closeTo(current[0].top, .01));
              expect(current[i].bottom, closeTo(current[0].bottom, .01));
              expect(
                current[i].left - current[i - 1].right,
                closeTo(horizontalGap, .01),
              );
            }
          } else {
            for (final box in current) {
              expect(box.width, closeTo(current[0].width, .01));
            }
            expect(current[2].left, closeTo(current[0].left, .01));
            expect(current[3].right, closeTo(current[1].right, .01));
            expect(current[2].top - current[0].bottom, closeTo(8, .01));

            expect(
              current[3].left - current[2].right,
              closeTo(horizontalGap, .01),
            );
          }
          expect(rect(circle).center.dx, closeTo(width / 2, .01));
          expect(rect(circle).top, closeTo(initialCircle.top, .01));
          expect(rect(circle).top - current.last.bottom, closeTo(24, .01));
          expect(tester.takeException(), isNull);
        }

        check();
        for (final label in ['100', '33', 'Custom', 'Free count', '33']) {
          await tapVisible(tester, find.widgetWithText(ChoiceChip, label));
          if (label == 'Custom') {
            await tester.enterText(find.byType(TextField), '10000');
            await tapText(tester, 'Set target');
          }
          expect(
            tester.widget<CounterSurface>(find.byType(CounterSurface)).target,
            label == 'Custom'
                ? 10000
                : label == 'Free count'
                ? null
                : int.parse(label),
          );
          check();
        }
        await tapText(tester, 'Tap to count');
        await tapText(tester, 'Undo');
        expect(
          tester.widget<CounterSurface>(find.byType(CounterSurface)).count,
          0,
        );
        await saves.idle;
      });
    }
  }
}
