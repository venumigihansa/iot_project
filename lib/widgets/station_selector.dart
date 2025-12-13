import 'package:flutter/material.dart';

import '../models/station.dart';

class StationSelector extends StatelessWidget {
  final List<Station> stations;
  final Station selected;
  final ValueChanged<Station> onChanged;

  const StationSelector({
    super.key,
    required this.stations,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Station',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            DropdownMenu<String>(
              initialSelection: selected.id,
              label: const Text('River monitoring stations'),
              trailingIcon: const Icon(Icons.arrow_drop_down),
              onSelected: (value) {
                if (value == null) return;
                final next =
                    stations.firstWhere((station) => station.id == value);
                onChanged(next);
              },
              dropdownMenuEntries: stations
                  .map(
                    (station) => DropdownMenuEntry<String>(
                      value: station.id,
                      label: station.name,
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 8),
            Text(
              'Showing live level for ${selected.name}',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: colorScheme.outline),
            ),
          ],
        ),
      ),
    );
  }
}
