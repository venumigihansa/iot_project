class Station {
  final String id;
  final String name;
  final double currentLevelCm;
  final String status;
  final String parameter;
  final String units;
  final double? latitude;
  final double? longitude;
  final DateTime? updatedAt;
  final bool isTank;

  const Station({
    required this.id,
    required this.name,
    this.currentLevelCm = 0,
    this.status = 'Loading…',
    this.parameter = 'River level',
    this.units = 'cm',
    this.latitude,
    this.longitude,
    this.updatedAt,
    this.isTank = false,
  });

  Station copyWith({
    double? currentLevelCm,
    String? status,
    String? parameter,
    String? units,
    double? latitude,
    double? longitude,
    DateTime? updatedAt,
    bool? isTank,
  }) {
    return Station(
      id: id,
      name: name,
      currentLevelCm: currentLevelCm ?? this.currentLevelCm,
      status: status ?? this.status,
      parameter: parameter ?? this.parameter,
      units: units ?? this.units,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      updatedAt: updatedAt ?? this.updatedAt,
      isTank: isTank ?? this.isTank,
    );
  }
}
