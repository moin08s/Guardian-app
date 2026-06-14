import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'services/ai_service.dart';
import 'services/db_helper.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

// Architecture Refactoring Imports
import 'package:provider/provider.dart';
import 'state/dashboard_provider.dart';
import 'widgets/custom_map.dart';
import 'screens/onboarding_screens.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
      ],
      child: const MaterialApp(home: OnboardingWelcomeScreen(), debugShowCheckedModeBanner: false),
    ),
  );
}

class SOSMapScreen extends StatefulWidget {
  const SOSMapScreen({super.key});
  @override
  State<SOSMapScreen> createState() => _SOSMapScreenState();
}

class SafetyZone {
  final String id;
  final String name;
  final LatLng center;
  final double radius;
  SafetyZone({required this.id, required this.name, required this.center, required this.radius});
}
class _SOSMapScreenState extends State<SOSMapScreen> with SingleTickerProviderStateMixin {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  final MapController _mapController = MapController();
  late AnimationController _pulseController;
  final AIService _aiService = AIService();
  final SpeechToText _speechToText = SpeechToText();
  final GlobalKey _mapKey = GlobalKey();
  List<SafetyZone> _firebaseZones = [];

  // --- APP STATE ---
  LatLng _currentPos = const LatLng(18.5204, 73.8567);
  final LatLng _userLocation = const LatLng(28.6139, 77.2090); // Default (Delhi)
  bool _isSOSActive = false;
  bool _isIoTOnline = false;
  bool _showManualTrack = false;
  bool _isLinked = false;
  bool _isWaitingForHardware = false;
  bool _isAILoading = false;
  bool _hasPendingSync = false;
  int _lastBattery = 100;
  final String _hardwareID = "UNIT_001";
  String _statusText = "On the move";

  // --- DATA LISTS ---
  final List<int> _batteryHistory = [100, 95, 90, 85, 82, 75, 70];
  DateTime _selectedDate = DateTime.now();

  bool _isParentNear() {
    const Distance distance = Distance();
    // Calculate distance between Parent's Phone and IoT Device
    double meterDist = distance.as(
        LengthUnit.Meter,
        _currentPos, // IoT Device Position
        _userLocation // Parent's Phone Position (Make sure you have this variable)
    );
    return meterDist < 100; // Returns true if within 100 meters
  }

  Future<void> _shutdownIoTDevice() async {
    // 1. Send the SHUTDOWN command to the hardware
    await _db.child('commands').child(_hardwareID).set({
      'type': 'POWER_OFF',
      'timestamp': ServerValue.timestamp,
    });

    // 2. Update the local UI to show it's shutting down
    setState(() {
      _isIoTOnline = false;
      _statusText = "Device Shutting Down...";
    });

    // 3. Reset the command after a few seconds so it doesn't loop
    Future.delayed(const Duration(seconds: 5), () {
      _db.child('commands').child(_hardwareID).remove();
    });
  }

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
    _checkInitialLinkStatus();
    _listenToIOTUpdates();
    _monitorConnectivity();
  }
  void _handlePhoneCall(String phoneNumber) async {
    // Clean the phone number (remove spaces/dashes) for the dialer
    final String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    final Uri telUri = Uri(scheme: 'tel', path: cleanNumber);

    if (kDebugMode) {
      // 1. SIMULATION MODE (For Hackathon Demos)
      _showSimulationPopup(phoneNumber);
    } else {
      // 2. PRODUCTION MODE (Actual Calling Logic)
      try {
        if (await canLaunchUrl(telUri)) {
          await launchUrl(telUri);
        } else {
          _showErrorSnackBar("Dialer not available on this device.");
        }
      } catch (e) {
        _showErrorSnackBar("Could not initiate call: $e");
      }
    }
  }

