import 'package:flutter/material.dart';

import '../models/tank_sensor_reading.dart';
import 'river_level_chart.dart';
import 'river_map_view.dart';

class TankSensorDashboard extends StatelessWidget {
  final TankSensorReading? reading;
  final List<double> waterHistory;
  final double? latitude;
  final double? longitude;
  final String stationName;

  const TankSensorDashboard({
    super.key,
    required this.reading,
    required this.waterHistory,
    required this.stationName,
    this.latitude,
    this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    if (reading == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Waiting for tank sensors…'),
            ],
          ),
        ),
      );
    }

    final alert = _alertForLevel(reading!.waterLevel);

    return Column(
      children: [
        _MetricsRow(reading: reading!),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tank capacity',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (reading!.percentFull / 100).clamp(0, 1),
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest,
                  minHeight: 14,
                ),
                const SizedBox(height: 8),
                Text(
                  '${reading!.percentFull.toStringAsFixed(1)}% full',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          color: alert.color.withValues(alpha: 0.15),
          child: ListTile(
            leading: Icon(alert.icon, color: alert.color, size: 32),
            title: Text(
              alert.message,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: alert.color),
            ),
            subtitle: Text(
              'Latest water level: ${reading!.waterLevel.toStringAsFixed(1)} cm',
            ),
          ),
        ),
        const SizedBox(height: 16),
        RiverLevelChart(
          data: waterHistory,
          title: 'Water level history',
          subtitle: 'Tank sensor readings (cm)',
        ),
        const SizedBox(height: 16),
        RiverMapView(
          latitude: latitude,
          longitude: longitude,
          stationName: stationName,
        ),
      ],
    );
  }

  _TankAlert _alertForLevel(double level) {
    if (level < 30) {
      return _TankAlert(
        message: 'WARNING: CRITICAL LOW - Refill Required',
        color: Colors.red.shade400,
        icon: Icons.warning,
      );
    }
    if (level < 60) {
      return _TankAlert(
        message: 'ALERT: LOW - Monitor Closely',
        color: Colors.orange.shade400,
        icon: Icons.priority_high,
      );
    }
    if (level > 180) {
      return _TankAlert(
        message: 'DANGER: OVERFLOW RISK - Stop Filling',
        color: Colors.red.shade700,
        icon: Icons.bolt,
      );
    }
    if (level > 150) {
      return _TankAlert(
        message: 'OK: HIGH - Tank Nearly Full',
        color: Colors.lightBlue.shade300,
        icon: Icons.info,
      );
    }
    return _TankAlert(
      message: 'OK: NORMAL - Adequate Supply',
      color: Colors.green.shade400,
      icon: Icons.check_circle,
    );
  }
}

class _MetricsRow extends StatelessWidget {
  final TankSensorReading reading;

  const _MetricsRow({required this.reading});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            label: 'Temperature',
            value: '${reading.temperature.toStringAsFixed(1)} °C',
            icon: Icons.thermostat,
            color: Colors.redAccent,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MetricCard(
            label: 'Humidity',
            value: '${reading.humidity.toStringAsFixed(1)} %',
            icon: Icons.water_drop,
            color: Colors.blueAccent,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MetricCard(
            label: 'Water level',
            value: '${reading.waterLevel.toStringAsFixed(1)} cm',
            icon: Icons.waves,
            color: Colors.tealAccent,
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(color: color),
            ),
            const SizedBox(height: 4),
            Text(label),
          ],
        ),
      ),
    );
  }
}

class _TankAlert {
  final String message;
  final Color color;
  final IconData icon;

  _TankAlert({
    required this.message,
    required this.color,
    required this.icon,
  });
}
