import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Handles local notifications for threshold alerts. This does not send remote
/// push messages – it simply surfaces a notification while the app is running
/// (foreground or background) on supported platforms.
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
    'river_alerts',
    'River level alerts',
    description:
        'Notifications when a monitored station exceeds the configured threshold.',
    importance: Importance.high,
  );

  bool _initialised = false;
  int _notificationId = 0;

  Future<void> init() async {
    if (_initialised) return;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: darwinInit,
      macOS: darwinInit,
    );

    await _plugin.initialize(initSettings);
    await _createChannelIfNeeded();
    await requestPermissions();

    _initialised = true;
    debugPrint('NotificationService initialised.');
  }

  Future<void> _createChannelIfNeeded() async {
    final androidImplementation = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImplementation?.createNotificationChannel(_androidChannel);
  }

  Future<void> requestPermissions() async {
    final androidImplementation = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImplementation?.requestNotificationsPermission();

    final darwinImplementation = _plugin
        .resolvePlatformSpecificImplementation<
            DarwinFlutterLocalNotificationsPlugin>();
    await darwinImplementation?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> sendThresholdAlert({
    required String stationName,
    required double levelCm,
    required double threshold,
    required bool toMobile,
    required bool toDesktop,
  }) async {
    if (!toMobile && !toDesktop) return;
    if (!_initialised) {
      await init();
    }

    final body =
        '${stationName.isEmpty ? 'Station' : stationName} is at ${levelCm.toStringAsFixed(1)} cm (limit ${threshold.toStringAsFixed(0)} cm).';

    final androidDetails = AndroidNotificationDetails(
      _androidChannel.id,
      _androidChannel.name,
      channelDescription: _androidChannel.description,
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'River alert',
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    await _plugin.show(
      _notificationId++,
      'Flood alert: $stationName',
      body,
      notificationDetails,
    );
  }
}
