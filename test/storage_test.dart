import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasbih_app/storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'legacy duplicates preserve progress and stable IDs; deletion is isolated',
    () async {
      SharedPreferences.setMockInitialValues({
        'custom_dhikr_names': ['Same', 'Same', 'Other'],
        'zikir_custom_Same_count': 78,
        'dhikr_target_custom_Same': 100,
        'dhikr_free_custom_Same': true,
        'zikir_custom_Other_count': 9,
      });
      final prefs = await SharedPreferences.getInstance();
      final entries = await DhikrStore.load(prefs);
      expect(entries.map((e) => e.id).toSet().length, 3);
      for (final entry in entries.take(2)) {
        final id = entry.id;
        expect(
          prefs.getInt(
            'zikir_$id'
            '_count',
          ),
          78,
        );
        expect(prefs.getInt('dhikr_target_$id'), 100);
        expect(prefs.getBool('dhikr_free_$id'), true);
      }
      expect(prefs.getBool(DhikrStore.migrationNoticeKey), true);
      expect(prefs.getInt('zikir_custom_Same_count'), 78);
      expect(
        (await DhikrStore.load(prefs)).map((e) => e.id),
        entries.map((e) => e.id),
      );
      await DhikrStore.delete(prefs, entries.first.id);
      expect((await DhikrStore.load(prefs)).length, 2);
      final survivor = entries[1].id;
      final deleted = entries.first.id;
      expect(
        prefs.getInt(
          'zikir_$survivor'
          '_count',
        ),
        78,
      );
      expect(
        prefs.getInt(
          'zikir_$deleted'
          '_count',
        ),
        isNull,
      );
      expect(prefs.getBool('dhikr_free_$survivor'), true);
    },
  );
  test('new same-name entries persist separate IDs', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final entries = [
      CustomDhikr(newDhikrId(), 'Same'),
      CustomDhikr(newDhikrId(), 'Same'),
    ];
    await DhikrStore.write(prefs, entries);
    expect(entries[0].id, isNot(entries[1].id));
    expect(
      (await DhikrStore.load(prefs)).map((e) => e.id),
      entries.map((e) => e.id),
    );
  });
  test(
    'writes are ordered despite latency and errors do not poison queue',
    () async {
      final queue = SaveQueue();
      final gate = Completer<void>();
      final writes = <int>[];
      final first = queue.run(() async {
        await gate.future;
        writes.add(1);
      });
      final failed = queue.run(() async {
        throw StateError('disk unavailable');
      });
      final last = queue.run(() async {
        writes.add(2);
      });
      await Future<void>.delayed(Duration.zero);
      expect(writes, isEmpty);
      gate.complete();
      expect(await first, true);
      expect(await failed, false);
      expect(await last, true);
      await queue.idle;
      expect(writes, [1, 2]);
      expect(queue.error.value, contains('Could not save'));
    },
  );
  test('false platform writes count as failures', () async {
    final queue = SaveQueue();
    expect(await queue.run(() => requireSave(Future.value(false))), false);
    expect(await queue.run(() => requireSave(Future.value(true))), true);
  });
}
