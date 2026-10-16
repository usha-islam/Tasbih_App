import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

const inkGreen = Color(0xFF193C35);
const primaryGreen = Color(0xFF1F5B4D);
const secondaryInk = Color(0xFF53685F);

Future<bool> confirmAction(
  BuildContext context, {
  required String title,
  required String message,
  required String action,
}) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(action),
          ),
        ],
      ),
    ) ??
    false;

Future<int?> choosePersonalTarget(BuildContext context, int? current) =>
    showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => _TargetSheet(current: current),
    );

class _TargetSheet extends StatefulWidget {
  const _TargetSheet({this.current});
  final int? current;
  @override
  State<_TargetSheet> createState() => _TargetSheetState();
}

class _TargetSheetState extends State<_TargetSheet> {
  late final _controller = TextEditingController(
    text: widget.current == null ? '' : '${widget.current}',
  );
  String? _error;
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = int.tryParse(_controller.text.trim());
    if (value == null || value < 1 || value > 10000) {
      setState(() => _error = 'Enter a whole number from 1 to 10000.');
      return;
    }
    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
      24,
      0,
      24,
      24 + MediaQuery.viewInsetsOf(context).bottom,
    ),
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Personal counting goal',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose a target for your own counting.',
            style: TextStyle(color: secondaryInk),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            maxLength: 5,
            decoration: InputDecoration(
              labelText: 'Target',
              hintText: '1 - 10000',
              counterText: '',
              errorText: _error,
            ),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 20),
          FilledButton(onPressed: _submit, child: const Text('Set target')),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    ),
  );
}

class CountingFeedback extends ChangeNotifier {
  CountingFeedback._();
  static final instance = CountingFeedback._();
  bool sound = false;
  bool vibration = false;
  bool _loaded = false;
  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    sound = prefs.getBool('counting_sound') ?? false;
    vibration = prefs.getBool('counting_vibration') ?? false;
    _loaded = true;
    notifyListeners();
  }

  Future<void> toggle({required bool isSound}) async {
    if (isSound) {
      sound = !sound;
    } else {
      vibration = !vibration;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
      isSound ? 'counting_sound' : 'counting_vibration',
      isSound ? sound : vibration,
    );
  }

  Future<void> play({bool milestone = false}) async {
    if (sound) {
      try {
        await SystemSound.play(SystemSoundType.click);
      } catch (_) {
        /* Unsupported platforms stay quiet. */
      }
    }
    if (vibration) {
      try {
        if (await Vibration.hasVibrator()) {
          await Vibration.vibrate(duration: milestone ? 200 : 30);
        }
      } catch (_) {
        /* Counting works without device feedback. */
      }
    }
  }
}

class FeedbackControls extends StatelessWidget {
  const FeedbackControls({super.key});
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: CountingFeedback.instance,
    builder: (context, _) {
      final feedback = CountingFeedback.instance;
      return Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        children: [
          TextButton.icon(
            style: TextButton.styleFrom(
              textStyle: const TextStyle(fontFamily: 'Lato', fontSize: 13),
            ),
            onPressed: () => feedback.toggle(isSound: true),
            icon: Icon(
              feedback.sound
                  ? Icons.volume_up_outlined
                  : Icons.volume_off_outlined,
              size: 20,
            ),
            label: Text('Sound ${feedback.sound ? 'on' : 'off'}'),
          ),
          TextButton.icon(
            style: TextButton.styleFrom(
              textStyle: const TextStyle(fontFamily: 'Lato', fontSize: 13),
            ),
            onPressed: () => feedback.toggle(isSound: false),
            icon: Icon(
              feedback.vibration
                  ? Icons.vibration
                  : Icons.phone_android_outlined,
              size: 20,
            ),
            label: Text('Vibration ${feedback.vibration ? 'on' : 'off'}'),
          ),
        ],
      );
    },
  );
}

class TargetChoices extends StatelessWidget {
  const TargetChoices({
    super.key,
    required this.target,
    required this.onChanged,
    this.enabled = true,
  });
  final int? target;
  final ValueChanged<int?> onChanged;
  final bool enabled;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      const Text(
        'Personal counting goal',
        style: TextStyle(color: secondaryInk, fontSize: 13),
      ),
      const SizedBox(height: 8),
      Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 6,
        children: [
          for (final value in [33, 100])
            ChoiceChip(
              label: Text('$value'),
              selected: target == value,
              onSelected: enabled ? (_) => onChanged(value) : null,
              showCheckmark: false,
              materialTapTargetSize: MaterialTapTargetSize.padded,
            ),
          ChoiceChip(
            label: Text(
              target != null && target != 33 && target != 100
                  ? 'Custom · $target'
                  : 'Custom',
            ),
            selected: target != null && target != 33 && target != 100,
            showCheckmark: false,
            onSelected: enabled
                ? (_) async {
                    final value = await choosePersonalTarget(context, target);
                    if (value != null && context.mounted) onChanged(value);
                  }
                : null,
          ),
          ChoiceChip(
            label: const Text('Free count'),
            selected: target == null,
            showCheckmark: false,
            onSelected: enabled ? (_) => onChanged(null) : null,
          ),
        ],
      ),
    ],
  );
}

