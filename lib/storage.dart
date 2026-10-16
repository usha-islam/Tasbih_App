import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Shared across routes, so leaving a counter cannot race a session reset.
class SaveQueue {
  Future<void>? _tail;
  final error = ValueNotifier<String?>(null);
  Future<void> get idle async {
    if (_tail != null) await _tail;
  }

  Future<bool> run(Future<void> Function() operation) {
    final previous = _tail;
    final result = (() async {
      if (previous != null) await previous;
      try {
        await operation();
        return true;
      } catch (_) {
        error.value =
            'Could not save changes. Keep the app open and try again.';
        return false;
      }
    })();
    final tail = result.then((_) {});
    _tail = tail;
    tail.then((_) {
      if (identical(_tail, tail)) _tail = null;
    });
    return result;
  }
}

final saves = SaveQueue();
Future<void> requireSave(Future<bool> write) async {
  if (!await write) throw StateError('Storage rejected the write');
}

String newDhikrId() {
  final random = Random.secure();
  return 'custom_v2_${List.generate(16, (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0')).join()}';
}

class CustomDhikr {
  const CustomDhikr(this.id, this.name);
  final String id;
  final String name;
  String encode() => jsonEncode({'id': id, 'name': name});
}

class DhikrStore {
  static const entriesKey = 'custom_dhikr_entries_v2';
  static const migrationNoticeKey = 'custom_dhikr_duplicate_migration';

  /// Commit the list last. Legacy data remains as a recovery backup.
  /// Duplicate names shared one counter; copy that snapshot to EACH entry.
  static Future<List<CustomDhikr>> load(SharedPreferences prefs) async {
    final stored = prefs.getStringList(entriesKey);
    if (stored != null) {
      return stored.map((raw) {
        final data = jsonDecode(raw) as Map<String, dynamic>;
        return CustomDhikr(data['id'] as String, data['name'] as String);
      }).toList();
    }
    final names = prefs.getStringList('custom_dhikr_names') ?? [];
    final entries = <CustomDhikr>[];
    for (final name in names) {
      final entry = CustomDhikr(newDhikrId(), name);
      entries.add(entry);
      final old = 'custom_$name';
      for (final prefix in ['zikir_', 'dhikr_target_', 'dhikr_free_']) {
        final suffix = prefix == 'zikir_' ? '_count' : '';
        final value = prefs.get('$prefix$old$suffix');
        final key = '$prefix${entry.id}$suffix';
        if (value is int) await requireSave(prefs.setInt(key, value));
        if (value is bool) await requireSave(prefs.setBool(key, value));
      }
    }
    if (names.toSet().length != names.length) {
      await requireSave(prefs.setBool(migrationNoticeKey, true));
    }
    await write(prefs, entries);
    return entries;
  }

  static Future<void> write(
    SharedPreferences prefs,
    List<CustomDhikr> entries,
  ) => requireSave(
    prefs.setStringList(entriesKey, entries.map((e) => e.encode()).toList()),
  );
  static Future<void> delete(SharedPreferences prefs, String id) async {
    final entries = await load(prefs);
    await write(prefs, entries.where((e) => e.id != id).toList());
    for (final key in [
      'zikir_${id}_count',
      'zikir_${id}_completed',
      'dhikr_target_$id',
      'dhikr_free_$id',
    ]) {
      await requireSave(prefs.remove(key));
    }
  }
}
