import 'package:record/record.dart';

class AudioService {
  final _record = AudioRecorder();

  Future<void> startEmergencyRecording() async {
    if (await _record.hasPermission()) {
      // Use high-quality AAC for industrial evidence
      await _record.start(const RecordConfig(), path: 'emergency_clip.m4a');
      print("🚨 Recording started: Black Box Active");
    }
  }

  Future<String?> stopAndUpload() async {
    return await _record.stop();
    // Logic to upload to your server goes here
  }
}
