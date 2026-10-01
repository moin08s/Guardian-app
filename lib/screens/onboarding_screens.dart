import 'package:flutter/material.dart';
import '../widgets/dashboard_ui.dart';
import 'main_wrapper_screen.dart';

const Color obDarkGreen = Color(0xFF0F5A48);
const Color obLightGreen = Color(0xFFE5F5F1);

class OnboardingWelcomeScreen extends StatefulWidget {
  const OnboardingWelcomeScreen({super.key});

  @override
  State<OnboardingWelcomeScreen> createState() => _OnboardingWelcomeScreenState();
}

class _OnboardingWelcomeScreenState extends State<OnboardingWelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _nextPage() {
    if (_currentPage < 4) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainWrapperScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgCream,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar for Page > 0
            if (_currentPage > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("9:41", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
                    Text("Step $_currentPage of 4", style: const TextStyle(fontWeight: FontWeight.bold, color: obDarkGreen)),
                  ],
                ),
              )
            else
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("9:41", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
                    Icon(Icons.signal_cellular_4_bar, size: 16, color: Colors.black54)
                  ],
                ),
              ),

            // Progress Bar
            if (_currentPage > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: List.generate(4, (index) {
                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        height: 4,
                        decoration: BoxDecoration(
                          color: index < _currentPage ? obDarkGreen : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                ),
              ),

            // Page Content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // Disable swipe to force button clicks
                onPageChanged: (idx) {
                  setState(() {
                    _currentPage = idx;
                  });
                },
                children: [
                  _buildWelcomePage(),
                  _buildDevicePairingPage(),
                  _buildFamilyNetworkPage(),
                  _buildSafeZonesPage(),
                  _buildCalibrateSensorsPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- PAGE 1: WELCOME ---
  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(color: obLightGreen, borderRadius: BorderRadius.circular(20), border: Border.all(color: obDarkGreen, width: 2)),
            child: const Icon(Icons.shield_outlined, color: obDarkGreen, size: 40),
          ),
          const SizedBox(height: 30),
          const Text("Abhaya", style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, fontFamily: 'serif')),
          const SizedBox(height: 10),
          const Text("Proactive safety for the people\nyou love most", textAlign: TextAlign.center, style: TextStyle(color: Colors.black54, fontSize: 16)),
          const Spacer(),
          
          _buildFeatureCard(Icons.monitor_heart, "Live biometric monitoring", "HR, stress, SpO2", obLightGreen, safeGreenText),
          const SizedBox(height: 15),
          _buildFeatureCard(Icons.location_on, "Safe zone geofencing", "Custom alerts when leaving home", Colors.blue.shade50, Colors.blue.shade700),
          const SizedBox(height: 15),
          _buildFeatureCard(Icons.star, "AI-powered threat analysis", "Local LLaMA 3.3 standalone", Colors.orange.shade50, Colors.orange.shade700),
          
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: obDarkGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
              onPressed: _nextPage,
              child: const Text("Get started", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 20),
          const Text.rich(TextSpan(text: "Already setup? ", style: TextStyle(color: Colors.black54), children: [TextSpan(text: "Sign in", style: TextStyle(color: obDarkGreen, fontWeight: FontWeight.bold))])),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, String sub, Color backgroundColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey.shade900)),
                Text(sub, style: TextStyle(fontSize: 12, color: Colors.blueGrey.shade600)),
              ],
            ),
          )
        ],
      ),
    );
  }

  // --- PAGE 2: DEVICE PAIRING ---
  Widget _buildDevicePairingPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Link your device", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'serif')),
          const SizedBox(height: 10),
          const Text("Pair the Abhaya Hub & Strap via\nNearby Share", style: TextStyle(color: Colors.black54, fontSize: 15)),
          const SizedBox(height: 30),
          
          // Radar Animation Mockup
          Center(
            child: Container(
              width: 200, height: 200,
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: obLightGreen, width: 2)),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(width: 140, height: 140, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: obLightGreen, width: 4))),
                  Container(width: 80, height: 80, decoration: const BoxDecoration(shape: BoxShape.circle, color: obLightGreen)),
                  const Text("HUB", style: TextStyle(fontWeight: FontWeight.bold, color: obDarkGreen)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Center(child: Text("Scanning nearby...", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87))),
          const Center(child: Text("Keep your devices close to the phone", style: TextStyle(fontSize: 12, color: Colors.black54))),
          const SizedBox(height: 30),

          const Text("DEVICES FOUND (2)", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black45, letterSpacing: 1.5)),
          const SizedBox(height: 10),
          
          // Found Devices List
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade200)),
            child: Column(
              children: [
                _buildDeviceRow("Abhaya Hub - ESP32-S3", "UNIT_001", "Signal strong", obLightGreen, obDarkGreen, "Pair", obDarkGreen, Colors.white),
                Divider(color: Colors.grey.shade100, height: 1),
                _buildDeviceRow("Abhaya Strap - nRF52840", "BLE 5.0 STRAP_001", "", Colors.blue.shade50, Colors.blue, "Pair", Colors.blue.shade50, Colors.blue),
              ],
            ),
          ),
          const SizedBox(height: 30),
          
          Center(child: Text("Device not showing? Enter ID manually", style: TextStyle(fontSize: 13, color: obDarkGreen, fontWeight: FontWeight.bold))),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity, height: 50,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.grey), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
              onPressed: _nextPage,
              child: const Text("Skip for now", style: TextStyle(color: Colors.black54)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDeviceRow(String title, String sub1, String sub2, Color iconBg, Color iconColor, String btnText, Color btnBg, Color btnTextCol) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.router, color: iconColor)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Row(
                  children: [
                    Text(sub1, style: const TextStyle(fontSize: 11, color: Colors.blueAccent)),
                    if (sub2.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Text("·", style: TextStyle(color: Colors.black54)),
                      const SizedBox(width: 8),
                      Text(sub2, style: const TextStyle(fontSize: 11, color: obDarkGreen)),
                    ]
                  ],
                )
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: btnBg, foregroundColor: btnTextCol, elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 16), minimumSize: const Size(60, 32)),
            onPressed: () {},
            child: Text(btnText),
          )
        ],
      ),
    );
  }

  // --- PAGE 3: FAMILY NETWORK ---
  Widget _buildFamilyNetworkPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Family network", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'serif')),
          const SizedBox(height: 10),
          const Text("Who gets alerted when you need help?", style: TextStyle(color: Colors.black54, fontSize: 15)),
          const SizedBox(height: 30),
          
          const Text("EMERGENCY CONTACTS", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black45, letterSpacing: 1.5)),
          const SizedBox(height: 15),

          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade200)),
            child: Column(
              children: [
                _buildContactItem("M", "Mom", "+91 ••••• ••210", Colors.teal, true),
                const SizedBox(height: 15),
                _buildContactItem("R", "Rahul (Brother)", "+91 ••••• ••211", Colors.blue, false),
                const SizedBox(height: 20),
                
                // Add contact form area
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(color: bgCream, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid)),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: _buildTextField("NAME", "e.g. Dad")),
                          const SizedBox(width: 10),
                          Expanded(flex: 2, child: _buildTextField("PHONE NUMBER", "+91")),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          _buildTag("Family", true),
                          const SizedBox(width: 5),
                          _buildTag("Sibling", false),
                          const SizedBox(width: 5),
                          _buildTag("Partner", false),
                          const SizedBox(width: 5),
                          _buildTag("Friend", false),
                        ],
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(side: const BorderSide(color: obDarkGreen), foregroundColor: obDarkGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text("Add this contact"),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 30),

          const Text("ALERT DELIVERY", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black45, letterSpacing: 1.5)),
          const SizedBox(height: 10),
          _buildToggleRow("SMS alert", true),
          _buildToggleRow("Voice call (Robo)", true),
          _buildToggleRow("Flash red beacon", false),
          
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity, height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: obDarkGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
              onPressed: _nextPage,
              child: const Text("Continue", style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildContactItem(String initial, String name, String phone, Color color, bool isPrimary) {
    return Row(
      children: [
        Container(width: 40, height: 40, decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Center(child: Text(initial, style: TextStyle(color: color, fontWeight: FontWeight.bold)))),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(phone, style: const TextStyle(color: Colors.black54, fontSize: 12)),
            ],
          ),
        ),
        if (isPrimary) Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: obLightGreen, borderRadius: BorderRadius.circular(10)), child: const Text("Primary", style: TextStyle(color: obDarkGreen, fontSize: 10, fontWeight: FontWeight.bold)))
        else Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(10)), child: Text("Secondary", style: TextStyle(color: Colors.blue.shade700, fontSize: 10, fontWeight: FontWeight.bold))),
        const SizedBox(width: 10),
        const Icon(Icons.remove_circle_outline, color: Colors.black26),
      ],
    );
  }

  Widget _buildTextField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.black45, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        TextField(decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(color: Colors.black38), isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.black12)))),
      ],
    );
  }

  Widget _buildTag(String text, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: active ? obDarkGreen : Colors.transparent, border: Border.all(color: active ? obDarkGreen : Colors.black26), borderRadius: BorderRadius.circular(12)),
      child: Text(text, style: TextStyle(color: active ? Colors.white : Colors.black54, fontSize: 10)),
    );
  }

  Widget _buildToggleRow(String title, bool active) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
          Switch(value: active, onChanged: (v){}, activeThumbColor: obDarkGreen, activeTrackColor: obDarkGreen.withOpacity(0.5)),
        ],
      ),
    );
  }

  // --- PAGE 4: SAFE ZONES ---
  Widget _buildSafeZonesPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Safe zones", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'serif')),
          const SizedBox(height: 10),
          const Text("Alert family when she leaves trusted areas.", style: TextStyle(color: Colors.black54, fontSize: 15)),
          const SizedBox(height: 20),

          // Map Geofence Preview
          Container(
            height: 160, width: double.infinity,
            decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(20)),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Mock grid
                CustomPaint(painter: GridPainter(Colors.blue.shade200), size: const Size(double.infinity, 160)),
                // Geofence Circle
                Container(width: 80, height: 80, decoration: BoxDecoration(shape: BoxShape.circle, color: obLightGreen.withOpacity(0.5), border: Border.all(color: obDarkGreen, width: 2))),
                const Icon(Icons.home, color: obDarkGreen),
                Positioned(top: 10, right: 10, child: Column(children: [Container(color: Colors.white, padding: const EdgeInsets.all(4), child: const Icon(Icons.add, size: 16)), Container(color: Colors.white, padding: const EdgeInsets.all(4), child: const Icon(Icons.remove, size: 16))]))
              ],
            ),
          ),
          const SizedBox(height: 20),

          const Text("ACTIVE SAFE ZONES", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black45, letterSpacing: 1.5)),
          const SizedBox(height: 10),
          _buildZoneItem(Icons.home, "Home", "Radius: 150m\n8 AM - 8 PM", true),
          const SizedBox(height: 10),
          _buildZoneItem(Icons.school, "School / College", "Radius: 300m\n9 AM - 4 PM", false),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(15)),
            child: const Row(
              children: [
                Icon(Icons.add_circle_outline, color: Colors.black38),
                SizedBox(width: 15),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Add a safe zone", style: TextStyle(fontWeight: FontWeight.bold)), Text("e.g. Workplace, tuition center", style: TextStyle(color: Colors.black45, fontSize: 12))]))
              ],
            ),
          ),

          const SizedBox(height: 30),
          const Text("WHEN SHE LEAVES A ZONE", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black45, letterSpacing: 1.5)),
          _buildToggleRow("Alert family", true),
          _buildToggleRow("Night mode (10pm - 6am)\nHigher sensitivity at night", true),

          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity, height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: obDarkGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
              onPressed: _nextPage,
              child: const Text("Save & continue", style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildZoneItem(IconData icon, String title, String sub, bool activeBadge) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade200)),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: Colors.blue.shade300)),
          const SizedBox(width: 15),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), Text(sub, style: const TextStyle(fontSize: 11, color: Colors.black45))])),
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: activeBadge ? obLightGreen : Colors.blue.shade50, borderRadius: BorderRadius.circular(12)), child: Text("Active", style: TextStyle(color: activeBadge ? obDarkGreen : Colors.blue.shade700, fontSize: 11, fontWeight: FontWeight.bold)))
        ],
      ),
    );
  }

  // --- PAGE 5: CALIBRATE SENSORS ---
  Widget _buildCalibrateSensorsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Calibrate sensors", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'serif')),
          const SizedBox(height: 10),
          const Text("Set personalized baselines for accurate alerts.", style: TextStyle(color: Colors.black54, fontSize: 15)),
          const SizedBox(height: 30),

          // Baselines
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade200)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("RESTING BASELINE (A.I. DETECTED)", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black45, letterSpacing: 1.5)),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildBaseMetric("68", "bpm", "Avg HR", obLightGreen, obDarkGreen),
                    _buildBaseMetric("18", "%", "Stress", obLightGreen, obDarkGreen),
                    _buildBaseMetric("98", "%", "SpO2", Colors.blue.shade50, Colors.blue.shade700),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 20),

          // SOS Threshold
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade200)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("SOS PANIC THRESHOLD", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black45, letterSpacing: 1.5)),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Trigger when stress\nexceeds:", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("85%", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red.shade700)),
                  ],
                ),
                const SizedBox(height: 10),
                Slider(value: 85, min: 0, max: 100, activeColor: Colors.red.shade700, onChanged: (v){}),
                const Text("Standard AI Panic Value is 85% for +95% accuracy.", style: TextStyle(fontSize: 11, color: Colors.black45)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const Text("ADDITIONAL PROTECTION", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black45, letterSpacing: 1.5)),
          _buildToggleRow("Fall detection\nAccelerometer alert", true),
          _buildToggleRow("Black box audio\nRecord on SOS trigger", true),
          _buildToggleRow("Auto call 112\nCall police on SOS trigger", false),
          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity, height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: obDarkGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
              onPressed: _nextPage,
              child: const Text("Complete setup — Start protecting", style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 15),
          const Center(child: Text("All biometrics stay encrypted locally - never synced", style: TextStyle(fontSize: 11, color: Colors.black45))),
        ],
      ),
    );
  }

  Widget _buildBaseMetric(String val, String unit, String label, Color bg, Color textCol) {
    return Container(
      width: 80, padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic,
            children: [
              Text(val, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textCol)),
              Text(" $unit", style: TextStyle(fontSize: 10, color: textCol)),
            ],
          ),
          const SizedBox(height: 5),
          Text(label, style: TextStyle(fontSize: 11, color: textCol)),
        ],
      ),
    );
  }
}
