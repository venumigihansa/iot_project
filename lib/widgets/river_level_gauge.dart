import 'dart:math' as math;

import 'package:flutter/material.dart';

class RiverLevelGauge extends StatelessWidget {
  final double levelCm;
  final double maxLevel;
  final double threshold;

  const RiverLevelGauge({
    super.key,
    required this.levelCm,
    required this.threshold,
    this.maxLevel = 500,
  });

  @override
  Widget build(BuildContext context) {
    final double clamped = levelCm.clamp(0, maxLevel).toDouble();
    final colorScheme = Theme.of(context).colorScheme;
    final _GaugeStyle style =
        _GaugeStyle.forLevel(levelCm, threshold, colorScheme);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: style.accent, width: 2),
      ),
      color: style.background,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(style.icon, color: style.accent),
                const SizedBox(width: 8),
                Text(
                  style.label,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: style.accent),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Center(
              child: _AnimatedGauge(
                value: clamped,
                max: maxLevel,
                accent: style.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedGauge extends StatelessWidget {
  final double value;
  final double max;
  final Color accent;

  const _AnimatedGauge({
    required this.value,
    required this.max,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: value),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, animValue, _) {
        final progress = max == 0 ? 0.0 : (animValue / max).clamp(0.0, 1.0);
        return SizedBox(
          width: 220,
          height: 220,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size.square(220),
                painter: _GaugePainter(
                  progress: progress,
                  accent: accent,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    animValue.toStringAsFixed(0),
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: accent,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    'Current Level (cm)',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: accent),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double progress;
  final Color accent;

  _GaugePainter({required this.progress, required this.accent});

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 18.0;
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = (size.shortestSide - strokeWidth) / 2;

    final backgroundPaint = Paint()
      ..color = accent.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    final foregroundPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          accent.withValues(alpha: 0.8),
          accent,
        ],
      ).createShader(
        Rect.fromCircle(center: center, radius: radius),
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final startAngle = 3 * math.pi / 4;
    final sweepAngle = 3 * math.pi / 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      backgroundPaint,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle * progress,
      false,
      foregroundPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.accent != accent;
  }
}

class _GaugeStyle {
  final Color background;
  final Color accent;
  final String label;
  final IconData icon;

  _GaugeStyle({
    required this.background,
    required this.accent,
    required this.label,
    required this.icon,
  });

  factory _GaugeStyle.forLevel(
      double level, double threshold, ColorScheme colorScheme) {
    final severeLevel = threshold + 100;
    final isDark = colorScheme.brightness == Brightness.dark;

    if (level >= severeLevel) {
      return _GaugeStyle(
        background: isDark
            ? Colors.red.shade900.withValues(alpha: 0.2)
            : Colors.red.shade100.withValues(alpha: 0.8),
        accent:
            isDark ? Colors.redAccent.shade100 : Colors.red.shade800,
        label: 'Severe',
        icon: Icons.warning_amber_rounded,
      );
    }
    if (level >= threshold) {
      return _GaugeStyle(
        background: isDark
            ? Colors.orange.shade900.withValues(alpha: 0.25)
            : Colors.orange.shade100.withValues(alpha: 0.9),
        accent: isDark
            ? Colors.orange.shade200
            : Colors.orange.shade700,
        label: 'High',
        icon: Icons.error_outline,
      );
    }
    return _GaugeStyle(
      background: isDark
          ? Colors.green.shade900.withValues(alpha: 0.25)
          : Colors.green.shade100.withValues(alpha: 0.9),
      accent: isDark
          ? Colors.greenAccent.shade200
          : Colors.green.shade800,
      label: 'Safe',
      icon: Icons.check_circle,
    );
  }
}
