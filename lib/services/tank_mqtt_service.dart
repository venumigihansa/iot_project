import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import '../models/tank_sensor_reading.dart';

class TankMqttService {
  static const String _broker = 'broker.hivemq.com';
  static const int _tcpPort = 1883;
  static const int _websocketPort = 8000;
  static const String _topic = 'tank/sensors';
  static const double _maxLevel = 200; // cm

  final StreamController<TankSensorReading> _controller =
      StreamController<TankSensorReading>.broadcast();

  MqttServerClient? _client;
  bool _connecting = false;

  Stream<TankSensorReading> get readings => _controller.stream;

  Future<void> connect() async {
    if (_connecting) return;
    if (_client?.connectionStatus?.state == MqttConnectionState.connected) {
      return;
    }
    _connecting = true;
    _client = MqttServerClient.withPort(
      _broker,
      'river_tank_${DateTime.now().millisecondsSinceEpoch}',
      kIsWeb ? _websocketPort : _tcpPort,
    );
    _client!.logging(on: false);
    _client!.keepAlivePeriod = 60;
    _client!.secure = false;
    _client!.onDisconnected = _onDisconnected;
    _client!.useWebSocket = kIsWeb;
    if (kIsWeb) {
      _client!.websocketProtocols = MqttClientConstants.protocolsSingleDefault;
    }
    final connMess = MqttConnectMessage()
        .withClientIdentifier('river_tank_client')
        .startClean()
        .withWillQos(MqttQos.atMostOnce);
    _client!.connectionMessage = connMess;

    try {
      await _client!.connect();
      _client!.subscribe(_topic, MqttQos.atMostOnce);
      _client!.updates?.listen(_handleMessage);
    } catch (_) {
      _client?.disconnect();
      rethrow;
    } finally {
      _connecting = false;
    }
  }

  void _handleMessage(
      List<MqttReceivedMessage<MqttMessage?>>? eventList) {
    if (eventList == null || eventList.isEmpty) return;
    final message = eventList.first.payload as MqttPublishMessage;
    final payload =
        MqttPublishPayload.bytesToStringAsString(message.payload.message);
    try {
      final Map<String, dynamic> data =
          jsonDecode(payload) as Map<String, dynamic>;
      final reading = TankSensorReading(
        temperature: _toDouble(data['temperature']) ?? 0,
        humidity: _toDouble(data['humidity']) ?? 0,
        waterLevel: _toDouble(data['waterLevel']) ?? 0,
        percentFull: _calculatePercent(_toDouble(data['waterLevel'])),
        timestamp: DateTime.now(),
      );
      _controller.add(reading);
    } catch (_) {
      // silently drop malformed payloads
    }
  }

  double _calculatePercent(double? level) {
    if (level == null) return 0;
    return (level / _maxLevel).clamp(0, 1) * 100;
  }

  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  void _onDisconnected() {}

  void dispose() {
    _controller.close();
    _client?.disconnect();
  }
}
