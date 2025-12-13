import 'package:flutter/material.dart';

import '../models/station.dart';

class StationInfoCards extends StatelessWidget {
  final Station station;

  const StationInfoCards({super.key, required this.station});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _InfoTile(
              icon: Icons.water,
              label: 'Station',
              value: station.name,
              color: colorScheme.primary,
            ),
            _InfoTile(
              icon: Icons.sensors,
              label: 'Parameter',
              value: station.parameter,
              color: colorScheme.secondary,
            ),
            _InfoTile(
              icon: Icons.shutter_speed,
              label: 'Status',
              value: station.status,
              color: station.status.toLowerCase().contains('warn')
                  ? Colors.orange
                  : colorScheme.tertiary,
            ),
            _InfoTile(
              icon: Icons.tag,
              label: 'Location id',
              value: station.id,
              color: colorScheme.outline,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 160,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.labelMedium
                      ?.copyWith(color: theme.colorScheme.outline),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
