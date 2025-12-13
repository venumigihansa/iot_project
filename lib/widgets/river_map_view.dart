import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class RiverMapView extends StatelessWidget {
  final double? latitude;
  final double? longitude;
  final String? stationName;

  const RiverMapView({
    super.key,
    required this.latitude,
    required this.longitude,
    this.stationName,
  });

  @override
  Widget build(BuildContext context) {
    if (latitude == null || longitude == null) {
      return Card(
        child: SizedBox(
          height: 280,
          child: Center(
            child: Text(
              'No coordinates for this station yet.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      );
    }
    final latLng = LatLng(latitude!, longitude!);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: 280,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: latLng,
            initialZoom: 12.5,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c'],
              userAgentPackageName: 'com.example.my_app',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: latLng,
                  width: 80,
                  height: 80,
                  alignment: Alignment.topCenter,
                  child: Column(
                    children: [
                      Icon(Icons.location_pin,
                          color: Theme.of(context).colorScheme.primary,
                          size: 36),
                      if (stationName != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surface
                                .withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            stationName!,
                            style:
                                Theme.of(context).textTheme.labelSmall,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
