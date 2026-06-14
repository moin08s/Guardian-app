import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http; // ADD THIS to your pubspec.yaml
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'db_helper.dart'; // Ensure this matches your filename
import 'ai_service.dart';

class SyncService {
  final AIService _aiService = AIService();
  final DatabaseHelper _dbHelper = DatabaseHelper(); // Use the Helper we made

  // The IP of your XAMPP Laptop
  final String bridgeUrl = "http://10.165.54.208/bridge.php";

  void init() {
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (results.any((result) => result != ConnectivityResult.none)) {
        debugPrint("🌐 Network Restored! Syncing pending SOS alerts...");
        uploadPendingData();
      }
    });
  }

  Future<void> uploadPendingData() async {
    // 1. Get the list of unsynced data from SQLite
    final List<Map<String, dynamic>> pending = await _dbHelper.getUnsyncedSOS();

    if (pending.isEmpty) {
      debugPrint("✅ No pending data to sync.");
      return;
    }

    for (var sos in pending) {
      try {
        // 2. SYNC TO CLOUD (The Most Important Step)
        // We send the coordinates back to the bridge so Firebase is updated
        final response = await http.get(Uri.parse(
            "$bridgeUrl?lat=${sos['lat']}&lng=${sos['lng']}&isSOS=1&batt=100&motion=0"
        )).timeout(const Duration(seconds: 5));

        if (response.statusCode == 200 && response.body.contains("Relay_Success")) {

          // 3. GET AI ADVICE (Optional but good for UI)
          Map<String, String> testHelpData = {
            'name': 'Emergency Control',
            'phone': '+91 9373149349',
            'address': 'Simulated Police Station'
          };

          await _aiService.getSafetyAdvice(
              query: "AUTO_SYNC_RESTORED",
              isSOSActive: true,
              battery: 100,
              pos: gmaps.LatLng(sos['lat'], sos['lng']),
              helpData: testHelpData
          );

          // 4. MARK AS SYNCED in local SQLite
          await _dbHelper.markAsSynced(sos['id']);
          debugPrint("✅ SOS ID ${sos['id']} synced to Firebase via PHP.");
        }
      } catch (e) {
        debugPrint("❌ Sync failed for ID ${sos['id']}: $e");
        break; // Stop the loop if the server is still unreachable
      }
    }
  }
}