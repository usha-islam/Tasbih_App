import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'counter_widgets.dart';
import 'home_widgets.dart';
import 'dhikr_target_choices.dart';
import 'storage.dart';
import 'reading_content.dart';

void main() {
  runApp(const MyApp());
}

const _minimumTarget = 1;
const _maximumTarget = 10000;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tasbih',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF1F5B4D),
          onPrimary: Colors.white,
          secondary: Color(0xFFB6873D),
          onSecondary: Colors.white,
          surface: Color(0xFFF7F3EA),
          onSurface: Color(0xFF193C35),
          outline: Color(0xFFB8C9BE),
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F3EA),
        fontFamily: 'Lato',
        navigationBarTheme: NavigationBarThemeData(
          iconTheme: WidgetStateProperty.resolveWith(
            (states) => IconThemeData(
              color: states.contains(WidgetState.selected)
                  ? primaryGreen
                  : secondaryInk,
            ),
          ),
          labelTextStyle: WidgetStateProperty.resolveWith(
            (states) => TextStyle(
              fontFamily: 'Lato',
              fontSize: 13,
              color: states.contains(WidgetState.selected)
                  ? inkGreen
                  : secondaryInk,
              fontWeight: states.contains(WidgetState.selected)
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: const Color(0xFFF7F3EA),
          selectedColor: const Color(0xFFDDE9DF),
          side: const BorderSide(color: Color(0xFFB8C9BE)),
          labelStyle: const TextStyle(fontFamily: 'Lato', color: inkGreen),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFE8F1EA),
          errorMaxLines: 3,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFB8C9BE)),
          ),
        ),
        iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(
            minimumSize: const Size(48, 48),
            iconSize: 22,
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF7F3EA),
          foregroundColor: Color(0xFF193C35),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontFamily: 'Lato',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF193C35),
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF193C35)),
          bodyMedium: TextStyle(color: Color(0xFF193C35)),
          bodySmall: TextStyle(color: Color(0xFF193C35)),
          titleMedium: TextStyle(color: Color(0xFF193C35)),
          titleLarge: TextStyle(color: Color(0xFF193C35)),
          titleSmall: TextStyle(color: Color(0xFF193C35)),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF1F5B4D),
            foregroundColor: Colors.white,
            minimumSize: const Size(48, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF1F5B4D),
            disabledForegroundColor: const Color(0xFF687B71),
            textStyle: const TextStyle(
              fontFamily: 'Lato',
              fontWeight: FontWeight.bold,
            ),
            minimumSize: const Size(48, 48),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF1F5B4D),
            side: const BorderSide(color: Color(0xFFB8C9BE)),
            minimumSize: const Size(48, 48),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
      builder: (context, child) => SafeArea(
        top: false,
        child: Center(
          child: SizedBox(
            width: 600,
            child: Column(
              children: [
                ValueListenableBuilder<String?>(
                  valueListenable: saves.error,
                  builder: (context, message, _) => message == null
                      ? const SizedBox.shrink()
                      : Material(
                          color: const Color(0xFFF7F3EA),
                          child: SafeArea(
                            bottom: false,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                children: [
                                  Text(
                                    message,
                                    style: const TextStyle(color: inkGreen),
                                  ),
                                  TextButton(
                                    onPressed: () => saves.error.value = null,
                                    child: const Text('Dismiss'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                ),
                Expanded(child: child!),
              ],
            ),
          ),
        ),
      ),
      home: const AppShell(),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  final _homeKey = GlobalKey<_TasbihHomePageState>();
  final _dailyKey = GlobalKey<_DailyZikirPageState>();
  final _libraryKey = GlobalKey<_DhikrLibraryPageState>();
  @override
  void initState() {
    super.initState();
    CountingFeedback.instance.load();
  }

  void _select(int index) {
    setState(() => _index = index);
    if (index == 1) _dailyKey.currentState?._loadProgress();
    if (index == 2) _libraryKey.currentState?._loadDhikrs();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: IndexedStack(
      index: _index,
      children: [
        TasbihHomePage(key: _homeKey),
        DailyZikirPage(key: _dailyKey),
        DhikrLibraryPage(key: _libraryKey),
      ],
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: _index,
      onDestinationSelected: _select,
      height: 68,
      backgroundColor: const Color(0xFFF7F3EA),
      indicatorColor: const Color(0xFFDDE9DF),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.touch_app_outlined),
          label: 'Tasbih',
        ),
        NavigationDestination(
          icon: Icon(Icons.checklist_rounded),
          label: 'Daily Dhikr',
        ),
        NavigationDestination(
          icon: Icon(Icons.menu_book_outlined),
          label: 'Dhikr List',
        ),
      ],
    ),
  );
}

class TasbihHomePage extends StatefulWidget {
  const TasbihHomePage({super.key});
  @override
  State<TasbihHomePage> createState() => _TasbihHomePageState();
}

class _TasbihHomePageState extends State<TasbihHomePage> {
  int _count = 0;
  int? _target = 33;
  bool _isLoading = true;
  bool _canUndo = false;
  bool _milestoneSent = false;
  @override
  void initState() {
    super.initState();
    _loadSavedProgress();
  }

  Future<void> _loadSavedProgress() async {
    await saves.idle;
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _count = prefs.getInt('tasbih_count') ?? 0;
      final saved = prefs.getInt('tasbih_target') ?? 33;
      _target = (prefs.getBool('tasbih_free_count') ?? false)
          ? null
          : (saved >= 1 && saved <= 10000 ? saved : 33);
      _milestoneSent = _target != null && _count >= _target!;
      _isLoading = false;
    });
  }

  void _incrementCounter() {
    if (_isLoading) return;
    final milestone =
        _target != null && _count + 1 >= _target! && !_milestoneSent;
    setState(() {
      _count++;
      _canUndo = true;
      if (milestone) _milestoneSent = true;
    });
    CountingFeedback.instance.play(milestone: milestone);
    _saveProgress();
  }

  Future<bool> _saveProgress() {
    final count = _count;
    final target = _target;
    return saves.run(() async {
      final prefs = await SharedPreferences.getInstance();
      await requireSave(prefs.setInt('tasbih_count', count));
      await requireSave(prefs.setBool('tasbih_free_count', target == null));
      if (target != null) {
        await requireSave(prefs.setInt('tasbih_target', target));
      }
    });
  }

  void _undo() {
    if (!_canUndo || _count == 0) return;
    setState(() {
      _count--;
      _canUndo = false;
      _milestoneSent = _target != null && _count >= _target!;
    });
    _saveProgress();
  }

  Future<void> _resetCounter() async {
    if (_count > 0 &&
        !await confirmAction(
          context,
          title: 'Reset count?',
          message: 'Clear your current Tasbih count?',
          action: 'Reset',
        )) {
      return;
    }
    if (!mounted) return;
    setState(() {
      _count = 0;
      _canUndo = false;
      _milestoneSent = false;
    });
    await _saveProgress();
  }

  void _changeTarget(int? target) {
    setState(() {
      _target = target;
      _milestoneSent = target != null && _count >= target;
    });
    _saveProgress();
  }

  @override
  Widget build(BuildContext context) {
    final complete = _target != null && _count >= _target!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasbih'),
        automaticallyImplyLeading: false,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 24),
            child: Center(
              child: Text(
                'ذكر',
                style: TextStyle(
                  color: Color(0xFFB6873D),
                  fontSize: 25,
                  fontFamily: 'NotoNaskhArabic',
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          key: const ValueKey('home-scroll'),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const HomeWelcomeCard(),
              const SizedBox(height: 18),
              HomeTargetChoices(
                target: _target,
                onChanged: _changeTarget,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 20),
              CounterSurface(
                count: _count,
                target: _target,
                loading: _isLoading,
                onTap: _isLoading ? null : _incrementCounter,
              ),
              const SizedBox(height: 16),
              if (_target != null)
                Text(
                  complete
                      ? 'MashaAllah, target complete!'
                      : '${_target! - _count} remaining',
                  textAlign: TextAlign.center,
                  semanticsLabel: complete ? 'Target complete' : null,
                  style: const TextStyle(
                    color: secondaryInk,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
              const SizedBox(height: 8),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 24,
                runSpacing: 4,
                children: [
                  TextButton.icon(
                    onPressed: _canUndo ? _undo : null,
                    icon: const Icon(Icons.undo, size: 20),
                    label: const Text('Undo'),
                  ),
                  TextButton.icon(
                    onPressed: _isLoading ? null : _resetCounter,
                    icon: const Icon(Icons.refresh, size: 20),
                    label: const Text('Reset count'),
                  ),
                ],
              ),
              const FeedbackControls(),
            ],
          ),
        ),
      ),
    );
  }
}

