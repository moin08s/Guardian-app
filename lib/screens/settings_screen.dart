import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/dashboard_ui.dart';
import '../state/dashboard_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DashboardProvider>(context);

    return Scaffold(
      backgroundColor: bgCream,
      body: SafeArea(
        child: Column(
          children: [
            // Top Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   const Text("9:41", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
                   const Text("Settings · profile", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black45)),
                   GestureDetector(
                     onTap: () => Navigator.pop(context),
                     child: const Icon(Icons.close, color: Colors.black54),
                   ),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    // Profile Header
                    Row(
                      children: [
                        Container(
                          width: 60, height: 60,
                          decoration: BoxDecoration(
                            color: safeLightBg(),
                            shape: BoxShape.circle,
                            border: Border.all(color: safeGreenText, width: 1.5)
                          ),
                          child: const Center(child: Text("P", style: TextStyle(color: safeGreenText, fontSize: 28, fontWeight: FontWeight.bold))),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Priya\nSharma", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'serif', height: 1.1)),
                              const SizedBox(height: 4),
                              Text("Abhaya AI - Unit 001", style: TextStyle(color: Colors.black45, fontSize: 13)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: safeLightBg(), borderRadius: BorderRadius.circular(20)),
                          child: const Text("Active", style: TextStyle(color: safeGreenText, fontWeight: FontWeight.bold, fontSize: 12)),
                        )
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Trusted Contacts
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade300)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("TRUSTED CONTACTS", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black45, letterSpacing: 1.5)),
                          const SizedBox(height: 15),
                          _buildContactRow("M", "Mom", "+91 ••••• ••210", Colors.teal),
                          const SizedBox(height: 15),
                          _buildContactRow("R", "Rahul", "+91 ••••• ••211", Colors.orange),
                          const SizedBox(height: 15),
                          Divider(color: Colors.grey.shade200),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Container(
                                width: 40, height: 40,
                                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade400, style: BorderStyle.none /* Wait flutter doesn't have dashed natively without custom painters, I'll just use light solid */), color: Colors.grey.shade100),
                                child: const Icon(Icons.add, color: Colors.black45),
                              ),
                              const SizedBox(width: 15),
                              const Text("Add contact", style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w500)),
                            ],
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Alert Thresholds
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade300)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("ALERT THRESHOLDS", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black45, letterSpacing: 1.5)),
                          const SizedBox(height: 15),
                          _buildThresholdRow("Panic stress level", "Auto-SOS if exceeded", "85%", panicRedText),
                          Divider(color: Colors.grey.shade200, height: 25),
                          _buildThresholdRow("BLE timeout", "Tamper alert delay", "45 s", tamperOrangeText),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Device Info
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade300)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("DEVICE", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black45, letterSpacing: 1.5)),
                          const SizedBox(height: 15),
                          _buildDeviceRow("Hub firmware", "v2.4.1"),
                          const SizedBox(height: 10),
                          _buildDeviceRow("Strap firmware", "v1.2.0"),
                          const SizedBox(height: 10),
                          _buildDeviceRow("Unit ID", "UNIT_001"),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Data privacy", style: TextStyle(color: Colors.black87)),
                              const Text("Local processing", style: TextStyle(color: safeGreenText, fontWeight: FontWeight.bold)),
                            ],
                          )
                        ],
                      ),
                    ),
                    if (provider.isIoTOnline)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 30),
                        child: InkWell(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Powering off strap and device...')),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: const Center(
                              child: Text(
                                "Power off strap and device",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color safeLightBg() => const Color(0xFFE5F5F1);

  Widget _buildContactRow(String initial, String name, String phone, Color color) {
    return Row(
      children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Center(child: Text(initial, style: TextStyle(color: color, fontWeight: FontWeight.bold))),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
              Text(phone, style: const TextStyle(color: Colors.black45, fontSize: 12)),
            ],
          ),
        ),
        Container(
          width: 8, height: 8,
          decoration: const BoxDecoration(color: safeGreenText, shape: BoxShape.circle),
        )
      ],
    );
  }

  Widget _buildThresholdRow(String title, String subtitle, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(color: Colors.black45, fontSize: 12)),
          ],
        ),
        Text(value, style: TextStyle(color: valueColor, fontWeight: FontWeight.bold, fontSize: 18)),
      ],
    );
  }

  Widget _buildDeviceRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.black87)),
        Text(value, style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
