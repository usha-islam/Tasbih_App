import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'counter_widgets.dart';

/// Scoped selector for editable Dhikr List counters; shared defaults stay unchanged.
class DhikrTargetChoices extends StatelessWidget {
  const DhikrTargetChoices({
    super.key,
    required this.target,
    required this.onChanged,
    this.enabled = true,
  });
  final int? target;
  final ValueChanged<int?> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    const labels = ['33', '100', 'Custom', 'Free count'];
    const style = TextStyle(
      fontFamily: 'Lato',
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: inkGreen,
      height: 1.25,
    );
    final scaler = MediaQuery.textScalerOf(context);
    final direction = Directionality.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Personal counting goal',
          textAlign: TextAlign.center,
          style: TextStyle(color: secondaryInk, fontSize: 13, height: 1.4),
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            Size measure(String label, double width) {
              final painter = TextPainter(
                text: TextSpan(text: label, style: style),
                textDirection: direction,
                textScaler: scaler,
              )..layout(maxWidth: width);
              final size = painter.size;
              painter.dispose();
              return size;
            }

            const gap = 8.0;
            final natural = labels
                .map(
                  (s) => math.max(
                    48.0,
                    measure(s, double.infinity).width.ceilToDouble() + 28,
                  ),
                )
                .toList();
            final singleRow =
                natural.reduce((a, b) => a + b) + 3 * gap <=
                constraints.maxWidth;
            final widths = singleRow
                ? natural
                : List.filled(4, (constraints.maxWidth - gap) / 2);
            final labelHeight = math.max(
              28.0,
              List.generate(
                4,
                (i) => measure(labels[i], widths[i] - 28).height.ceilToDouble(),
              ).reduce(math.max),
            );
            final height = labelHeight + 22;
            Widget choice(int index) {
              final selected = switch (index) {
                0 => target == 33,
                1 => target == 100,
                2 => target != null && target != 33 && target != 100,
                _ => target == null,
              };
              return SizedBox(
                key: ValueKey('dhikr-target-$index'),
                width: widths[index],
                height: height,
                child: ChoiceChip(
                  label: SizedBox(
                    width: widths[index] - 28,
                    height: labelHeight,
                    child: Center(
                      child: Text(labels[index], textAlign: TextAlign.center),
                    ),
                  ),
                  labelStyle: style,
                  labelPadding: EdgeInsets.zero,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  selected: selected,
                  showCheckmark: false,
                  visualDensity: VisualDensity.standard,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  backgroundColor: const Color(0xFFF7F3EA),
                  selectedColor: const Color(0xFFDDE9DF),
                  disabledColor: const Color(0xFFE8EAE2),
                  side: const BorderSide(color: Color(0xFFB8C9BE), width: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: !enabled
                      ? null
                      : (_) async {
                          if (index == 2) {
                            final value = await choosePersonalTarget(
                              context,
                              target,
                            );
                            if (value != null && context.mounted) {
                              onChanged(value);
                            }
                          } else {
                            onChanged(switch (index) {
                              0 => 33,
                              1 => 100,
                              _ => null,
                            });
                          }
                        },
                ),
              );
            }

            Widget row(List<int> indices) => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < indices.length; i++) ...[
                  if (i > 0) const SizedBox(width: gap),
                  choice(indices[i]),
                ],
              ],
            );
            return singleRow
                ? row([0, 1, 2, 3])
                : Column(
                    children: [
                      row([0, 1]),
                      const SizedBox(height: gap),
                      row([2, 3]),
                    ],
                  );
          },
        ),
      ],
    );
  }
}
