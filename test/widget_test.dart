import 'package:flutter/material.dart';
import 'package:vibration_platform_interface/vibration_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasbih_app/main.dart';
import 'package:tasbih_app/counter_widgets.dart';
import 'package:tasbih_app/storage.dart';

import 'test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadAppFonts);
  setUp(() async {
    await saves.idle;
    SharedPreferences.setMockInitialValues({});
    saves.error.value = null;
  });
  tearDown(() async {
    await saves.idle;
    CountingFeedback.instance.vibration = false;
  });

  testWidgets(
    'home rapid taps, undo, target changes and reset persist in order',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      for (var i = 0; i < 40; i++) {
        await tester.tap(find.text('Tap to count'));
      }
      await tester.pumpAndSettle();
      expect(find.text('Continue counting'), findsNothing);
      expect(
        tester.widget<CounterSurface>(find.byType(CounterSurface)).count,
        40,
      );
      await tapText(tester, 'Undo');
      await tapText(tester, '100');
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('tasbih_count'), 39);
      expect(prefs.getInt('tasbih_target'), 100);
      await tapText(tester, 'Reset count');
      await tapText(tester, 'Cancel');
      expect(prefs.getInt('tasbih_count'), 39);
      await tapText(tester, 'Reset count');
      await tapText(tester, 'Reset');
      expect(prefs.getInt('tasbih_count'), 0);
      await tapVisible(tester, find.widgetWithText(ChoiceChip, 'Free count'));
      expect(prefs.getBool('tasbih_free_count'), true);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      expect(
        tester.widget<CounterSurface>(find.byType(CounterSurface)).target,
        null,
      );
    },
  );

  testWidgets('target bottom sheet validates and saves 10000', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    await tapText(tester, 'Custom');
    await tester.enterText(find.byType(TextField), '0');
    await tapText(tester, 'Set target');
    expect(find.text('Enter a whole number from 1 to 10000.'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '10000');
    await tapText(tester, 'Set target');
    expect(
      (await SharedPreferences.getInstance()).getInt('tasbih_target'),
      10000,
    );
  });

  for (final home in [true, false]) {
    testWidgets('milestone once per crossing, including undo: home=$home', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({'tasbih_target': 1});
      final durations = <int>[];
      final previousPlatform = VibrationPlatform.instance;
      VibrationPlatform.instance = _RecordingVibration(durations);
      addTearDown(() => VibrationPlatform.instance = previousPlatform);
      await tester.pumpWidget(
        home
            ? const MyApp()
            : const MaterialApp(
                home: ZikirTasbihPage(
                  zikir: ZikirItem(
                    id: 'test',
                    name: 'Test',
                    arabic: 'ذكر',
                    target: 1,
                  ),
                ),
              ),
      );
      await tester.pumpAndSettle();
      CountingFeedback.instance.vibration = true;
      await tapText(tester, 'Tap to count');
      await tapText(tester, 'Undo');
      await tapText(tester, 'Tap to count');
      await tapText(tester, 'Tap to count');
      expect(durations, [200, 200, 30]);
      expect(find.text('Continue counting'), findsNothing);
      expect(
        tester.widget<CounterSurface>(find.byType(CounterSurface)).count,
        2,
      );
      for (final indicator in tester.widgetList<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      )) {
        expect(indicator.value, inInclusiveRange(0, 1));
      }
    });
  }

  testWidgets(
    'manual sessions survive reopening and resetting Fajr leaves Zuhr intact',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'zikir_astaghfirullah_count': 3,
        'zikir_astaghfirullah_completed': true,
        'zikir_zuhr_astaghfirullah_count': 2,
      });
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      await tapText(tester, 'Daily Dhikr');
      await tapText(tester, 'Fajr');
      expect(
        find.text('Your progress stays saved until you reset this session.'),
        findsOneWidget,
      );
      await tester.pump(const Duration(days: 2));
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('zikir_astaghfirullah_count'), 3);
      await tapText(tester, 'Reset session');
      await tapText(tester, 'Cancel');
      expect(prefs.getInt('zikir_astaghfirullah_count'), 3);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      await tapText(tester, 'Daily Dhikr');
      await tapText(tester, 'Fajr');
      await tapText(tester, 'Reset session');
      await tapText(tester, 'Reset');
      expect(prefs.getInt('zikir_astaghfirullah_count'), 0);
      expect(prefs.getBool('zikir_astaghfirullah_completed'), false);
      expect(prefs.getInt('zikir_zuhr_astaghfirullah_count'), 2);
    },
  );

  testWidgets('daily completion preserves Next and Done and supports reset', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    await tapText(tester, 'Daily Dhikr');
    await tapText(tester, 'Fajr');
    await tapText(tester, 'Astaghfirullah');
    for (var i = 0; i < 3; i++) {
      await tapText(tester, 'Tap to count');
    }
    expect(find.text('Alhamdulillah! Completed.'), findsOneWidget);
    await tapText(tester, 'Next dhikr');
    expect(find.text('SubhanAllah'), findsWidgets);
    await back(tester);
    await tapText(tester, 'Astaghfirullah');
    await tapText(tester, 'Reset count');
    await tapText(tester, 'Reset');
    expect(
      (await SharedPreferences.getInstance()).getBool(
        'zikir_astaghfirullah_completed',
      ),
      false,
    );
  });

  testWidgets('same-name library entries delete independently through UI', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'custom_dhikr_names': ['Duplicate', 'Duplicate'],
      'zikir_custom_Duplicate_count': 8,
      'dhikr_target_custom_Duplicate': 100,
    });
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    await tapText(tester, 'Dhikr List');
    await tester.enterText(find.byType(TextField), 'Duplicate');
    await tester.pumpAndSettle();
    expect(
      find.byWidgetPredicate((w) => w is Text && w.data == 'Duplicate'),
      findsNWidgets(2),
    );
    await tapVisible(tester, find.byTooltip('Actions for Duplicate').first);
    await tapText(tester, 'Delete');
    await tapText(tester, 'Delete');
    expect(
      find.byWidgetPredicate((w) => w is Text && w.data == 'Duplicate'),
      findsOneWidget,
    );
    await tapText(tester, 'Duplicate');
    expect(tester.widget<CounterSurface>(find.byType(CounterSurface)).count, 8);
    expect(
      tester.widget<CounterSurface>(find.byType(CounterSurface)).target,
      100,
    );
  });
}

class _RecordingVibration extends VibrationPlatform {
  _RecordingVibration(this.durations);
  final List<int> durations;
  @override
  Future<bool> hasVibrator() async => true;
  @override
  Future<void> vibrate({
    int duration = 500,
    List<int> pattern = const [],
    int repeat = -1,
    List<int> intensities = const [],
    int amplitude = -1,
    double sharpness = 0.5,
  }) async {
    durations.add(duration);
  }
}
