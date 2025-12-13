import 'dart:async';

import 'package:flutter/material.dart';

import 'screens/account_screen.dart';
import 'screens/river_dashboard_screen.dart';
import 'screens/settings_screen.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RiverLevelsApp());
}

class RiverLevelsApp extends StatefulWidget {
  const RiverLevelsApp({super.key});

  @override
  State<RiverLevelsApp> createState() => _RiverLevelsAppState();
}

class _RiverLevelsAppState extends State<RiverLevelsApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  ThemeMode _themeMode = ThemeMode.dark;
  double _alertThreshold = 300;
  bool _mobileAlertsEnabled = true;
  bool _desktopAlertsEnabled = false;

  void toggleTheme(bool dark) {
    setState(() {
      _themeMode = dark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  void initState() {
    super.initState();
    NotificationService.instance.init();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flood Monitor for Wales River',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _themeMode,
      navigatorKey: _navigatorKey,
      home: RiverDashboardScreen(
        alertThreshold: _alertThreshold,
        notificationsEnabled: _mobileAlertsEnabled || _desktopAlertsEnabled,
        onOpenSettings: () {
          _navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (_) => SettingsScreen(
                isDark: _themeMode == ThemeMode.dark,
                onThemeChanged: toggleTheme,
                alertThreshold: _alertThreshold,
                onThresholdChanged: (value) {
                  setState(() => _alertThreshold = value);
                },
                mobileAlertsEnabled: _mobileAlertsEnabled,
                desktopAlertsEnabled: _desktopAlertsEnabled,
                onMobileAlertsChanged: (value) {
                  setState(() => _mobileAlertsEnabled = value);
                },
                onDesktopAlertsChanged: (value) {
                  setState(() => _desktopAlertsEnabled = value);
                },
              ),
            ),
          );
        },
        onOpenAccount: () {
          _navigatorKey.currentState?.push(
            MaterialPageRoute(builder: (_) => const AccountScreen()),
          );
        },
        onAlertRequested: (station) async {
          if (!_mobileAlertsEnabled && !_desktopAlertsEnabled) {
            return;
          }
          if (station.currentLevelCm < _alertThreshold) {
            return;
          }
          await NotificationService.instance.sendThresholdAlert(
            stationName: station.name,
            levelCm: station.currentLevelCm,
            threshold: _alertThreshold,
            toMobile: _mobileAlertsEnabled,
            toDesktop: _desktopAlertsEnabled,
          );
        },
      ),
    );
  }
}
