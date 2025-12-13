import 'dart:async';

import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/station.dart';
import '../models/tank_sensor_reading.dart';
import '../services/river_api_service.dart';
import '../services/tank_mqtt_service.dart';
import '../widgets/station_selector.dart';
import '../widgets/river_level_gauge.dart';
import '../widgets/station_info_cards.dart';
import '../widgets/alert_section.dart';
import '../widgets/river_level_chart.dart';
import '../widgets/river_map_view.dart';
import '../widgets/tank_sensor_dashboard.dart';
import '../widgets/app_drawer.dart';

class RiverDashboardScreen extends StatefulWidget {
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenAccount;
  final double alertThreshold;
  final bool notificationsEnabled;
  final ValueChanged<Station>? onAlertRequested;

  const RiverDashboardScreen({
    super.key,
    required this.onOpenSettings,
    required this.onOpenAccount,
    required this.alertThreshold,
    required this.notificationsEnabled,
    this.onAlertRequested,
  });

  @override
  State<RiverDashboardScreen> createState() => _RiverDashboardScreenState();
}

class _RiverDashboardScreenState extends State<RiverDashboardScreen> {
  static const Duration _refreshInterval = Duration(seconds: 5);
  static const int _maxHistoryPoints = 60;
  final RiverApiService _apiService = RiverApiService();
  final TankMqttService _tankService = TankMqttService();

  late Station selectedStation;
  List<double> _chartData = const [];
  bool _loading = true;
  String? _error;
  Timer? _refreshTimer;
  TankSensorReading? _tankReading;
  List<double> _tankWaterHistory = const [];
  StreamSubscription<TankSensorReading>? _tankSubscription;

  @override
  void initState() {
    super.initState();
    selectedStation = stations.first;
    _setupTankStream();
    _fetchStationData();
    _refreshTimer =
        Timer.periodic(_refreshInterval, (_) => _fetchStationData());
  }

  @override
  void didUpdateWidget(covariant RiverDashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.alertThreshold != widget.alertThreshold ||
        oldWidget.notificationsEnabled != widget.notificationsEnabled) {
      _maybeTriggerAlert();
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _tankSubscription?.cancel();
    _tankService.dispose();
    super.dispose();
  }

  void _onStationChanged(Station station) {
    setState(() {
      selectedStation = station;
      _loading = !station.isTank;
      _error = null;
      _chartData = const [];
    });
    _fetchStationData();
  }

  Future<void> _fetchStationData() async {
    if (selectedStation.isTank) {
      setState(() {
        _loading = false;
        _error = null;
      });
      return;
    }
    try {
      final observation = await _apiService.fetchStation(selectedStation.id);
      if (!mounted) return;
      setState(() {
        selectedStation = selectedStation.copyWith(
          currentLevelCm: observation.levelCm,
          status: observation.status,
          parameter: observation.parameter,
          units: observation.units,
          latitude: observation.latitude,
          longitude: observation.longitude,
          updatedAt: observation.timestamp,
        );
        _chartData = observation.history;
        _loading = false;
        _error = null;
      });
      _maybeTriggerAlert();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Unable to load live data';
      });
    }
  }

  void _setupTankStream() {
    _tankSubscription =
        _tankService.readings.listen(_handleTankReading, onError: (_) {});
    _tankService.connect().catchError((_) {});
  }

  void _handleTankReading(TankSensorReading reading) {
    if (!mounted) return;
    setState(() {
      _tankReading = reading;
      _tankWaterHistory =
          _appendHistory(_tankWaterHistory, reading.waterLevel);
      if (selectedStation.isTank) {
        _loading = false;
        _error = null;
      }
    });
  }

  List<double> _appendHistory(List<double> history, double value) {
    final next = List<double>.from(history)..add(value);
    if (next.length > _maxHistoryPoints) {
      next.removeAt(0);
    }
    return next;
  }

  void _maybeTriggerAlert() {
    if (!widget.notificationsEnabled || widget.onAlertRequested == null) {
      return;
    }
    if (selectedStation.currentLevelCm >= widget.alertThreshold) {
      widget.onAlertRequested!(selectedStation);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flood Monitor for Wales River'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: widget.onOpenSettings,
          )
        ],
      ),
      drawer: AppDrawer(
        onOpenAccount: widget.onOpenAccount,
        onOpenSettings: widget.onOpenSettings,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_loading) const LinearProgressIndicator(),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  _error!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            StationSelector(
              stations: stations,
              selected: selectedStation,
              onChanged: _onStationChanged,
            ),
            const SizedBox(height: 24),
            if (selectedStation.isTank)
              TankSensorDashboard(
                reading: _tankReading,
                waterHistory: _tankWaterHistory,
                latitude: selectedStation.latitude,
                longitude: selectedStation.longitude,
                stationName: selectedStation.name,
              )
            else ...[
              _MapGaugeRow(
                map: RiverMapView(
                  latitude: selectedStation.latitude,
                  longitude: selectedStation.longitude,
                  stationName: selectedStation.name,
                ),
                gauge: RiverLevelGauge(
                  levelCm: selectedStation.currentLevelCm,
                  threshold: widget.alertThreshold,
                ),
              ),
              const SizedBox(height: 24),
              StationInfoCards(station: selectedStation),
              const SizedBox(height: 24),
              AlertSection(
                levelCm: selectedStation.currentLevelCm,
                threshold: widget.alertThreshold,
                notificationsEnabled: widget.notificationsEnabled,
              ),
              const SizedBox(height: 24),
              RiverLevelChart(data: _chartData),
            ],
          ],
        ),
      ),
    );
  }
}

class _MapGaugeRow extends StatelessWidget {
  final Widget map;
  final Widget gauge;

  const _MapGaugeRow({required this.map, required this.gauge});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 800;
        if (isNarrow) {
          return Column(
            children: [
              map,
              const SizedBox(height: 16),
              gauge,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: map),
            const SizedBox(width: 16),
            Expanded(child: gauge),
          ],
        );
      },
    );
  }
}
