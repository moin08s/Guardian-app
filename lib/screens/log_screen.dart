import 'package:flutter/material.dart';
import '../widgets/dashboard_ui.dart';

class LogScreen extends StatelessWidget {
  const LogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgCream,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Text("9:41", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
                   Text("3 events today", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black45)),
                ],
              ),
            ),
            
            // Title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Event log", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'serif')),
                  SizedBox(height: 5),
                  Text("Full history · tap to expand", style: TextStyle(color: Colors.black45, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildChip("All", true),
                    const SizedBox(width: 10),
                    _buildChip("SOS", false),
                    const SizedBox(width: 10),
                    _buildChip("Biometric", false),
                    const SizedBox(width: 10),
                    _buildChip("Device", false),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Timeline
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildTimelineItem(
                    icon: Icons.star, iconColor: panicRedText, iconBg: panicRedBg,
                    title: "SOS resolved", time: "9:14 AM",
                    desc: "Panic spike detected. Auto-alert sent. User confirmed safe after 4 min.",
                    tags: [
                      _buildTag("HR 118 bpm", panicRedBg, panicRedText),
                      _buildTag("Stress 91%", panicRedBg, panicRedText),
                      _buildTag("Audio saved", Colors.blue.shade50, Colors.blue.shade700),
                    ],
                    isFirst: true, isLast: false,
                  ),
                  _buildTimelineItem(
                    icon: Icons.show_chart, iconColor: tamperOrangeText, iconBg: tamperOrangeBg,
                    title: "Stress elevated", time: "8:52 AM",
                    desc: "GSR reading above 70% for 45 seconds. Subsided naturally. No alert triggered.",
                    tags: [
                      _buildTag("GSR 73%", tamperOrangeBg, tamperOrangeText),
                      _buildTag("45 sec", tamperOrangeBg, tamperOrangeText),
                    ],
                    isFirst: false, isLast: false,
                  ),
                  _buildTimelineItem(
                    icon: Icons.check_circle_outline, iconColor: safeGreenText, iconBg: safeGreenBg,
                    title: "System online", time: "7:30 AM",
                    desc: "Strap connected. Hub online. All sensors calibrated. Battery at 91%.",
                    tags: [],
                    isFirst: false, isLast: false,
                  ),
                  _buildTimelineItem(
                    icon: Icons.radio_button_unchecked, iconColor: Colors.grey.shade600, iconBg: Colors.white,
                    title: "Routine heartbeat", time: "Yesterday",
                    desc: "",
                    tags: [],
                    isFirst: false, isLast: true, isFaded: true
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: active ? Colors.black87 : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: active ? Colors.black87 : Colors.grey.shade300)
      ),
      child: Text(label, style: TextStyle(color: active ? Colors.white : Colors.black87, fontSize: 13, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildTag(String text, Color bg, Color textCol) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      margin: const EdgeInsets.only(right: 8, top: 8),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: TextStyle(color: textCol, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildTimelineItem({
    required IconData icon, required Color iconColor, required Color iconBg,
    required String title, required String time, required String desc, required List<Widget> tags,
    required bool isFirst, required bool isLast, bool isFaded = false
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline Line & Icon
          SizedBox(
            width: 50,
            child: Column(
              children: [
                Container(width: 2, height: isFirst ? 0 : 20, color: Colors.grey.shade300),
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: iconBg,
                    shape: BoxShape.circle,
                    border: Border.all(color: iconBg == Colors.white ? Colors.grey.shade400 : iconColor, width: 1.5)
                  ),
                  child: Icon(icon, color: iconColor, size: 16),
                ),
                Expanded(child: Container(width: 2, color: isLast ? Colors.transparent : Colors.grey.shade300)),
              ],
            ),
          ),
          
          const SizedBox(width: 10),
          
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30, top: 5), // Added top padding to align with icon
              child: Opacity(
                opacity: isFaded ? 0.5 : 1.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: iconColor == Colors.grey.shade600 ? Colors.black54 : iconColor)),
                        Text(time, style: const TextStyle(fontSize: 12, color: Colors.black45)),
                      ],
                    ),
                    if (desc.isNotEmpty) const SizedBox(height: 8),
                    if (desc.isNotEmpty) Text(desc, style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.4)),
                    if (tags.isNotEmpty) Wrap(children: tags),
                    
                    if (desc.isNotEmpty) const SizedBox(height: 15),
                    if (desc.isNotEmpty) Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade300)),
                      child: const Center(child: Text("Audio saved", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12))),
                    ) // this matches the specific audio saved button seen under the first event? Ah wait, the first event HAS an 'Audio saved' button. I'll just hardcode it or show it generically if tags exist
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
