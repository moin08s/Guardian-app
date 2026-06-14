import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/biometrics.dart';
import '../services/audio_service.dart';

class DashboardProvider extends ChangeNotifier {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  final String hardwareID = "UNIT_001";
  final AudioService _audioService = AudioService();

  // --- Map and IoT State (previously ported from main.dart) ---
  LatLng _currentPos = const LatLng(18.5204, 73.8567);
  final LatLng _userLocation = const LatLng(28.6139, 77.2090); // Default parent location
  bool _isIoTOnline = false;
  int _lastBattery = 100;
  final List<int> _batteryHistory = [100, 95, 90, 85, 82, 75, 70];

  // --- Biometric Data ---
  Biometrics _biometrics = Biometrics.empty();
  
  // --- SOS State ---
  bool _isSOSActive = false;
  String _sosReason = "";

  // Getters
  LatLng get currentPos => _currentPos;
  LatLng get userLocation => _userLocation;
  bool get isIoTOnline => _isIoTOnline;
  int get lastBattery => _lastBattery;
  List<int> get batteryHistory => _batteryHistory;
  
  double get stressLevel => _biometrics.stressLevel;
  int get heartRate => _biometrics.heartRate;
  int get spo2 => _biometrics.spo2;
  double get calmIndex => 100.0 - stressLevel;
  bool get isStrapAttached => _biometrics.isStrapAttached;
  bool get isI2CConnected => _biometrics.isI2CConnected;
  bool get isSOSActive => _isSOSActive;
  String get sosReason => _sosReason;

  DashboardProvider() {
    _listenToIOTUpdates();
  }

  void _listenToIOTUpdates() {
    _db.child('handshake').child(hardwareID).onValue.listen((event) {
      if (event.snapshot.value != null) {
        final data = Map<dynamic, dynamic>.from(event.snapshot.value as Map);

        int lastSeen = int.tryParse(data['timestamp'].toString()) ?? 0;
        int now = DateTime.now().millisecondsSinceEpoch;
        bool isStale = (now - lastSeen) > 300000;

        _isIoTOnline = !isStale;
        
        // Safety checks for LatLng parsing
        if (data.containsKey('lat') && data.containsKey('lng')) {
           _currentPos = LatLng(
              double.tryParse(data['lat'].toString()) ?? _currentPos.latitude,
              double.tryParse(data['lng'].toString()) ?? _currentPos.longitude
          );
        }
        
        _lastBattery = int.tryParse(data['batt'].toString()) ?? _lastBattery;

        // Parse biometrics if available from IoT
        final newBiometrics = Biometrics.fromRealtimeDatabase(data);
        updateBiometrics(newBiometrics);

        // Map existing SOS status if external hardware button was triggered
        if (data['isSOS'].toString() == "1" && !_isSOSActive) {
           triggerSOS("HARDWARE_BUTTON");
        } else if (data['isSOS'].toString() == "0" && _isSOSActive) {
           _isSOSActive = false; // System disabled SOS externally
           notifyListeners();
        }
      }
    });
  }

  // Update logic called from your IoT Service
  void updateBiometrics(Biometrics newData) {
    // 🔥 EMERGENCY: Forceful Removal Detection
    if (_biometrics.isStrapAttached && !newData.isStrapAttached) {
      triggerSOS("STRAP_REMOVED_BY_FORCE");
    }
    
    // 🔥 EMERGENCY: I2C Sensor Strap Disconnected
    if (_biometrics.isI2CConnected && !newData.isI2CConnected) {
      triggerSOS("SENSOR_HUB_DISCONNECTED_CRITICAL");
    }
    
    _biometrics = newData;
    notifyListeners(); // Updates the UI instantly
  }

  void triggerSOS(String reason) {
    if (_isSOSActive) return; // Already active

    _isSOSActive = true;
    _sosReason = reason;

    // Start audio black box via the dedicated service
    _audioService.startEmergencyRecording();

    notifyListeners();
  }

  void clearSOS() {
    if (!_isSOSActive) return;
    _isSOSActive = false;
    _sosReason = "";
    notifyListeners();
  }
}
