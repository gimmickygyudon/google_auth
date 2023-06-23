import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../styles/painter.dart';

class MarkerLabel extends StatelessWidget {
  const MarkerLabel({super.key, required this.latlang, required this.currentLocation});

  final Position latlang;
  final Map currentLocation;

  @override
  Widget build(BuildContext context) {
    return MarkerLayer(
      markers: [
        Marker(
          point: LatLng(latlang.latitude, latlang.longitude),
          width: 60,
          height: 60,
          builder: (context) {
            return Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.5),
                  ),
                ),
                PhysicalModel(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(50),
                  elevation: 2,
                  shadowColor: Theme.of(context).colorScheme.shadow.withOpacity(0.5),
                  child: const SizedBox(
                    width: 20,
                    height: 20,
                  ),
                ),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            );
          },
        ),
        Marker(
          rotate: true,
          width: 210,
          height: 58,
          point: LatLng(latlang.latitude, latlang.longitude),
          builder: (context) {
            return Transform.translate(
              offset: const Offset(0, -48),
              child: Column(
                children: [
                  PhysicalModel(
                    elevation: 4,
                    shadowColor: Theme.of(context).colorScheme.shadow.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(12),
                    color: Theme.of(context).colorScheme.surface,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 8, 0, 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 16,
                            child: Icon(Icons.location_on_outlined, size: 24, color: Theme.of(context).colorScheme.primary),
                          ),
                          const SizedBox(width: 6),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(currentLocation['suburb'], style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                height: 0,
                                letterSpacing: 0
                              )),
                              Text(currentLocation['subdistrict'], style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.secondary,
                                fontSize: 10,
                                letterSpacing: 0
                              )),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  CustomPaint(painter: Triangle(Theme.of(context).colorScheme.surface)),
                ],
              )
            );
          },
        )
      ],
    );
  }
}

