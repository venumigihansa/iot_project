import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class StationObservation {
  final double levelCm;
  final String status;
  final String parameter;
  final String units;
  final double? latitude;
  final double? longitude;
  final DateTime? timestamp;
  final List<double> history;

  StationObservation({
    required this.levelCm,
    required this.status,
    required this.parameter,
    required this.units,
    required this.history,
    this.latitude,
    this.longitude,
    this.timestamp,
  });
}

class RiverApiService {
  static const String _host = 'api.naturalresources.wales';
  static const String _path =
      '/rivers-and-seas/v1/api/StationData/historical';
  static const String _parameterId = '166';
  static const String _subscriptionKey =
      '07322214f498442589d655260b268ad4';
  static const String _corsProxy =
      'https://corsproxy.io/?';

  final http.Client _client;

  RiverApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<StationObservation> fetchStation(String stationId) async {
    final queryParameters = <String, String>{
      'location': stationId,
      'parameter': _parameterId,
      'subscription-key': _subscriptionKey,
    };
    final baseUri = Uri.https(_host, _path, queryParameters);
    final uri = kIsWeb ? Uri.parse('$_corsProxy$baseUri') : baseUri;
    final response = await _client.get(
      uri,
      headers: {
        'Ocp-Apim-Subscription-Key': _subscriptionKey,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }

    final Map<String, dynamic> json =
        jsonDecode(response.body) as Map<String, dynamic>;

    final List<dynamic> readings =
        (json['parameterReadings'] as List<dynamic>? ?? []);
    final List<double> history = readings
        .map((entry) => _toCm(entry))
        .whereType<double>()
        .toList();

    final double latestLevel =
        history.isNotEmpty ? history.last : double.nan;

    final String status =
        (json['statusEN'] ?? json['parameterStatusEN'] ?? 'Unknown')
            .toString();
    final String parameter =
        (json['paramNameEN'] ?? json['titleEN'] ?? 'River level')
            .toString();
    const String units = 'cm';

    final double? latitude = _toDouble(json['latitude']) ??
        _toDouble(json['coordinates']?['latitude']);
    final double? longitude = _toDouble(json['longitude']) ??
        _toDouble(json['coordinates']?['longitude']);

    DateTime? timestamp;
    if (readings.isNotEmpty) {
      final dynamic last = readings.last;
      final String? timeStr = last is Map ? last['time']?.toString() : null;
      if (timeStr != null) {
        timestamp = DateTime.tryParse(timeStr);
      }
    }

    return StationObservation(
      levelCm: latestLevel.isNaN ? 0 : latestLevel,
      status: status,
      parameter: parameter,
      units: units,
      latitude: latitude,
      longitude: longitude,
      timestamp: timestamp,
      history: history,
    );
  }

  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  double? _toCm(dynamic entry) {
    if (entry is Map && entry['value'] != null) {
      final double? meters = _toDouble(entry['value']);
      if (meters == null) return null;
      return double.parse((meters * 100).toStringAsFixed(2));
    }
    return null;
  }
}
