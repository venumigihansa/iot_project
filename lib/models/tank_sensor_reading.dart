class TankSensorReading {
  final double temperature;
  final double humidity;
  final double waterLevel;
  final double percentFull;
  final DateTime timestamp;

  const TankSensorReading({
    required this.temperature,
    required this.humidity,
    required this.waterLevel,
    required this.percentFull,
    required this.timestamp,
  });
}
