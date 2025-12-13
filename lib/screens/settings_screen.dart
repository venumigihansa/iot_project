import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  final bool isDark;
  final ValueChanged<bool> onThemeChanged;
  final double alertThreshold;
  final ValueChanged<double> onThresholdChanged;
  final bool mobileAlertsEnabled;
  final bool desktopAlertsEnabled;
  final ValueChanged<bool> onMobileAlertsChanged;
  final ValueChanged<bool> onDesktopAlertsChanged;

  const SettingsScreen({
    super.key,
    required this.isDark,
    required this.onThemeChanged,
    required this.alertThreshold,
    required this.onThresholdChanged,
    required this.mobileAlertsEnabled,
    required this.desktopAlertsEnabled,
    required this.onMobileAlertsChanged,
    required this.onDesktopAlertsChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Appearance',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Switch between the bright daytime look and a darker dashboard better suited for night monitoring.',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(
                        value: false,
                        label: Text('Light'),
                        icon: Icon(Icons.sunny),
                      ),
                      ButtonSegment(
                        value: true,
                        label: Text('Dark'),
                        icon: Icon(Icons.dark_mode),
                      ),
                    ],
                    selected: {isDark},
                    onSelectionChanged: (selection) {
                      if (selection.isNotEmpty) {
                        onThemeChanged(selection.first);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Alerts & notifications',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose when to warn you about river levels and which platforms should receive a push notification.',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Threshold: ${alertThreshold.toStringAsFixed(0)} cm',
                    style: theme.textTheme.labelLarge,
                  ),
                  Slider(
                    value: alertThreshold,
                    min: 100,
                    max: 500,
                    divisions: 40,
                    label: alertThreshold.toStringAsFixed(0),
                    onChanged: onThresholdChanged,
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    value: mobileAlertsEnabled,
                    onChanged: onMobileAlertsChanged,
                    title: const Text('Mobile push notifications'),
                    subtitle: const Text('Use FCM/APNS to notify phones'),
                    secondary: const Icon(Icons.smartphone),
                  ),
                  SwitchListTile(
                    value: desktopAlertsEnabled,
                    onChanged: onDesktopAlertsChanged,
                    title: const Text('Desktop notifications'),
                    subtitle: const Text('Uses system tray notifications'),
                    secondary: const Icon(Icons.desktop_mac),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: const [
                ListTile(
                  leading: Icon(Icons.layers_outlined),
                  title: Text('Map style'),
                  subtitle: Text('Satellite imagery'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: const [
                ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('Version'),
                  subtitle: Text('1.0.0'),
                ),
                Divider(height: 0),
                ListTile(
                  leading: Icon(Icons.water_damage_outlined),
                  title: Text('Data source'),
                  subtitle: Text('Natural Resources Wales – StationData API'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
