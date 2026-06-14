import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../state/dashboard_provider.dart';
import '../widgets/dashboard_ui.dart';

class MapTabScreen extends StatefulWidget {
  const MapTabScreen({super.key});

  @override
  State<MapTabScreen> createState() => _MapTabScreenState();
}

class _MapTabScreenState extends State<MapTabScreen> {
  final MapController _mapController = MapController();
  DateTime _selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: safeGreenText,
            colorScheme: const ColorScheme.light(primary: safeGreenText),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<DashboardProvider>();

    return Scaffold(
      backgroundColor: bgCream,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("9:41", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
                  Text("Map · live tracking", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black45)),
                  Icon(Icons.signal_cellular_4_bar, size: 16, color: Colors.black54),
                ],
              ),
            ),

            // Map Area
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
                      ]
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: state.currentPos,
                        initialZoom: 16.0,
                        interactionOptions: const InteractionOptions(flags: InteractiveFlag.all & ~InteractiveFlag.rotate),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                          subdomains: const ['a', 'b', 'c', 'd'],
                        ),
                        // Live Tracking Path (Mock)
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: [
                                LatLng(state.currentPos.latitude - 0.005, state.currentPos.longitude - 0.005),
                                LatLng(state.currentPos.latitude - 0.002, state.currentPos.longitude - 0.001),
                                state.currentPos,
                              ],
                              color: safeGreenText.withOpacity(0.5),
                              strokeWidth: 4,
                            )
                          ],
                        ),
                        // Geofence Circle Mock
                        CircleLayer(
                          circles: [
                            CircleMarker(
                              point: state.currentPos,
                              radius: 120,
                              useRadiusInMeter: true,
                              color: safeGreenText.withOpacity(0.1),
                              borderColor: safeGreenText.withOpacity(0.3),
                              borderStrokeWidth: 2,
                            )
                          ],
                        ),
                        // Hero Marker
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: state.currentPos,
                              width: 40,
                              height: 40,
                              child: Center(
                                child: Container(
                                  width: 20, height: 20,
                                  decoration: BoxDecoration(color: safeGreenText, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3)),
                                ),
                              ),
                            )
                          ]
                        ),
                      ],
                    ),
                  ),

                  // Date Picker Control
                  Positioned(
                    top: 20, left: 20,
                    child: GestureDetector(
                      onTap: () => _selectDate(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white, 
                          borderRadius: BorderRadius.circular(20), 
                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_month, color: safeGreenText, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              _selectedDate.day == DateTime.now().day && _selectedDate.month == DateTime.now().month && _selectedDate.year == DateTime.now().year
                                ? "Today"
                                : DateFormat('dd MMM yyyy').format(_selectedDate),
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 13),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_drop_down, color: Colors.black54, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Floating Controls
                  Positioned(
                    top: 20, right: 20,
                    child: Container(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
                      child: Column(
                        children: [
                          IconButton(icon: const Icon(Icons.add, size: 20), onPressed: () {
                            _mapController.move(state.currentPos, _mapController.camera.zoom + 1);
                          }),
                          Container(height: 1, width: 30, color: Colors.grey.shade200),
                          IconButton(icon: const Icon(Icons.remove, size: 20), onPressed: () {
                            _mapController.move(state.currentPos, _mapController.camera.zoom - 1);
                          }),
                        ],
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: 20, right: 30,
                    child: Container(
                      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
                      child: IconButton(
                        icon: const Icon(Icons.my_location, color: safeGreenText),
                        onPressed: () {
                          _mapController.move(state.currentPos, 16.0);
                        },
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Info Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(flex: 2, child: _buildInfoCard("LOCATION", "${state.currentPos.latitude.toStringAsFixed(4)}°N\n${state.currentPos.longitude.toStringAsFixed(4)}°E", Colors.black87)),
                  const SizedBox(width: 8),
                  Expanded(flex: 2, child: _buildInfoCard("ACCURACY", "± 4 m", safeGreenText, highlightScale: true)),
                  const SizedBox(width: 8),
                  Expanded(flex: 2, child: _buildInfoCard("UPLINK", "Every\n10 min", Colors.black87)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Share Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: safeGreenBg,
                    foregroundColor: safeGreenText,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  icon: const Icon(Icons.share),
                  label: const Text("Share live location", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, Color valueColor, {bool highlightScale = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: valueColor == safeGreenText ? safeGreenBg : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: valueColor == safeGreenText ? safeGreenText.withOpacity(0.3) : Colors.grey.shade300)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black45, letterSpacing: 1.0)),
          const SizedBox(height: 5),
          Text(
            value, 
            textAlign: TextAlign.center,
            style: TextStyle(
              color: valueColor, 
              fontSize: highlightScale ? 18 : 13, 
              fontWeight: FontWeight.bold,
              height: 1.3
            )
          ),
        ],
      ),
    );
  }
}