// Helper for the Simulation Popup
  void _showSimulationPopup(String number) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.blueGrey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Row(
          children: [
            Icon(Icons.bug_report, color: Colors.orangeAccent),
            SizedBox(width: 10),
            Text("Demo Simulation", style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Text(
          "DIALING: $number\n\nNote: In the final version, this button opens the phone dialer. Real calls are disabled during the demo.",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("OK", style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

// Helper for error messages
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }
  void _showAIResponse(String text, String stationName, String phoneNumber) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.security, color: Colors.redAccent, size: 30),
            ),
            const SizedBox(height: 12),
            const Text(
              "Guardian AI Analysis",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // AI Suggestion Box
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Text(
                  text,
                  style: TextStyle(color: Colors.blueGrey[900], fontSize: 15, height: 1.5),
                ),
              ),
              const SizedBox(height: 20),
              // Location Badge
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, size: 18, color: Colors.blueAccent),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "NEAREST: $stationName",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.blueAccent
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          Column(
            children: [
              // The Primary Action Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _handlePhoneCall(phoneNumber);
                  },
                  icon: const Icon(Icons.phone_forwarded),
                  label: const Text("DIAL EMERGENCY STATION", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("DISMISS ADVICE", style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- 1. HANDSHAKE LOGIC ---
  void _checkInitialLinkStatus() {
    _db.child('handshake').child(_hardwareID).onValue.listen((e) {
      if (mounted) {
        final data = e.snapshot.value as Map?;
        setState(() {
          // Change 'COMPLETE' to 'CONNECTED' to match your PHP/Firebase
          _isLinked = data != null && data['status'] == 'CONNECTED';
          if (_isLinked) _isWaitingForHardware = false;
        });
      }
    });
  }

  void _performCloudLink() async {
    setState(() => _isWaitingForHardware = true);
    await _db.child('handshake').child(_hardwareID).set({
      'app_request': true,
      'status': 'PENDING',
      'timestamp': ServerValue.timestamp,
    });
    // Timeout if hardware doesn't respond
    Future.delayed(const Duration(seconds: 20), () {
      if (mounted && !_isLinked) {
        setState(() => _isWaitingForHardware = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Hardware not responding. Check IoT connectivity.")),
        );
      }
    });
  }

  void _updateStatusText(LatLng pos) {
    const Distance distance = Distance();
    bool inZone = false;

    for (var zone in _firebaseZones) {
      if (distance.as(LengthUnit.Meter, pos, zone.center) <= zone.radius) {
        setState(() => _statusText = "At ${zone.name}");
        inZone = true;
        break;
      }
    }

    if (!inZone) {
      setState(() => _statusText = _isSOSActive ? "Emergency Active" : "On the move");
    }
  }
  void _selectHistoryDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
  void _showAISheet(BuildContext context) {
    final TextEditingController chatController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 25, right: 25, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("GUARDIAN LOCAL AI", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
            const SizedBox(height: 15),
            TextField(
              controller: chatController,
              decoration: InputDecoration(
                  hintText: "What is your emergency?",
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 15)),
                onPressed: () async {
                  final q = chatController.text;
                  if (q.isEmpty) return;

                  Navigator.pop(ctx); // Close the input sheet
                  setState(() => _isAILoading = true);

                  try {
                    // Wrap _currentPos in the gmaps.LatLng constructor
                    final helpData = await _aiService.findNearestHelp(
                        gmaps.LatLng(_currentPos.latitude, _currentPos.longitude)
                    );

                    // 2. SECOND: Get AI advice using that real help data
                    final advice = await _aiService.getSafetyAdvice(
                      query: q,
                      isSOSActive: _isSOSActive,
                      battery: _lastBattery,
                      pos: gmaps.LatLng(_currentPos.latitude, _currentPos.longitude),
                      helpData: helpData, // Passing the station info to the AI
                    );

                    // 3. THIRD: Show the response with the real station name and phone
                    _showAIResponse(
                        advice,                    // The text response from AI
                        helpData['name'] ?? "Local Station", // The Station Name
                        helpData['phone'] ?? "100" // The Phone Number
                    );
                  } catch (e) {
                    debugPrint("AI Error: $e");
                  } finally {
                    setState(() => _isAILoading = false);
                  }
                },
                child: const Text("ANALYZE SITUATION", style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
  void _addNewGeofenceDialog() {
    TextEditingController nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Set New Green Zone"),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(hintText: "Zone Name (e.g., Home)"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              _db.child('geofences').child(_hardwareID).push().set({
                'name': nameController.text,
                'lat': _currentPos.latitude,
                'lng': _currentPos.longitude,
                'radius': 150.0, // Default 150 meters
              });
              Navigator.pop(context);
            },
            child: const Text("Save Zone"),
          )
        ],
      ),
    );
  }

  void _bypassHandshake() {
    setState(() {
      _isLinked = true;
      _isWaitingForHardware = false;
      _statusText = "Testing Mode (Bypass)";
    });
  }

  // --- 2. UNLINK DEVICE FUNCTION ---
  Future<void> _unlinkDevice() async {
    await _db.child('handshake').child(_hardwareID).set({'status': 'RESET'});
    setState(() {
      _isLinked = false;
      _isSOSActive = false;
    });
  }

  // --- 3. BATTERY ANALYSIS & GRAPH ---
  void _showBatteryAnalysis() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Battery Consumption History", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            SizedBox(
              height: 120,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: _batteryHistory.map((val) => Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text("$val%", style: const TextStyle(fontSize: 10)),
                    Container(width: 25, height: val.toDouble(), decoration: BoxDecoration(color: val > 20 ? Colors.green : Colors.red, borderRadius: BorderRadius.circular(4))),
                  ],
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 4. CONNECTIVITY & IOT UPDATES ---
  void _monitorConnectivity() {
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) async {
      // 1. Correctly define and await the 'waiting' variable
      bool waiting = await DatabaseHelper().hasPendingData();

      if (mounted) {
        setState(() {
          // 2. If results contains 'none', internet is down OR we have unsynced data
          _hasPendingSync = results.contains(ConnectivityResult.none) || waiting;
        });
      }
    });
  }

  void _listenToGeofences() {
    _db.child('geofences').child(_hardwareID).onValue.listen((event) {
      final List<SafetyZone> loadedZones = [];
      if (event.snapshot.value != null) {
        final data = Map<dynamic, dynamic>.from(event.snapshot.value as Map);
        data.forEach((key, value) {
          loadedZones.add(SafetyZone(
            id: key,
            name: value['name'],
            center: LatLng(value['lat'], value['lng']),
            radius: (value['radius'] as num).toDouble(),
          ));
        });
      }
      setState(() => _firebaseZones = loadedZones);
      _updateStatusText(_currentPos); // Check if we are inside a zone now
    });
  }

  void _triggerRemoteBuzzer() {
    _db.child('commands').child(_hardwareID).set({
      'type': 'BUZZER_ON',
      'timestamp': ServerValue.timestamp,
    });

    // Automatically turn it off after 3 seconds so it doesn't stay stuck
    Future.delayed(const Duration(seconds: 3), () {
      _db.child('commands').child(_hardwareID).remove();
    });
  }

  void _listenToIOTUpdates() {
    _db.child('handshake').child(_hardwareID).onValue.listen((event) {
      if (event.snapshot.value != null) {
        final data = Map<dynamic, dynamic>.from(event.snapshot.value as Map);

        // Calculate data freshness
        int lastSeen = int.tryParse(data['timestamp'].toString()) ?? 0;
        int now = DateTime.now().millisecondsSinceEpoch;
        bool isStale = (now - lastSeen) > 300000; // 5 minutes

        setState(() {
          _isIoTOnline = !isStale;
          _currentPos = LatLng(
              double.tryParse(data['lat'].toString()) ?? 0.0,
              double.tryParse(data['lng'].toString()) ?? 0.0
          );
          _isSOSActive = data['isSOS'].toString() == "1";
          _lastBattery = int.tryParse(data['batt'].toString()) ?? 100;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 1. Handshake Gate: Keeps unauthorized users out
    if (!_isLinked) return _buildHandshakeUI();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  _isSOSActive ? "⚠️ EMERGENCY" : (_showManualTrack ? "History: ${DateFormat('dd MMM').format(_selectedDate)}" : "Guardian Live"),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)
              ),
              // Shows "Device Online" or "Device Offline" based on Heartbeat
              Text(
                  _isIoTOnline ? "Device Online" : "Device Offline",
                  style: const TextStyle(color: Colors.white70, fontSize: 12)
              ),
            ]
        ),
        backgroundColor: _isSOSActive ? Colors.red.shade900 : Colors.redAccent.withOpacity(0.8),
        // Uses the new modular actions (Cloud Icon + Settings)
        actions: _buildAppBarActions(),
      ),
      body: Stack(
        children: [
          // 2. The Map Layer (Extracted into reusable custom_map.dart)
          CustomMap(
            mapKey: _mapKey,
            mapController: _mapController,
            pulseController: _pulseController,
            showManualTrack: _showManualTrack,
            firebaseZones: _firebaseZones,
            isParentNear: _isParentNear,
            triggerRemoteBuzzer: _triggerRemoteBuzzer,
            shutdownIoTDevice: _shutdownIoTDevice,
            buildHistoryLayer: () => _buildHistoryLayer(),
            buildSOSMarker: () => _buildSOSMarker(),
          ),

          // 3. UI Overlays
          _buildTopToggle(), // Live vs History Switcher

          // Action Buttons (AI Button + Calendar)
          Positioned(
              bottom: 30,
              right: 20,
              child: _buildActionButtons()
          ),

          // New Modular Battery/Offline Indicator
          Positioned(
              bottom: 35,
              left: 20,
              child: _buildBatteryIndicator()
          ),

          // Loading Spinner for AI Processing
          if (_isAILoading)
            const Center(child: CircularProgressIndicator(color: Colors.redAccent)),
        ],
      ),
    );
  }


  // --- UI HELPERS ---
  Widget _buildHandshakeUI() {
    return Scaffold(
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          _isWaitingForHardware
              ? const CircularProgressIndicator(color: Colors.redAccent)
              : const Icon(Icons.security, size: 100, color: Colors.redAccent),
          const SizedBox(height: 30),
          Text(_isWaitingForHardware ? "Connecting..." : "Device Not Linked", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: _performCloudLink, child: const Text("INITIALIZE LINK")),
          TextButton(onPressed: _bypassHandshake, child: const Text("Debug: Bypass (Demo Only)")),
        ]),
      ),
    );
  }

  void _showSettingsMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          const Text("System Controls", style: TextStyle(fontWeight: FontWeight.bold)),
          const Divider(),
          // THE NEW POWER OFF BUTTON
          ListTile(
            leading: const Icon(Icons.power_settings_new, color: Colors.red),
            title: const Text("Turn Off IoT Device", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            subtitle: const Text("This will put the T-Call into Deep Sleep"),
            onTap: () {
              Navigator.pop(ctx);
              _confirmShutdown(); // Call a confirmation dialog
            },
          ),
          ListTile(
            leading: const Icon(Icons.link_off),
            title: const Text("Unlink Device"),
            onTap: () {
              _db.child('handshake').child(_hardwareID).set({'status': 'RESET'});
              setState(() => _isLinked = false);
              Navigator.pop(ctx);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _confirmShutdown() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm Shutdown"),
        content: const Text("Are you sure? You will need to press the physical button on the T-Call to wake it up again."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              _shutdownIoTDevice();
              Navigator.pop(ctx);
            },
            child: const Text("Power Off"),
          )
        ],
      ),
    );
  }

  Widget _buildTimeBasedHistory() {
    return StreamBuilder<DatabaseEvent>(
      stream: _db.child('history').child(_hardwareID).onValue,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.snapshot.value == null) return const SizedBox();
        final data = Map<dynamic, dynamic>.from(snapshot.data!.snapshot.value as Map);
        List<Polyline> segments = [];
        data.forEach((key, val) {
          DateTime time = DateTime.fromMillisecondsSinceEpoch(val['timestamp']);
          if (DateFormat('yyyyMMdd').format(time) == DateFormat('yyyyMMdd').format(_selectedDate)) {
            Color c = Colors.blue;
            if (time.hour >= 5 && time.hour < 12) c = Colors.orange;
            if (time.hour >= 12 && time.hour < 17) c = Colors.blue;
            if (time.hour >= 17 || time.hour < 5) c = Colors.purple;
            segments.add(Polyline(points: [LatLng(val['lat'], val['lng']), LatLng(val['lat'] + 0.0001, val['lng'] + 0.0001)], strokeWidth: 6, color: c));
          }
        });
        return PolylineLayer(polylines: segments);
      },
    );
  }



  Widget _buildTopToggle() => Positioned(top: 110, left: 60, right: 60, child: Container(height: 45, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), boxShadow: [const BoxShadow(color: Colors.black26, blurRadius: 10)]), child: Row(children: [
    Expanded(child: _toggleBtn("LIVE", !_showManualTrack, () => setState(() => _showManualTrack = false))),
    Expanded(child: _toggleBtn("HISTORY", _showManualTrack, () => setState(() => _showManualTrack = true))),
  ])));

  Widget _toggleBtn(String label, bool active, VoidCallback tap) => GestureDetector(onTap: tap, child: Container(decoration: BoxDecoration(color: active ? Colors.blue : Colors.transparent, borderRadius: BorderRadius.circular(25)), alignment: Alignment.center, child: Text(label, style: TextStyle(color: active ? Colors.white : Colors.black54, fontWeight: FontWeight.bold))));
  Widget _buildBatteryIndicator() {
    return GestureDetector(
      onTap: _isIoTOnline ? _showBatteryAnalysis : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 5)],
        ),
        child: _isIoTOnline
            ? Row(
          children: [
            Icon(Icons.battery_4_bar, color: _lastBattery > 20 ? Colors.green : Colors.red, size: 20),
            const SizedBox(width: 5),
            Text("$_lastBattery%", style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        )
            : const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
            SizedBox(width: 5),
            Text("DEVICE OFFLINE", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryLayer() {
    return StreamBuilder<DatabaseEvent>(
      stream: _db.child('history').child(_hardwareID).onValue,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.snapshot.value == null) return const SizedBox();

        final data = Map<dynamic, dynamic>.from(snapshot.data!.snapshot.value as Map);
        List<Polyline> coloredSegments = [];

        data.forEach((key, val) {
          DateTime time = DateTime.fromMillisecondsSinceEpoch(val['timestamp']);

          // Only show data for the selected date
          if (DateFormat('yyyyMMdd').format(time) == DateFormat('yyyyMMdd').format(_selectedDate)) {

            // Color Logic: Morning (Orange), Afternoon (Blue), Night (Purple)
            Color pathColor = Colors.blue;
            if (time.hour >= 5 && time.hour < 12) pathColor = Colors.orange;
            if (time.hour >= 12 && time.hour < 17) pathColor = Colors.blue;
            if (time.hour >= 17 || time.hour < 5) pathColor = Colors.purple;

            coloredSegments.add(
              Polyline(
                points: [
                  LatLng(val['lat'], val['lng']),
                  LatLng(val['lat'] + 0.0001, val['lng'] + 0.0001)
                ],
                strokeWidth: 6,
                color: pathColor,
              ),
            );
          }
        });
        return PolylineLayer(polylines: coloredSegments);
      },
    );
  }
  Widget _buildSOSMarker() => ScaleTransition(scale: Tween(begin: 1.0, end: 1.2).animate(_pulseController), child: const Icon(Icons.location_on, color: Colors.red, size: 50));
  Widget _buildActionButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // NEW: Add Geofence Button (Only in Live Mode)
        if (!_showManualTrack)
          FloatingActionButton.small(
            heroTag: "addZ",
            onPressed: _addNewGeofenceDialog,
            backgroundColor: Colors.green,
            child: const Icon(Icons.add_location_alt, color: Colors.white),
          ),
        if (_showManualTrack)
          FloatingActionButton.small(
              heroTag: "cal",
              onPressed: _selectHistoryDate,
              backgroundColor: Colors.blue,
              child: const Icon(Icons.calendar_month, color: Colors.white)
          ),
        const SizedBox(height: 12),
        FloatingActionButton.extended(
          onPressed: () => _showAISheet(context),
          label: const Text("Safety AI"),
          icon: const Icon(Icons.auto_awesome),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
      ],
    );
  }
  List<Widget> _buildAppBarActions() {
    return [
      Padding(
        padding: const EdgeInsets.only(right: 15),
        child: Icon(
          _isIoTOnline ? Icons.cloud_done : Icons.cloud_off,
          color: _isIoTOnline ? Colors.greenAccent : Colors.orangeAccent,
        ),
      ),
      IconButton(
        icon: const Icon(Icons.settings, color: Colors.white),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (ctx) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.link_off, color: Colors.red),
                  title: const Text("Unlink IoT Device"),
                  onTap: () {
                    _db.child('handshake').child(_hardwareID).set({'status': 'RESET'});
                    setState(() => _isLinked = false);
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          );
        },
      ),
    ];
  }
}