import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'counter_widgets.dart';

/// Home-only presentation; shared target controls and other pages are unchanged.
class HomeTargetChoices extends StatelessWidget {
  const HomeTargetChoices({
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
          style: TextStyle(color: secondaryInk, fontSize: 14, height: 1.4),
        ),
        const SizedBox(height: 10),
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
            final height = labelHeight + 22.4;
            Widget choice(int index) {
              final selected = switch (index) {
                0 => target == 33,
                1 => target == 100,
                2 => target != null && target != 33 && target != 100,
                _ => target == null,
              };
              return SizedBox(
                key: ValueKey('home-target-$index'),
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
                  side: const BorderSide(color: Color(0xFFBCD2C7), width: 1.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
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

class HomeWelcomeCard extends StatelessWidget {
  const HomeWelcomeCard({super.key});
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final illustrationWidth = (constraints.maxWidth * .31).clamp(76.0, 112.0);
      return Container(
        key: const ValueKey('home-welcome-card'),
        constraints: const BoxConstraints(minHeight: 124),
        decoration: BoxDecoration(
          color: const Color(0xFFE8EDE2),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'A moment of remembrance',
                    style: TextStyle(
                      color: primaryGreen,
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      height: 1.25,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Keep your heart present',
                    style: TextStyle(
                      color: secondaryInk,
                      fontSize: 14,
                      height: 1.4,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ExcludeSemantics(
              child: SizedBox(
                width: illustrationWidth,
                height: 112,
                child: CustomPaint(painter: _TasbihIllustration()),
              ),
            ),
          ],
        ),
      );
    },
  );
}

/// Separate, resolution-independent artwork drawn locally, not a screenshot.
class _TasbihIllustration extends CustomPainter {
  const _TasbihIllustration();
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 144, size.height / 150);
    final motif = Paint()
      ..color = const Color(0xFFD5DECC)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final petal = Path()
      ..moveTo(80, 4)
      ..cubicTo(92, 25, 120, 20, 122, 47)
      ..cubicTo(124, 62, 117, 66, 137, 78)
      ..cubicTo(118, 88, 126, 109, 105, 120)
      ..cubicTo(92, 123, 84, 131, 80, 142)
      ..cubicTo(72, 128, 60, 128, 50, 119)
      ..cubicTo(30, 113, 39, 90, 20, 78)
      ..cubicTo(40, 68, 31, 52, 44, 36)
      ..cubicTo(54, 24, 72, 23, 80, 4)
      ..close();
    canvas.drawPath(petal, motif);
    canvas.save();
    canvas.translate(80, 75);
    canvas.scale(.76);
    canvas.translate(-80, -75);
    canvas.drawPath(petal, motif);
    canvas.restore();
    canvas.drawLine(const Offset(80, 18), const Offset(80, 134), motif);
    canvas.drawLine(const Offset(32, 78), const Offset(128, 78), motif);

    Offset bead(double t) {
      final x = 49 * math.cos(t), y = 27 * math.sin(t), a = -.58;
      return Offset(
        85 + x * math.cos(a) - y * math.sin(a),
        68 + x * math.sin(a) + y * math.cos(a),
      );
    }

    final string = Path()..moveTo(bead(0).dx, bead(0).dy);
    for (var i = 1; i <= 96; i++) {
      final p = bead(i * 2 * math.pi / 96);
      string.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
      string,
      Paint()
        ..color = const Color(0xFFB58C47)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.7,
    );
    for (var i = 0; i < 26; i++) {
      final p = bead(i * 2 * math.pi / 26);
      final gold = i % 4 == 0;
      canvas.drawCircle(
        p.translate(.7, 1),
        5.0,
        Paint()..color = const Color(0x1821493A),
      );
      canvas.drawCircle(
        p,
        4.8,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-.4, -.4),
            colors: gold
                ? const [Color(0xFFD2C59E), Color(0xFFAD9869)]
                : const [Color(0xFF3C7464), Color(0xFF1E5043)],
          ).createShader(Rect.fromCircle(center: p, radius: 5)),
      );
      canvas.drawCircle(
        p,
        4.8,
        Paint()
          ..color = const Color(0xFFB48A43)
          ..style = PaintingStyle.stroke
          ..strokeWidth = .7,
      );
    }
    final join = bead(math.pi * .88);
    final cord = Paint()
      ..color = const Color(0xFFB48A43)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final tassel = const Offset(35, 110);
    canvas.drawLine(join, tassel, cord);
    for (var i = 0; i < 3; i++) {
      final p = Offset.lerp(join, tassel, (i + 1) / 4)!;
      canvas.drawOval(
        Rect.fromCenter(center: p, width: 8, height: 6),
        Paint()..color = const Color(0xFFC1AC79),
      );
      canvas.drawOval(
        Rect.fromCenter(center: p, width: 8, height: 6),
        cord..strokeWidth = .7,
      );
    }
    for (var i = 0; i < 10; i++) {
      final x = 12 + i * 2.8;
      canvas.drawPath(
        Path()
          ..moveTo(tassel.dx, tassel.dy)
          ..quadraticBezierTo(20 + i * 1.5, 126, x, 143 - math.sin(i * .3) * 4),
        Paint()
          ..color = i.isEven ? const Color(0xFF285B4D) : const Color(0xFFB48A43)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8
          ..strokeCap = StrokeCap.round,
      );
    }
    canvas.drawLine(
      const Offset(30, 115),
      const Offset(36, 118),
      cord..strokeWidth = 3,
    );
    void star(Offset p, double r) {
      canvas.drawPath(
        Path()
          ..moveTo(p.dx, p.dy - r)
          ..quadraticBezierTo(p.dx + 1, p.dy - 1, p.dx + r, p.dy)
          ..quadraticBezierTo(p.dx + 1, p.dy + 1, p.dx, p.dy + r)
          ..quadraticBezierTo(p.dx - 1, p.dy + 1, p.dx - r, p.dy)
          ..quadraticBezierTo(p.dx - 1, p.dy - 1, p.dx, p.dy - r)
          ..close(),
        Paint()
          ..color = const Color(0xFFB68A3F)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
    }

    star(const Offset(18, 42), 7);
    star(const Offset(126, 116), 6);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _TasbihIllustration oldDelegate) => false;
}