class CounterSurface extends StatelessWidget {
  const CounterSurface({
    super.key,
    required this.count,
    required this.target,
    required this.onTap,
    this.loading = false,
    this.label = 'Tasbih',
  });
  final int count;
  final int? target;
  final VoidCallback? onTap;
  final bool loading;
  final String label;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final diameter = constraints.maxWidth.clamp(0.0, 232.0);
      return Center(
        child: SizedBox(
          key: const ValueKey('counter-circle'),
          width: diameter,
          height: diameter,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (target != null && target! > 0)
                Positioned.fill(
                  child: ExcludeSemantics(
                    child: CircularProgressIndicator(
                      value: (count / target!).clamp(0.0, 1.0),
                      strokeWidth: 3,
                      backgroundColor: const Color(0xFFD8E2D7),
                      color: const Color(0xFFB6873D),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Semantics(
                  button: true,
                  label:
                      '$label, count $count${target == null ? ', free count' : ', target $target'}',
                  child: Material(
                    color: primaryGreen,
                    shape: const CircleBorder(
                      side: BorderSide(color: Color(0xFFB98A5A)),
                    ),
                    elevation: 2,
                    shadowColor: const Color(0x33193C35),
                    child: InkWell(
                      onTap: onTap,
                      customBorder: const CircleBorder(),
                      splashFactory: MediaQuery.disableAnimationsOf(context)
                          ? NoSplash.splashFactory
                          : InkRipple.splashFactory,
                      child: SizedBox.expand(
                        child: ExcludeSemantics(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: SizedBox(
                                width: 200,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                      ),
                                      child: SizedBox(
                                        height: 76,
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            loading ? '…' : '$count',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 64,
                                              height: 1.1,
                                              fontWeight: FontWeight.bold,
                                              fontFeatures: [
                                                FontFeature.tabularFigures(),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      target == null
                                          ? 'Free count'
                                          : 'of $target',
                                      style: const TextStyle(
                                        color: Color(0xFFF7F3EA),
                                        fontSize: 17,
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    const Text(
                                      'Tap to count',
                                      style: TextStyle(
                                        color: Color(0xFFDDE9DF),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class ReadingText extends StatelessWidget {
  const ReadingText({
    super.key,
    required this.arabic,
    this.transliteration,
    this.meaning,
  });
  final String arabic;
  final String? transliteration;
  final String? meaning;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        arabic,
        textDirection: readingDirection(arabic),
        textAlign: TextAlign.center,
        style: TextStyle(
          color: primaryGreen,
          fontSize: 28,
          height: 1.65,
          fontFamily: readingDirection(arabic) == TextDirection.rtl
              ? 'NotoNaskhArabic'
              : 'Lato',
          fontFamilyFallback: ['Lato'],
        ),
      ),
      if (transliteration != null) ...[
        const SizedBox(height: 8),
        Text(
          transliteration!,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: secondaryInk,
            fontSize: 15,
            height: 1.5,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
      if (meaning != null) ...[
        const SizedBox(height: 8),
        Text(
          meaning!,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: secondaryInk,
            fontSize: 15,
            height: 1.5,
          ),
        ),
      ],
    ],
  );
}

TextDirection readingDirection(String text) =>
    RegExp(r'[\u0600-\u06ff]').hasMatch(text)
    ? TextDirection.rtl
    : TextDirection.ltr;

/// Long readings scroll independently to keep counting controls within reach.
class BoundedReading extends StatefulWidget {
  const BoundedReading({
    super.key,
    required this.arabic,
    this.transliteration,
    this.meaning,
  });
  final String arabic;
  final String? transliteration;
  final String? meaning;
  @override
  State<BoundedReading> createState() => _BoundedReadingState();
}

class _BoundedReadingState extends State<BoundedReading> {
  final _scroll = ScrollController();
  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reading = ReadingText(
      arabic: widget.arabic,
      transliteration: widget.transliteration,
      meaning: widget.meaning,
    );
    if (widget.arabic.length < 180) return reading;
    return Column(
      children: [
        const Text(
          'Scroll to read the full verse',
          style: TextStyle(color: secondaryInk, fontSize: 13),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: (MediaQuery.sizeOf(context).height * .3).clamp(120.0, 260.0),
          child: Scrollbar(
            controller: _scroll,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: _scroll,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: reading,
            ),
          ),
        ),
      ],
    );
  }
}

/// A compact reading surface; long passages retain their full font size.
class DhikrReadingCard extends StatelessWidget {
  const DhikrReadingCard({
    super.key,
    required this.name,
    required this.arabic,
    this.transliteration,
    this.meaning,
    this.contextNote,
  });
  final String name;
  final String arabic;
  final String? transliteration;
  final String? meaning;
  final String? contextNote;
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: const Color(0xFFFCFAF5),
      border: Border.all(color: const Color(0xFFD6DED3)),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: inkGreen,
              fontSize: 17,
              fontWeight: FontWeight.bold,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          BoundedReading(
            arabic: arabic,
            transliteration: transliteration,
            meaning: meaning,
          ),
          if (contextNote != null) ...[
            const SizedBox(height: 12),
            Text(
              contextNote!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: secondaryInk,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    ),
  );
}
