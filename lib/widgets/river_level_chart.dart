import 'dart:math' as math;

import 'package:flutter/material.dart';

class RiverLevelChart extends StatelessWidget {
  final List<double> data;
  final String title;
  final String subtitle;

  const RiverLevelChart({
    super.key,
    required this.data,
    this.title = 'River level history',
    this.subtitle = 'Last 24 readings (cm)',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lineColor = theme.colorScheme.primary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              width: double.infinity,
              child: CustomPaint(
                painter: _RiverChartPainter(
                  data: data,
                  lineColor: lineColor,
                  gridColor: theme.colorScheme.outlineVariant,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _RiverChartPainter extends CustomPainter {
  final List<double> data;
  final Color lineColor;
  final Color gridColor;

  _RiverChartPainter({
    required this.data,
    required this.lineColor,
    required this.gridColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    const gridLines = 4;
    for (var i = 0; i <= gridLines; i++) {
      final dy = size.height / gridLines * i;
      canvas.drawLine(Offset(0, dy), Offset(size.width, dy), gridPaint);
    }

    if (data.length < 2) {
      return;
    }

    final minValue = data.reduce(math.min);
    final maxValue = data.reduce(math.max);
    final range = (maxValue - minValue).abs();
    final denominator = range == 0 ? 1 : range;

    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    final fillPaint = Paint()
      ..color = lineColor.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    final dx = size.width / (data.length - 1);

    for (var i = 0; i < data.length; i++) {
      final x = dx * i;
      final normalized = (data[i] - minValue) / denominator;
      final y = size.height - (normalized * size.height);
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _RiverChartPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.gridColor != gridColor;
  }
}
