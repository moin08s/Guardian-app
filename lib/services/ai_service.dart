import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AIService {
  // Replace with your Groq API key or define via --dart-define=GROQ_API_KEY=your_key
  static const String _groqApiKey = String.fromEnvironment('GROQ_API_KEY', defaultValue: "");
  static const String _groqUrl = "https://api.groq.com/openai/v1/chat/completions";

  // Exotel Credentials - Configure these or define via --dart-define
  static const String _exotelSid = String.fromEnvironment('EXOTEL_SID', defaultValue: "");
  static const String _exotelKey = String.fromEnvironment('EXOTEL_KEY', defaultValue: "");
  static const String _exotelToken = String.fromEnvironment('EXOTEL_TOKEN', defaultValue: "");

  // 1. NEW: Logic to actually make the Phone Call
  Future<void> triggerEmergencyCall(String message, String langCode) async {
    // Map internal lang codes to Exotel's voice engine codes
    String voiceCode = "en-IN";
    if (langCode == "mr") {
      voiceCode = "mr-IN";
    } else if (langCode == "hi") voiceCode = "hi-IN";

    final String basicAuth = 'Basic ${base64Encode(utf8.encode('$_exotelKey:$_exotelToken'))}';
    final Uri url = Uri.parse("https://api.exotel.com/v1/Accounts/$_exotelSid/Calls/connect.json");

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': basicAuth,
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'From': '+919373149349',
          'To': '+919373149349',
          'CallerId': '02048557941',
          'CallType': 'trans',
          'Url': "http://twimlets.com/message?Message[0]=${Uri.encodeComponent(message)}&Language=$voiceCode",
        },
      );

      if (response.statusCode == 200) {
        print("✅ SUCCESS: SOS Call Dispatched");
      } else {
        print("❌ ERROR: Exotel Response ${response.body}");
      }
    } catch (e) {
      print("❌ Connection Error: $e");
    }
  }

  // Finds help via OSM
  Future<Map<String, String>> findNearestHelp(LatLng pos) async {
    final String query = '[out:json];node["amenity"~"police|hospital"](around:5000,${pos.latitude},${pos.longitude});out;';
    final url = Uri.parse("https://overpass-api.de/api/interpreter?data=$query");

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['elements'] != null && data['elements'].isNotEmpty) {
          var tags = data['elements'][0]['tags'];
          return {
            'name': tags['name'] ?? 'Local Emergency Station',
            'phone': tags['phone'] ?? tags['contact:phone'] ?? '100',
          };
        }
      }
    } catch (e) {
      print("OSM/Overpass Error: $e");
    }
    return {'name': 'Emergency Contact', 'phone': '+91 9373149349'};
  }

  // Generates AI advice
  Future<String> getSafetyAdvice({
    required String query,
    required bool isSOSActive,
    required int battery,
    required LatLng pos,
    required Map<String, String> helpData,
    String langCode = "mr",
  }) async {
    String langInstruction = (langCode == "mr")
        ? "Respond ONLY in Marathi."
        : (langCode == "hi") ? "Respond ONLY in Hindi." : "Respond ONLY in English.";

    try {
      final response = await http.post(
        Uri.parse(_groqUrl),
        headers: {
          "Authorization": "Bearer $_groqApiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "model": "llama-3.3-70b-versatile",
          "messages": [
            {
              "role": "system",
              "content": "Abhaya AI. $langInstruction Context: SOS is ${isSOSActive ? 'ON' : 'OFF'}. Help: ${helpData['name']}."
            },
            {"role": "user", "content": query}
          ],
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['choices'][0]['message']['content'];
      }
    } catch (e) {
      print("Groq Error: $e");
    }
    return "Call ${helpData['phone']} immediately.";
  }
}