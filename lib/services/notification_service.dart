import 'package:flutter/foundation.dart';

/// Placeholder notification service. Replace the debugPrint calls with a real
/// push/local notifications implementation (e.g. Firebase Cloud Messaging on
/// mobile plus a desktop notifier) when wiring up the backend.
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  Future<void> init() async {
    debugPrint('NotificationService initialised (stub).');
  }

  Future<void> requestPermissions() async {
    debugPrint('Requesting notification permissions (stub).');
  }

  Future<void> sendThresholdAlert({
    required String stationName,
    required double levelCm,
    required double threshold,
    required bool toMobile,
    required bool toDesktop,
  }) async {
    debugPrint(
      'ALERT: $stationName is at ${levelCm.toStringAsFixed(1)} cm '
      '(threshold $threshold) → mobile:$toMobile desktop:$toDesktop',
    );
  }

}