class ZikirItem {
  const ZikirItem({
    required this.id,
    required this.name,
    required this.arabic,
    this.transliteration,
    this.meaning,
    this.recommendation,
    required this.target,
  });

  final String id;
  final String name;
  final String arabic;
  final String? transliteration;
  final String? meaning;
  final String? recommendation;
  final int? target;
}

class DhikrLibraryPage extends StatefulWidget {
  const DhikrLibraryPage({super.key});

  @override
  State<DhikrLibraryPage> createState() => _DhikrLibraryPageState();
}

class _DhikrLibraryPageState extends State<DhikrLibraryPage> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  static const _deletedIdsKey = 'deleted_dhikr_ids';
  static const _defaultDhikrs = [
    ZikirItem(
      id: 'la_ilaha_illallah',
      name: 'La ilaha illallah',
      arabic: 'لَا إِلٰهَ إِلَّا اللهُ',
      transliteration: 'La ilaha illallah',
      meaning: 'There is no god but Allah.',
      target: null,
    ),
    ZikirItem(
      id: 'subhanallah',
      name: 'SubhanAllah',
      arabic: 'سُبْحَانَ اللهِ',
      transliteration: 'SubhanAllah',
      meaning: 'Glory be to Allah.',
      target: null,
    ),
    ZikirItem(
      id: 'alhamdulillah',
      name: 'Alhamdulillah',
      arabic: 'الْحَمْدُ لِلَّهِ',
      transliteration: 'Alhamdulillah',
      meaning: 'All praise is due to Allah.',
      target: null,
    ),
    ZikirItem(
      id: 'allahu_akbar',
      name: 'Allahu Akbar',
      arabic: 'اللهُ أَكْبَرُ',
      transliteration: 'Allahu Akbar',
      meaning: 'Allah is the Greatest.',
      target: null,
    ),
    ZikirItem(
      id: 'la_hawla',
      name: 'La hawla wa la quwwata illa billah',
      arabic: 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللهِ',
      transliteration: 'La hawla wa la quwwata illa billah',
      meaning: 'There is no power or strength except through Allah.',
      target: null,
    ),
    ZikirItem(
      id: 'astaghfirullah',
      name: 'Astaghfirullah',
      arabic: 'أَسْتَغْفِرُ اللهَ',
      transliteration: 'Astaghfirullah',
      meaning: 'I seek forgiveness from Allah.',
      target: null,
    ),
    ZikirItem(
      id: 'subhanallahi_wa_bihamdihi',
      name: 'SubhanAllahi wa bihamdihi',
      arabic: 'سُبْحَانَ اللهِ وَبِحَمْدِهِ',
      transliteration: 'SubhanAllahi wa bihamdihi',
      meaning: 'Glory be to Allah and all praise is for Him.',
      target: null,
    ),
    ZikirItem(
      id: 'subhanallahil_azim',
      name: 'SubhanAllahil Azim',
      arabic: 'سُبْحَانَ اللهِ الْعَظِيمِ',
      transliteration: 'SubhanAllahil Azim',
      meaning: 'Glory be to Allah, the Magnificent.',
      target: null,
    ),
    ZikirItem(
      id: 'subhanallahi_wa_bihamdihi_azim',
      name: 'SubhanAllahi wa bihamdihi, SubhanAllahil Azim',
      arabic: 'سُبْحَانَ اللهِ وَبِحَمْدِهِ، سُبْحَانَ اللهِ الْعَظِيمِ',
      transliteration: 'SubhanAllahi wa bihamdihi, SubhanAllahil Azim',
      meaning: 'Glory be to Allah and all praise is for Him; Glory be to Allah, the Magnificent.',
      target: null,
    ),
    ZikirItem(
      id: 'la_ilaha_illallahu_wahdahu',
      name: 'La ilaha illallahu wahdahu la sharika lah',
      arabic: 'لَا إِلٰهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ',
      transliteration: "La ilaha illallahu wahdahu la sharika lah, lahul-mulku wa lahul-hamdu wa huwa 'ala kulli shay'in qadir.",
      meaning: 'There is no god but Allah alone. He has no partner. To Him belongs the kingdom and all praise, and He has power over everything.',
      target: null,
    ),
    ZikirItem(
      id: 'la_ilaha_illa_anta',
      name: 'La ilaha illa anta subhanaka',
      arabic: 'لَا إِلٰهَ إِلَّا أَنْتَ سُبْحَانَكَ إِنِّي كُنْتُ مِنَ الظَّالِمِينَ',
      transliteration: 'La ilaha illa anta subhanaka inni kuntu minaz-zalimin.',
      meaning: 'There is no god but You. Glory be to You. Indeed, I was among the wrongdoers.',
      target: null,
    ),
    ZikirItem(
      id: 'astaghfirullahal_azim',
      name: 'Astaghfirullahal Azim',
      arabic: 'أَسْتَغْفِرُ اللهَ الْعَظِيمَ الَّذِي لَا إِلٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ وَأَتُوبُ إِلَيْهِ',
      transliteration: 'Astaghfirullahal Azim alladhi la ilaha illa huwal-hayyul-qayyum wa atubu ilayh.',
      meaning: 'I seek forgiveness from Allah, the Magnificent, there is no god but Him, the Ever-Living, the Sustainer of all, and I repent to Him.',
      target: null,
    ),
    ZikirItem(
      id: 'ya_hayyu_ya_qayyum',
      name: 'Ya Hayyu Ya Qayyum',
      arabic: 'يَا حَيُّ يَا قَيُّومُ بِرَحْمَتِكَ أَسْتَغِيثُ',
      transliteration: 'Ya Hayyu Ya Qayyum, bi rahmatika astagheeth.',
      meaning:
          'O Ever-Living, O Sustainer of all, I seek help through Your mercy.',
      target: null,
    ),
    ZikirItem(
      id: 'allahumma_salli_ala_muhammad',
      name: 'Allahumma salli ala Muhammad',
      arabic: 'اللَّهُمَّ صَلِّ عَلَىٰ مُحَمَّدٍ',
      transliteration: "Allahumma salli 'ala Muhammad.",
      meaning: 'O Allah, send blessings upon Muhammad.',
      target: null,
    ),
    ZikirItem(
      id: 'allahumma_salli_ala_ali_muhammad',
      name: 'Allahumma salli ala Muhammad wa ala ali Muhammad',
      arabic: 'اللَّهُمَّ صَلِّ عَلَىٰ مُحَمَّدٍ وَعَلَىٰ آلِ مُحَمَّدٍ',
      transliteration: "Allahumma salli 'ala Muhammad wa 'ala ali Muhammad.",
      meaning: 'O Allah, send blessings upon Muhammad and upon the family of Muhammad.',
      target: null,
    ),
    ZikirItem(
      id: 'allahumma_salli_wa_sallim',
      name: 'Allahumma salli wa sallim ala nabiyyina Muhammad',
      arabic: 'اللَّهُمَّ صَلِّ وَسَلِّمْ عَلَى نَبِيِّنَا مُحَمَّدٍ',
      transliteration: 'Allahumma salli wa sallim ala nabiyyina Muhammad.',
      meaning: 'O Allah, send blessings and peace upon our Prophet Muhammad.',
      target: null,
    ),
  ];

  List<CustomDhikr> _customEntries = [];
  bool _migrationNotice = false;
  Set<String> _deletedIds = {};
  Map<String, int> _targets = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDhikrs();
  }

  Future<void> _loadDhikrs() async {
    final preferences = await SharedPreferences.getInstance();
    List<CustomDhikr> customEntries = [];
    final loaded = await saves.run(() async {
      customEntries = await DhikrStore.load(preferences);
    });
    if (!loaded) return;
    final deletedIds = preferences.getStringList(_deletedIdsKey) ?? [];
    final allDhikrs = [
      ..._defaultDhikrs.map((dhikr) => dhikr.id),
      ...customEntries.map((entry) => entry.id),
    ];
    final targets = <String, int>{};
    for (final id in allDhikrs) {
      final target = preferences.getInt(_targetKeyFor(id));
      if (target != null) targets[id] = target;
    }
    if (!mounted) return;
    setState(() {
      _customEntries = customEntries;
      _migrationNotice =
          preferences.getBool(DhikrStore.migrationNoticeKey) ?? false;
      _deletedIds = deletedIds.toSet();
      _targets = targets;
      _isLoading = false;
    });
  }

  String _targetKeyFor(String id) => 'dhikr_target_$id';

  Future<void> _addDhikr() async {
    final name = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(builder: (_) => const AddDhikrPage()),
    );
    if (name == null || !mounted) return;
    final preferences = await SharedPreferences.getInstance();
    await saves.run(() async {
      final entries = await DhikrStore.load(preferences);
      await DhikrStore.write(preferences, [
        ...entries,
        CustomDhikr(newDhikrId(), name),
      ]);
    });
    await _loadDhikrs();
  }

  Future<void> _deleteDhikr(ZikirItem dhikr) async {
    if (!await confirmAction(
      context,
      title: 'Delete dhikr?',
      message: 'Remove ${dhikr.name} and its saved count from your list?',
      action: 'Delete',
    )) {
      return;
    }
    if (!mounted) return;
    final preferences = await SharedPreferences.getInstance();
    await saves.run(() async {
      if (_customEntries.any((entry) => entry.id == dhikr.id)) {
        await DhikrStore.delete(preferences, dhikr.id);
      } else {
        final deleted = {..._deletedIds, dhikr.id};
        await requireSave(
          preferences.setStringList(_deletedIdsKey, deleted.toList()),
        );
        await requireSave(preferences.remove(_targetKeyFor(dhikr.id)));
        await requireSave(preferences.remove('zikir_${dhikr.id}_count'));
        await requireSave(preferences.remove('dhikr_free_${dhikr.id}'));
      }
    });
    await _loadDhikrs();
  }

  Future<void> _openDhikr(ZikirItem dhikr) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ZikirTasbihPage(
          zikir: dhikr,
          allowTargetEditing: true,
          targetKey: _targetKeyFor(dhikr.id),
        ),
      ),
    );
    _loadDhikrs();
  }

  @override
  Widget build(BuildContext context) {
    final customDhikrs = _customEntries.map(
      (entry) => ZikirItem(
        id: entry.id,
        name: entry.name,
        arabic: entry.name,
        target: _targets[entry.id],
      ),
    );
    final allDhikrs = [
      ..._defaultDhikrs.where((dhikr) => !_deletedIds.contains(dhikr.id)),
      ...customDhikrs,
    ];
    final query = _query.trim().toLowerCase();
    final dhikrs = allDhikrs
        .where(
          (item) => [
            item.name,
            item.arabic,
            item.transliteration ?? '',
            item.meaning ?? '',
          ].any((text) => text.toLowerCase().contains(query)),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dhikr List'),
        automaticallyImplyLeading: false,
        foregroundColor: const Color(0xFF193C35),
        backgroundColor: Colors.transparent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 30),
              children: [
                const Text(
                  'Your Dhikr List',
                  style: TextStyle(
                    color: Color(0xFF193C35),
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Choose a dhikr to count and set its target.',
                  style: TextStyle(color: Color(0xFF53685F), fontSize: 15),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _query = value),
                  decoration: InputDecoration(
                    labelText: 'Search dhikr',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Clear search',
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                if (dhikrs.isEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'No dhikr found. Try another name or clear your search.',
                      style: TextStyle(color: secondaryInk, height: 1.5),
                    ),
                  ),
                  if (_query.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                      child: const Text('Clear search'),
                    ),
                ],
                if (_migrationNotice)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: Text(
                      'Older entries with identical names shared progress. That saved progress was copied to each entry; they now count independently.',
                      style: TextStyle(color: secondaryInk, height: 1.5),
                    ),
                  ),
                ...dhikrs.map(_buildDhikrTile),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: _addDhikr,
                  icon: const Icon(Icons.add),
                  label: const Text('Add new dhikr'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1F5B4D),
                    side: const BorderSide(color: Color(0xFFC7D8CC)),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildDhikrTile(ZikirItem dhikr) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: Colors.white.withValues(alpha: .7),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0xFFD6DED3)),
        ),
        elevation: 1,
        shadowColor: const Color(0x14193C35),
        child: InkWell(
          onTap: () => _openDhikr(dhikr),
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dhikr.arabic,
                        textDirection: readingDirection(dhikr.arabic),
                        style: TextStyle(
                          color: Color(0xFF193C35),
                          fontSize: 24,
                          height: 1.65,
                          fontWeight: FontWeight.w500,
                          fontFamily:
                              readingDirection(dhikr.arabic) ==
                                  TextDirection.rtl
                              ? 'NotoNaskhArabic'
                              : 'Lato',
                          fontFamilyFallback: const ['Lato'],
                        ),
                      ),
                      if (dhikr.transliteration != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          dhikr.transliteration!,
                          style: const TextStyle(
                            color: Color(0xFF53685F),
                            fontSize: 14,
                            height: 1.5,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                      if (dhikr.meaning != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          dhikr.meaning!,
                          style: const TextStyle(
                            color: Color(0xFF53685F),
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  tooltip: 'Actions for ${dhikr.name}',
                  icon: const Icon(Icons.more_horiz, color: secondaryInk),
                  onSelected: (_) => _deleteDhikr(dhikr),
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AddDhikrPage extends StatefulWidget {
  const AddDhikrPage({super.key});

  @override
  State<AddDhikrPage> createState() => _AddDhikrPageState();
}

class _AddDhikrPageState extends State<AddDhikrPage> {
  final _nameController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Enter a dhikr name.');
      return;
    }
    Navigator.of(context).pop(name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Dhikr'),
        foregroundColor: const Color(0xFF193C35),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
        children: [
          const Text(
            'New dhikr',
            style: TextStyle(
              color: Color(0xFF193C35),
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add a name to your personal dhikr list.',
            style: TextStyle(color: Color(0xFF53685F), fontSize: 15),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _nameController,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: 'Dhikr name',
              hintText: 'For example, Astaghfirullah',
              errorText: _error,
              border: const OutlineInputBorder(),
            ),
            onSubmitted: (_) => _save(),
          ),
          const SizedBox(height: 22),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            runSpacing: 8,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PrayerTime {
  const PrayerTime({
    required this.id,
    required this.name,
    required this.zikirs,
  });

  final String id;
  final String name;
  final List<ZikirItem> zikirs;
}

const _prayerTimes = [
  PrayerTime(
    id: 'fajr',
    name: 'Fajr',
    zikirs: [
      ZikirItem(
        id: 'astaghfirullah',
        name: 'Astaghfirullah',
        arabic: 'أَسْتَغْفِرُ اللَّهَ',
        transliteration: 'Astaghfirullah',
        meaning: 'I seek forgiveness from Allah.',
        recommendation: 'Three after prayer: Sahih Muslim 591.',
        target: 3,
      ),
      ZikirItem(
        id: 'subhanallah',
        name: 'SubhanAllah',
        arabic: 'سُبْحَانَ اللَّهِ',
        transliteration: 'SubhanAllah',
        meaning: 'Glory be to Allah.',
        recommendation: '33 / 33 / 34 after prayer: Sahih Muslim 596a.',
        target: 33,
      ),
      ZikirItem(
        id: 'alhamdulillah',
        name: 'Alhamdulillah',
        arabic: 'الْحَمْدُ لِلَّهِ',
        transliteration: 'Alhamdulillah',
        meaning: 'All praise is due to Allah.',
        recommendation: '33 / 33 / 34 after prayer: Sahih Muslim 596a.',
        target: 33,
      ),
      ZikirItem(
        id: 'allahu_akbar',
        name: 'Allahu Akbar',
        arabic: 'اللَّهُ أَكْبَرُ',
        transliteration: 'Allahu Akbar',
        meaning: 'Allah is the Greatest.',
        recommendation: '33 / 33 / 34 after prayer: Sahih Muslim 596a.',
        target: 34,
      ),
      ZikirItem(
        id: 'ayatul_kursi',
        name: 'Ayatul Kursi',
        arabic: ayatulKursi,
        recommendation: 'Quran 2:255. One recitation is this session goal; not restricted to these two prayers.',
        target: 1,
      ),
      ZikirItem(
        id: 'allahumma_ajirni',
        name: 'Allahumma ajirni minan-nar',
        arabic: 'اللَّهُمَّ أَجِرْنِي مِنَ النَّارِ',
        transliteration: 'Allahumma ajirni minan-nar.',
        meaning: 'O Allah, protect me from the Fire.',
        recommendation: 'The report specifying seven repetitions (Abu Dawud 5079) is graded weak by Al-Albani. Kept as an optional personal goal.',
        target: 7,
      ),
    ],
  ),
  PrayerTime(
    id: 'zuhr',
    name: 'Zuhr',
    zikirs: [
      ZikirItem(
        id: 'zuhr_astaghfirullah',
        name: 'Astaghfirullah',
        arabic: 'أَسْتَغْفِرُ اللَّهَ',
        transliteration: 'Astaghfirullah',
        meaning: 'I seek forgiveness from Allah.',
        recommendation: 'Three after prayer: Sahih Muslim 591.',
        target: 3,
      ),
      ZikirItem(
        id: 'zuhr_subhanallah',
        name: 'SubhanAllah',
        arabic: 'سُبْحَانَ اللَّهِ',
        transliteration: 'SubhanAllah',
        meaning: 'Glory be to Allah.',
        recommendation: '33 / 33 / 34 after prayer: Sahih Muslim 596a.',
        target: 33,
      ),
      ZikirItem(
        id: 'zuhr_alhamdulillah',
        name: 'Alhamdulillah',
        arabic: 'الْحَمْدُ لِلَّهِ',
        transliteration: 'Alhamdulillah',
        meaning: 'All praise is due to Allah.',
        recommendation: '33 / 33 / 34 after prayer: Sahih Muslim 596a.',
        target: 33,
      ),
      ZikirItem(
        id: 'zuhr_allahu_akbar',
        name: 'Allahu Akbar',
        arabic: 'اللَّهُ أَكْبَرُ',
        transliteration: 'Allahu Akbar',
        meaning: 'Allah is the Greatest.',
        recommendation: '33 / 33 / 34 after prayer: Sahih Muslim 596a.',
        target: 34,
      ),
    ],
  ),
  PrayerTime(
    id: 'asr',
    name: 'Asr',
    zikirs: [
      ZikirItem(
        id: 'asr_astaghfirullah',
        name: 'Astaghfirullah',
        arabic: 'أَسْتَغْفِرُ اللَّهَ',
        transliteration: 'Astaghfirullah',
        meaning: 'I seek forgiveness from Allah.',
        recommendation: 'Three after prayer: Sahih Muslim 591.',
        target: 3,
      ),
      ZikirItem(
        id: 'asr_subhanallah',
        name: 'SubhanAllah',
        arabic: 'سُبْحَانَ اللَّهِ',
        transliteration: 'SubhanAllah',
        meaning: 'Glory be to Allah.',
        recommendation: '33 / 33 / 34 after prayer: Sahih Muslim 596a.',
        target: 33,
      ),
      ZikirItem(
        id: 'asr_alhamdulillah',
        name: 'Alhamdulillah',
        arabic: 'الْحَمْدُ لِلَّهِ',
        transliteration: 'Alhamdulillah',
        meaning: 'All praise is due to Allah.',
        recommendation: '33 / 33 / 34 after prayer: Sahih Muslim 596a.',
        target: 33,
      ),
      ZikirItem(
        id: 'asr_allahu_akbar',
        name: 'Allahu Akbar',
        arabic: 'اللَّهُ أَكْبَرُ',
        transliteration: 'Allahu Akbar',
        meaning: 'Allah is the Greatest.',
        recommendation: '33 / 33 / 34 after prayer: Sahih Muslim 596a.',
        target: 34,
      ),
    ],
  ),
  PrayerTime(
    id: 'maghrib',
    name: 'Maghrib',
    zikirs: [
      ZikirItem(
        id: 'maghrib_astaghfirullah',
        name: 'Astaghfirullah',
        arabic: 'أَسْتَغْفِرُ اللَّهَ',
        transliteration: 'Astaghfirullah',
        meaning: 'I seek forgiveness from Allah.',
        recommendation: 'Three after prayer: Sahih Muslim 591.',
        target: 3,
      ),
      ZikirItem(
        id: 'maghrib_subhanallah',
        name: 'SubhanAllah',
        arabic: 'سُبْحَانَ اللَّهِ',
        transliteration: 'SubhanAllah',
        meaning: 'Glory be to Allah.',
        recommendation: '33 / 33 / 34 after prayer: Sahih Muslim 596a.',
        target: 33,
      ),
      ZikirItem(
        id: 'maghrib_alhamdulillah',
        name: 'Alhamdulillah',
        arabic: 'الْحَمْدُ لِلَّهِ',
        transliteration: 'Alhamdulillah',
        meaning: 'All praise is due to Allah.',
        recommendation: '33 / 33 / 34 after prayer: Sahih Muslim 596a.',
        target: 33,
      ),
      ZikirItem(
        id: 'maghrib_allahu_akbar',
        name: 'Allahu Akbar',
        arabic: 'اللَّهُ أَكْبَرُ',
        transliteration: 'Allahu Akbar',
        meaning: 'Allah is the Greatest.',
        recommendation: '33 / 33 / 34 after prayer: Sahih Muslim 596a.',
        target: 34,
      ),
      ZikirItem(
        id: 'maghrib_ayatul_kursi',
        name: 'Ayatul Kursi',
        arabic: ayatulKursi,
        recommendation: 'Quran 2:255. One recitation is this session goal; not restricted to these two prayers.',
        target: 1,
      ),
      ZikirItem(
        id: 'maghrib_allahumma_ajirni',
        name: 'Allahumma ajirni minan-nar',
        arabic: 'اللَّهُمَّ أَجِرْنِي مِنَ النَّارِ',
        transliteration: 'Allahumma ajirni minan-nar.',
        meaning: 'O Allah, protect me from the Fire.',
        recommendation: 'The report specifying seven repetitions (Abu Dawud 5079) is graded weak by Al-Albani. Kept as an optional personal goal.',
        target: 7,
      ),
    ],
  ),
  PrayerTime(
    id: 'isha',
    name: 'Isha',
    zikirs: [
      ZikirItem(
        id: 'isha_astaghfirullah',
        name: 'Astaghfirullah',
        arabic: 'أَسْتَغْفِرُ اللَّهَ',
        transliteration: 'Astaghfirullah',
        meaning: 'I seek forgiveness from Allah.',
        recommendation: 'Three after prayer: Sahih Muslim 591.',
        target: 3,
      ),
      ZikirItem(
        id: 'isha_subhanallah',
        name: 'SubhanAllah',
        arabic: 'سُبْحَانَ اللَّهِ',
        transliteration: 'SubhanAllah',
        meaning: 'Glory be to Allah.',
        recommendation: '33 / 33 / 34 after prayer: Sahih Muslim 596a.',
        target: 33,
      ),
      ZikirItem(
        id: 'isha_alhamdulillah',
        name: 'Alhamdulillah',
        arabic: 'الْحَمْدُ لِلَّهِ',
        transliteration: 'Alhamdulillah',
        meaning: 'All praise is due to Allah.',
        recommendation: '33 / 33 / 34 after prayer: Sahih Muslim 596a.',
        target: 33,
      ),
      ZikirItem(
        id: 'isha_allahu_akbar',
        name: 'Allahu Akbar',
        arabic: 'اللَّهُ أَكْبَرُ',
        transliteration: 'Allahu Akbar',
        meaning: 'Allah is the Greatest.',
        recommendation: '33 / 33 / 34 after prayer: Sahih Muslim 596a.',
        target: 34,
      ),
    ],
  ),
];

List<ZikirItem> _savedPrayerItems(SharedPreferences prefs, PrayerTime prayer) {
  return [
    ...prayer.zikirs,
    ...(prefs.getStringList('daily_dhikr_${prayer.id}') ?? []).map((encoded) {
      final data = jsonDecode(encoded) as Map<String, dynamic>;
      return ZikirItem(
        id: data['id'] as String,
        name: data['name'] as String,
        arabic: data['arabic'] as String,
        target: data['target'] as int,
      );
    }),
  ];
}

bool _itemComplete(SharedPreferences prefs, ZikirItem item) =>
    (prefs.getBool('zikir_${item.id}_completed') ?? false) ||
    (item.target != null &&
        (prefs.getInt('zikir_${item.id}_count') ?? 0) >= item.target!);

class DailyZikirPage extends StatefulWidget {
  const DailyZikirPage({super.key});
  @override
  State<DailyZikirPage> createState() => _DailyZikirPageState();
}

class _DailyZikirPageState extends State<DailyZikirPage> {
  final Map<String, int> _done = {};
  final Map<String, int> _totals = {};
  bool _loading = true;
  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    await saves.idle;
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      for (final prayer in _prayerTimes) {
        final items = _savedPrayerItems(prefs, prayer);
        _totals[prayer.id] = items.length;
        _done[prayer.id] = items
            .where((item) => _itemComplete(prefs, item))
            .length;
      }
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Daily Dhikr'),
      automaticallyImplyLeading: false,
    ),
    body: SafeArea(
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              children: [
                const Text(
                  'A moment of remembrance',
                  style: TextStyle(
                    color: inkGreen,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Select a prayer time to begin your daily dhikr.',
                  style: TextStyle(
                    color: secondaryInk,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                for (final prayer in _prayerTimes) _buildPrayerTile(prayer),
              ],
            ),
    ),
  );
  Widget _buildPrayerTile(PrayerTime prayer) {
    final done = _done[prayer.id] ?? 0;
    final total = _totals[prayer.id] ?? prayer.zikirs.length;
    final icons = [
      Icons.wb_twilight,
      Icons.wb_sunny_outlined,
      Icons.wb_sunny,
      Icons.nights_stay_outlined,
      Icons.dark_mode_outlined,
    ];
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: Colors.white.withValues(alpha: .7),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0xFFD6DED3)),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => PrayerZikirPage(prayer: prayer),
              ),
            );
            if (mounted) await _loadProgress();
          },
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: const BoxDecoration(
                    color: Color(0xFFDDE9DF),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icons[_prayerTimes.indexOf(prayer)],
                    color: primaryGreen,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prayer.name,
                        style: const TextStyle(
                          color: inkGreen,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$done of $total completed',
                        style: const TextStyle(
                          color: secondaryInk,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: total == 0 ? 0 : done / total,
                        minHeight: 3,
                        borderRadius: BorderRadius.circular(4),
                        backgroundColor: const Color(0xFFDDE9DF),
                        color: primaryGreen,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (done == total && total > 0)
                  const Tooltip(
                    message: 'All dhikr completed',
                    child: Icon(
                      Icons.check_circle_outline,
                      color: primaryGreen,
                      size: 22,
                    ),
                  ),
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF806333),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({
    required this.isCompleted,
    required this.count,
    required this.target,
  });
  final bool isCompleted;
  final int count;
  final int target;
  @override
  Widget build(BuildContext context) => Semantics(
    label: isCompleted
        ? 'Completed'
        : count == 0
        ? 'Not started'
        : '$count of $target recitations',
    child: SizedBox(
      width: 32,
      height: 32,
      child: isCompleted
          ? const Icon(Icons.check_circle, color: primaryGreen, size: 30)
          : ExcludeSemantics(
              child: CircularProgressIndicator(
                value: target == 0 ? 0 : (count / target).clamp(0.0, 1.0),
                strokeWidth: 2,
                color: primaryGreen,
                backgroundColor: const Color(0xFFB8C9BE),
              ),
            ),
    ),
  );
}

class PrayerZikirPage extends StatefulWidget {
  const PrayerZikirPage({super.key, required this.prayer});

  final PrayerTime prayer;

  @override
  State<PrayerZikirPage> createState() => _PrayerZikirPageState();
}

class _PrayerZikirPageState extends State<PrayerZikirPage> {
  final Set<String> _completed = {};
  final Map<String, int> _counts = {};
  List<ZikirItem> _customZikirs = [];
  bool _loading = true;
  List<ZikirItem> get _items => [...widget.prayer.zikirs, ..._customZikirs];

  @override
  void initState() {
    super.initState();
    _loadCompleted();
  }

  Future<void> _loadCompleted() async {
    await saves.idle;
    final preferences = await SharedPreferences.getInstance();
    final storedCustomZikirs = preferences.getStringList(_customKey) ?? [];
    final customZikirs = storedCustomZikirs.map(_decodeCustomZikir).toList();
    if (!mounted) return;
    setState(() {
      _customZikirs = customZikirs;
      _completed.clear();
      _counts.clear();
      for (final zikir in [...widget.prayer.zikirs, ...customZikirs]) {
        _counts[zikir.id] = preferences.getInt('zikir_${zikir.id}_count') ?? 0;
        if (_itemComplete(preferences, zikir)) {
          _completed.add(zikir.id);
        }
      }
      _loading = false;
    });
  }

  String get _customKey => 'daily_dhikr_${widget.prayer.id}';

  ZikirItem _decodeCustomZikir(String encoded) {
    final data = jsonDecode(encoded) as Map<String, dynamic>;
    return ZikirItem(
      id: data['id'] as String,
      name: data['name'] as String,
      arabic: data['arabic'] as String,
      target: data['target'] as int,
    );
  }

  String _encodeCustomZikir(ZikirItem zikir) {
    return jsonEncode({
      'id': zikir.id,
      'name': zikir.name,
      'arabic': zikir.arabic,
      'target': zikir.target,
    });
  }

  Future<void> _addCustomZikir() async {
    final zikir = await Navigator.of(context).push<ZikirItem>(
      MaterialPageRoute<ZikirItem>(builder: (_) => const AddDailyDhikrPage()),
    );
    if (zikir == null || !mounted) return;
    final preferences = await SharedPreferences.getInstance();
    _customZikirs = [..._customZikirs, zikir];
    await preferences.setStringList(
      _customKey,
      _customZikirs.map(_encodeCustomZikir).toList(),
    );
    setState(() {});
  }

  Future<void> _deleteCustomZikir(ZikirItem zikir) async {
    if (!await confirmAction(
      context,
      title: 'Delete dhikr?',
      message: 'Remove ${zikir.name} from this session?',
      action: 'Delete',
    )) {
      return;
    }
    if (!mounted) return;
    final preferences = await SharedPreferences.getInstance();
    _customZikirs = _customZikirs.where((item) => item.id != zikir.id).toList();
    await preferences.setStringList(
      _customKey,
      _customZikirs.map(_encodeCustomZikir).toList(),
    );
    await preferences.remove('zikir_${zikir.id}_completed');
    await preferences.remove('zikir_${zikir.id}_count');
    if (mounted) {
      setState(() => _completed.remove(zikir.id));
    }
  }

  Future<void> _openZikir(ZikirItem zikir) async {
    var current = zikir;
    while (mounted) {
      var nextRequested = false;
      final index = _items.indexWhere((item) => item.id == current.id);
      final hasNext = _items.any(
        (item) => item.id != current.id && !_completed.contains(item.id),
      );
      await Navigator.of(context).push<bool>(
        MaterialPageRoute<bool>(
          builder: (_) => ZikirTasbihPage(
            zikir: current,
            onNext: hasNext
                ? () {
                    nextRequested = true;
                    Navigator.pop(context, true);
                  }
                : null,
          ),
        ),
      );
      if (!mounted) return;
      await _loadCompleted();
      if (!nextRequested || !mounted) return;
      final following = [..._items.skip(index + 1), ..._items.take(index)];
      final unfinished = following.where(
        (item) => !_completed.contains(item.id),
      );
      if (unfinished.isEmpty) return;
      current = unfinished.first;
    }
  }

  Future<void> _resetAllZikirs() async {
    if (_counts.values.any((count) => count > 0) || _completed.isNotEmpty) {
      if (!await confirmAction(
        context,
        title: 'Reset session?',
        message: 'Clear all counts and completion in this prayer session?',
        action: 'Reset',
      )) {
        return;
      }
      if (!mounted) return;
    }
    final preferences = await SharedPreferences.getInstance();
    final items = [...widget.prayer.zikirs, ..._customZikirs];
    final saved = await saves.run(() async {
      for (final zikir in items) {
        await requireSave(
          preferences.setBool('zikir_${zikir.id}_completed', false),
        );
        await requireSave(preferences.setInt('zikir_${zikir.id}_count', 0));
      }
    });
    if (!saved) return;
    if (mounted) {
      setState(() {
        _completed.clear();
        _counts.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.prayer.name} Dhikr'),
        foregroundColor: const Color(0xFF193C35),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 30),
        children: [
          const Text(
            'Your progress stays saved until you reset this session.',
            style: TextStyle(color: Color(0xFF53685F), fontSize: 15),
          ),
          const SizedBox(height: 16),
          Text(
            '${_completed.length} of ${_items.length} completed',
            style: const TextStyle(color: secondaryInk),
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: _items.isEmpty ? 0 : _completed.length / _items.length,
            minHeight: 4,
            borderRadius: BorderRadius.circular(4),
            backgroundColor: const Color(0xFFDDE9DF),
          ),
          const SizedBox(height: 18),
          if (_completed.length < _items.length)
            FilledButton.icon(
              onPressed: _loading
                  ? null
                  : () => _openZikir(
                      _items.firstWhere(
                        (item) => !_completed.contains(item.id),
                      ),
                    ),
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(
                _counts.values.any((count) => count > 0) ||
                        _completed.isNotEmpty
                    ? 'Continue session'
                    : 'Start dhikr',
              ),
            )
          else
            const Text(
              'Session complete',
              style: TextStyle(
                color: primaryGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          const SizedBox(height: 24),
          ...widget.prayer.zikirs.map((zikir) => _buildZikirTile(zikir)),
          ..._customZikirs.map(
            (zikir) => _buildZikirTile(zikir, isCustom: true),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _addCustomZikir,
            icon: const Icon(Icons.add),
            label: const Text('Add custom dhikr or dua'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF1F5B4D),
              side: const BorderSide(color: Color(0xFFC7D8CC)),
            ),
          ),
          const SizedBox(height: 24),
          TextButton.icon(
            onPressed: _resetAllZikirs,
            icon: const Icon(Icons.refresh, size: 19),
            label: const Text('Reset session'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFB98A5A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZikirTile(ZikirItem zikir, {bool isCustom = false}) {
    final isCompleted = _completed.contains(zikir.id);
    final titleStyle = TextStyle(
      color: isCompleted ? const Color(0xFF4D8A70) : const Color(0xFF193C35),
      fontSize: 17,
      fontWeight: FontWeight.bold,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: isCompleted
            ? const Color(0xFFE8F1EA)
            : Colors.white.withValues(alpha: .7),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0xFFD6DED3)),
        ),
        elevation: 1,
        shadowColor: const Color(0x14193C35),
        child: InkWell(
          onTap: () => _openZikir(zikir),
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Row(
              children: [
                _StatusIcon(
                  isCompleted: isCompleted,
                  count: _counts[zikir.id] ?? 0,
                  target: zikir.target ?? 0,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(zikir.name, style: titleStyle),
                      const SizedBox(height: 4),
                      Text(
                        '${_counts[zikir.id] ?? 0} of ${zikir.target} recitations',
                        style: TextStyle(
                          color: const Color(0xFF53685F),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isCustom)
                  PopupMenuButton<String>(
                    tooltip: 'Actions for ${zikir.name}',
                    onSelected: (_) => _deleteCustomZikir(zikir),
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                const Icon(
                  Icons.chevron_right,
                  size: 22,
                  color: Color(0xFF806333),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AddDailyDhikrPage extends StatefulWidget {
  const AddDailyDhikrPage({super.key});

  @override
  State<AddDailyDhikrPage> createState() => _AddDailyDhikrPageState();
}

class _AddDailyDhikrPageState extends State<AddDailyDhikrPage> {
  final _dhikrController = TextEditingController();
  final _targetController = TextEditingController(text: '1');
  String? _error;

  @override
  void dispose() {
    _dhikrController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  void _save() {
    final dhikr = _dhikrController.text.trim();
    final target = int.tryParse(_targetController.text.trim());
    if (dhikr.isEmpty) {
      setState(() => _error = 'Enter your Dhikr or Dua.');
      return;
    }
    if (target == null || target < _minimumTarget || target > _maximumTarget) {
      setState(() => _error = 'Target must be a whole number from 1 to 10000.');
      return;
    }

    Navigator.of(context).pop(
      ZikirItem(id: newDhikrId(), name: dhikr, arabic: dhikr, target: target),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Daily Dhikr'),
        foregroundColor: const Color(0xFF193C35),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
        children: [
          const Text(
            'New prayer remembrance',
            style: TextStyle(
              color: Color(0xFF193C35),
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add a custom dua or dhikr to this prayer time.',
            style: TextStyle(color: Color(0xFF53685F), fontSize: 15),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _dhikrController,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: 'Dhikr or Dua',
              hintText: 'Write it in any language',
              errorText: _error,
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _targetController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            maxLength: 5,
            decoration: InputDecoration(
              labelText: 'Target',
              hintText: '1 to 10000',
              counterText: '',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 22),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            runSpacing: 8,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ZikirTasbihPage extends StatefulWidget {
  const ZikirTasbihPage({
    super.key,
    required this.zikir,
    this.allowTargetEditing = false,
    this.targetKey,
    this.onNext,
  });
  final ZikirItem zikir;
  final bool allowTargetEditing;
  final String? targetKey;
  final VoidCallback? onNext;
  @override
  State<ZikirTasbihPage> createState() => _ZikirTasbihPageState();
}

class _ZikirTasbihPageState extends State<ZikirTasbihPage> {
  late final String _countKey = 'zikir_${widget.zikir.id}_count';
  late final String _freeKey = 'dhikr_free_${widget.zikir.id}';
  int _count = 0;
  int? _target;
  bool _isLoading = true;
  bool _canUndo = false;
  bool _milestoneSent = false;

  @override
  void initState() {
    super.initState();
    _loadProgress();
    CountingFeedback.instance.load();
  }

  Future<void> _loadProgress() async {
    await saves.idle;
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _count = prefs.getInt(_countKey) ?? 0;
      _target = widget.allowTargetEditing
          ? ((prefs.getBool(_freeKey) ?? false)
                ? null
                : prefs.getInt(widget.targetKey ?? '') ??
                      widget.zikir.target ??
                      33)
          : widget.zikir.target;
      _milestoneSent = _target != null && _count >= _target!;
      _isLoading = false;
    });
  }

  void _increment() {
    if (_isLoading) return;
    final milestone =
        _target != null && _count + 1 >= _target! && !_milestoneSent;
    setState(() {
      _count++;
      _canUndo = true;
      if (milestone) _milestoneSent = true;
    });
    CountingFeedback.instance.play(milestone: milestone);
    _saveProgress();
  }

  Future<bool> _saveProgress() {
    final count = _count;
    final target = _target;
    return saves.run(() async {
      final prefs = await SharedPreferences.getInstance();
      await requireSave(prefs.setInt(_countKey, count));
      if (widget.allowTargetEditing) {
        await requireSave(prefs.setBool(_freeKey, target == null));
        if (target != null && widget.targetKey != null) {
          await requireSave(prefs.setInt(widget.targetKey!, target));
        }
      }
      if (!widget.allowTargetEditing) {
        await requireSave(
          prefs.setBool(
            'zikir_${widget.zikir.id}_completed',
            target != null && count >= target,
          ),
        );
      }
    });
  }

  void _undo() {
    if (!_canUndo || _count == 0) return;
    setState(() {
      _count--;
      _canUndo = false;
      _milestoneSent = _target != null && _count >= _target!;
    });
    _saveProgress();
  }

  Future<void> _resetCount() async {
    if (_isLoading) return;
    if (_count > 0 &&
        !await confirmAction(
          context,
          title: 'Reset count?',
          message: 'Clear the count for this dhikr?',
          action: 'Reset',
        )) {
      return;
    }
    if (!mounted) return;
    setState(() {
      _count = 0;
      _canUndo = false;
      _milestoneSent = false;
    });
    await _saveProgress();
  }

  void _changeTarget(int? target) {
    setState(() {
      _target = target;
      _milestoneSent = target != null && _count >= target;
    });
    _saveProgress();
  }

  Future<void> _complete({bool next = false}) async {
    if (!await _saveProgress() || !mounted) return;
    if (next && widget.onNext != null) {
      widget.onNext!();
    } else {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final complete = _target != null && _count >= _target!;
    return Scaffold(
      appBar: AppBar(title: const Text('Dhikr Tasbih')),
      body: SafeArea(
        child: SingleChildScrollView(
          key: const ValueKey('dhikr-counter-scroll'),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            // Tight horizontal constraints keep every section on the same axis.
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DhikrReadingCard(
                name: widget.zikir.name,
                arabic: widget.zikir.arabic,
                transliteration: widget.zikir.transliteration,
                meaning: widget.zikir.meaning,
                contextNote: widget.zikir.recommendation,
              ),
              if (widget.allowTargetEditing) ...[
                const SizedBox(height: 20),
                DhikrTargetChoices(
                  target: _target,
                  onChanged: _changeTarget,
                  enabled: !_isLoading,
                ),
              ],
              const SizedBox(height: 24),
              CounterSurface(
                count: _count,
                target: _target,
                loading: _isLoading,
                label: widget.zikir.name,
                onTap: _isLoading ? null : _increment,
              ),
              const SizedBox(height: 16),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 16,
                runSpacing: 4,
                children: [
                  TextButton.icon(
                    onPressed: _canUndo ? _undo : null,
                    icon: const Icon(Icons.undo, size: 20),
                    label: const Text('Undo'),
                  ),
                  TextButton.icon(
                    onPressed: _isLoading ? null : _resetCount,
                    icon: const Icon(Icons.refresh, size: 20),
                    label: const Text('Reset count'),
                  ),
                ],
              ),
              const FeedbackControls(),
              const SizedBox(height: 16),
              // Reserve the actual wrapped/scaled action layout, not a fixed
              // height. No content above this section moves at the milestone.
              Visibility(
                visible: complete,
                maintainSize: true,
                maintainState: true,
                maintainAnimation: true,
                child: Column(
                  key: const ValueKey('completion-section'),
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Alhamdulillah! Completed.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: primaryGreen,
                        fontWeight: FontWeight.bold,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        if (widget.onNext != null)
                          FilledButton.icon(
                            onPressed: () => _complete(next: true),
                            icon: const Icon(Icons.arrow_forward, size: 20),
                            label: const Text('Next dhikr'),
                          ),
                        TextButton(
                          onPressed: _complete,
                          child: const Text('Done'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
