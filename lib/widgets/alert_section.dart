import 'package:flutter/material.dart';

class AlertSection extends StatelessWidget {
  final double levelCm;
  final double threshold;
  final bool notificationsEnabled;

  const AlertSection({
    super.key,
    required this.levelCm,
    required this.threshold,
    required this.notificationsEnabled,
  });

  @override
  Widget build(BuildContext context) {
    final status = _buildStatus(levelCm);
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: status.color.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: status.color,
              child: Icon(status.icon, color: colorScheme.onPrimary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Alert',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: status.color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Threshold ${threshold.toStringAsFixed(0)} cm',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: status.color,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    status.label,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: status.color,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Latest reading: ${levelCm.toStringAsFixed(1)} cm',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    notificationsEnabled
                        ? 'Notifications armed'
                        : 'Notifications disabled',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: notificationsEnabled
                              ? Colors.greenAccent.shade200
                              : colorScheme.outline,
                        ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh data',
              onPressed: () {},
            )
          ],
        ),
      ),
    );
  }

  _AlertStatus _buildStatus(double level) {
    final severe = threshold + 100;
    if (level >= severe) {
      return _AlertStatus(
        label: 'Severe (≥ ${severe.toStringAsFixed(0)} cm)',
        color: Colors.red.shade600,
        icon: Icons.warning_amber_rounded,
      );
    }
    if (level >= threshold) {
      return _AlertStatus(
        label: 'High (≥ ${threshold.toStringAsFixed(0)} cm)',
        color: Colors.orange.shade600,
        icon: Icons.error_outline,
      );
    }
    return _AlertStatus(
      label: 'Normal (≤ ${threshold.toStringAsFixed(0)} cm)',
      color: Colors.green.shade600,
      icon: Icons.check_circle,
    );
  }
}

class _AlertStatus {
  final String label;
  final Color color;
  final IconData icon;

  _AlertStatus({
    required this.label,
    required this.color,
    required this.icon,
  });
}
