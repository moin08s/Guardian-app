import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import '../state/dashboard_provider.dart';

class CustomMap extends StatelessWidget {
  final GlobalKey mapKey;
  final MapController mapController;
  final AnimationController pulseController;
  final bool showManualTrack;
  final List firebaseZones;
  final bool Function() isParentNear;
  final VoidCallback triggerRemoteBuzzer;
  final VoidCallback shutdownIoTDevice;
  final Widget Function() buildHistoryLayer;
  final Widget Function() buildSOSMarker;

  const CustomMap({
    super.key,
    required this.mapKey,
    required this.mapController,
    required this.pulseController,
    required this.showManualTrack,
    required this.firebaseZones,
    required this.isParentNear,
    required this.triggerRemoteBuzzer,
    required this.shutdownIoTDevice,
    required this.buildHistoryLayer,
    required this.buildSOSMarker,
  });

  @override
  Widget build(BuildContext context) {
    // Connect Map UI to our newly extracted State Class
    final state = context.watch<DashboardProvider>();

    return RepaintBoundary(
      key: mapKey,
      child: FlutterMap(
        mapController: mapController,
        options: MapOptions(initialCenter: state.currentPos, initialZoom: 15.0),
        children: [
          if (state.isSOSActive && isParentNear())
            Positioned(
              bottom: 150,
              left: 20,
              child: FloatingActionButton.extended(
                heroTag: "siren_btn",
                backgroundColor: Colors.orangeAccent,
                onPressed: triggerRemoteBuzzer,
                icon: const Icon(Icons.volume_up, color: Colors.white),
                label: const Text("TRIGGER SIREN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          if (kDebugMode)
            Positioned(
              top: 130, // Placed below Live/History toggle
              right: 20,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: Colors.redAccent,
                heroTag: "debug_off_btn",
                onPressed: shutdownIoTDevice,
                child: const Icon(Icons.power_settings_new, color: Colors.white),
              ),
            ),
          CircleLayer(
            circles: firebaseZones.map((z) => CircleMarker(
              point: z.center,
              radius: z.radius,
              useRadiusInMeter: true,
              color: Colors.green.withOpacity(0.2),
              borderColor: Colors.green,
              borderStrokeWidth: 2,
            )).toList(),
          ),
          TileLayer(urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png'),
          // Live Marker (Only in Live Mode)
          if (!showManualTrack)
            MarkerLayer(markers: [
              Marker(point: state.currentPos, width: 80, height: 80, child: buildSOSMarker())
            ]),
          // Time-Coded History (Only in History Mode)
          if (showManualTrack) buildHistoryLayer(),
        ],
      ),
    );
  }
}
