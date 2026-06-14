import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/dashboard_provider.dart';
import 'package:latlong2/latlong.dart';

// --- THEME COLORS ---
const Color bgCream = Color(0xFFFBF9F1);

// Safe
const Color safeGreenText = Color(0xFF13765f);
const Color safeGreenBg = Color(0xFFe5f5f1);
const Color safeBlueLines = Color(0xFFd0def5);
const Color safeOrange = Color(0xFFe08d23);

// Panic
const Color panicRedText = Color(0xFFa43434);
const Color panicRedBg = Color(0xFFfae8e8);
const Color panicRedLines = Color(0xFFf0caca);

// Tamper
const Color tamperOrangeText = Color(0xFF8f5a18);
const Color tamperOrangeBg = Color(0xFFfaebd7);
const Color tamperOrangeLines = Color(0xFFead1b8);

class AppTheme {
  final Color textColor;
  final Color bgColor;
  final Color lineBg;

  AppTheme(this.textColor, this.bgColor, this.lineBg);

  factory AppTheme.safe() => AppTheme(safeGreenText, safeGreenBg, safeBlueLines);
  factory AppTheme.panic() => AppTheme(panicRedText, panicRedBg, panicRedLines);
  factory AppTheme.tamper() => AppTheme(tamperOrangeText, tamperOrangeBg, tamperOrangeLines);
}

// -----------------------------------------------------
// 1. STATUS HEADER CARD
// -----------------------------------------------------
class StatusHeaderCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final AppTheme theme;

  const StatusHeaderCard({super.key, required this.title, required this.subtitle, required this.icon, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        color: theme.bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.textColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.textColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: theme.textColor, size: 28),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: theme.textColor, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: theme.textColor.withOpacity(0.8), fontSize: 13)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// -----------------------------------------------------
// 2. MINI MAP CARD
// -----------------------------------------------------
class MiniMapCard extends StatelessWidget {
  final LatLng pos;
  final double accuracy;
  final AppTheme theme;

  const MiniMapCard({super.key, required this.pos, required this.accuracy, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.lineBg.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.lineBg.withOpacity(0.5), width: 1),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          // Simulated Grid/Map Background Map
          Positioned.fill(
              child: CustomPaint(
                painter: GridPainter(theme.lineBg),
              )
          ),
          
          // Marker
          Center(
            child: Container(
              width: 16, height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: theme.textColor, width: 4),
                color: Colors.white,
              ),
            ),
          ),
          
          // Labels
          Positioned(
            bottom: 10, left: 15,
            child: Text("${pos.latitude.toStringAsFixed(4)}°N - ${pos.longitude.toStringAsFixed(4)}°E", 
              style: TextStyle(color: theme.textColor.withOpacity(0.7), fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          Positioned(
            bottom: 10, right: 15,
            child: Text("Live ± ${accuracy.toInt()}m", // Just mock accuracy display
              style: TextStyle(color: theme.textColor, fontSize: 10, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  final Color lineColor;
  GridPainter(this.lineColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor.withOpacity(0.4)
      ..strokeWidth = 1.0;
      
    double step = 30;
    for (double i = 0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }

    // Draw some bold lines to simulate roads
    paint.strokeWidth = 6.0;
    paint.color = lineColor;
    canvas.drawLine(Offset(0, size.height/2 + 10), Offset(size.width, size.height/2 + 20), paint);
    canvas.drawLine(Offset(size.width/2 - 20, 0), Offset(size.width/2 + 10, size.height), paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// -----------------------------------------------------
// 3. METRICS GRID & CARDS
// -----------------------------------------------------
class MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final AppTheme theme;
  final Color barColor;
  final double barFill;

  const MetricCard({super.key, required this.label, required this.value, required this.unit, required this.theme, required this.barColor, required this.barFill});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.lineBg, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: TextStyle(color: theme.textColor.withOpacity(0.6), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          const SizedBox(height: 5),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: TextStyle(color: Colors.black87, fontSize: 32, fontWeight: FontWeight.normal)),
              const SizedBox(width: 4),
              Text(unit, style: TextStyle(color: Colors.black54, fontSize: 14)),
            ],
          ),
          const Spacer(),
          // Custom Progress bar
          Container(
            height: 3, width: double.infinity,
            color: theme.lineBg.withOpacity(0.5),
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: barFill.clamp(0.0, 1.0),
              child: Container(color: barColor),
            ),
          )
        ],
      ),
    );
  }
}

class MetricsGrid extends StatelessWidget {
  final String mode; // 'safe' or 'panic'
  final AppTheme theme;
  const MetricsGrid({super.key, required this.mode, required this.theme});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DashboardProvider>();

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.45,
      children: [
        MetricCard(
          label: "HEART\nRATE", 
          value: "${provider.heartRate}", unit: "bpm", theme: theme, 
          barColor: mode == 'safe' ? safeGreenText : panicRedText, 
          barFill: provider.heartRate / 180,
        ),
        if (mode == 'safe')
           MetricCard(
             label: "CALM\nINDEX", 
             value: "${provider.calmIndex.toInt()}", unit: "%", theme: theme, 
             barColor: safeGreenText, barFill: provider.calmIndex / 100,
           )
        else
           MetricCard(
             label: "STRESS", 
             value: "${provider.stressLevel.toInt()}", unit: "%", theme: theme, 
             barColor: panicRedText, barFill: provider.stressLevel / 100,
           ),
        
        MetricCard(
           label: "SPO₂", 
           value: "${provider.spo2}", unit: "%", theme: theme, 
           barColor: Colors.blueAccent, barFill: provider.spo2 / 100,
        ),
        if (mode == 'safe')
           MetricCard(
             label: "BATTERY", 
             value: "${provider.lastBattery}", unit: "%", theme: theme, 
             barColor: safeOrange, barFill: provider.lastBattery / 100,
           )
        else
           // Panic Mode Audio Card
           Container(
             padding: const EdgeInsets.all(15),
             decoration: BoxDecoration(
               color: Colors.white,
               borderRadius: BorderRadius.circular(20),
               border: Border.all(color: theme.lineBg, width: 1.5),
             ),
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 Text("AUDIO", style: TextStyle(color: theme.textColor.withOpacity(0.6), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                 Text("Recording", style: TextStyle(color: panicRedText, fontSize: 18, fontWeight: FontWeight.normal)),
                 const SizedBox(height: 5),
                 Text("Black box active", style: TextStyle(color: Colors.black54, fontSize: 12)),
               ],
             ),
           )
      ],
    );
  }
}

// -----------------------------------------------------
// 4. STRAP STATUS CARD (Safe Mode)
// -----------------------------------------------------
class StrapStatusCard extends StatelessWidget {
  const StrapStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: safeBlueLines, width: 1.5),
      ),
      child: Row(
        children: [
          Container(width: 10, height: 10, decoration: const BoxDecoration(shape: BoxShape.circle, color: safeGreenText)),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Strap connected", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text("BLE - signal excellent", style: TextStyle(color: Colors.black45, fontSize: 12)),
              ],
            ),
          ),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("3.2 days", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text("left", style: TextStyle(color: Colors.black45, fontSize: 12)),
            ],
          )
        ],
      ),
    );
  }
}

// -----------------------------------------------------
// 5. TAMPER STATUS MATRIX CARD
// -----------------------------------------------------
class TamperStatusCard extends StatelessWidget {
  const TamperStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: tamperOrangeLines, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("HUB STATUS", style: TextStyle(color: Colors.black45, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          const SizedBox(height: 15),
          _buildRow("4G uplink", "Active", safeGreenText),
          const SizedBox(height: 12),
          _buildRow("Black box", "Recording", panicRedText),
          const SizedBox(height: 12),
          _buildRow("Firebase", "Alert sent", safeGreenText),
          const SizedBox(height: 12),
          _buildRow("GPS", "Still active", safeGreenText),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, Color vColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 15, color: Colors.black87)),
        Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: vColor)),
      ],
    );
  }
}

// -----------------------------------------------------
// 6. AI GUIDANCE CARD
// -----------------------------------------------------
class AIGuidanceCard extends StatelessWidget {
  final List<String> steps;
  const AIGuidanceCard({super.key, required this.steps});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("AI GUIDANCE · LLAMA 3.3", style: TextStyle(color: Colors.black45, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          const SizedBox(height: 20),
          ...steps.asMap().entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24, height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: panicRedText, width: 1.5),
                  ),
                  child: Text("${e.key + 1}", style: const TextStyle(color: panicRedText, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 15),
                Expanded(child: Text(e.value, style: const TextStyle(color: Colors.black87, fontSize: 14, height: 1.4))),
              ],
            ),
          ))
        ],
      ),
    );
  }
}

// -----------------------------------------------------
// 7. ACTION BUTTON
// -----------------------------------------------------
class ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final AppTheme theme;
  final bool isFilled;

  const ActionButton({super.key, required this.label, required this.onTap, required this.theme, this.isFilled = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isFilled ? theme.bgColor : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: theme.textColor.withOpacity(0.5), width: 1),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(color: isFilled ? theme.textColor : Colors.black87, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// -----------------------------------------------------
// 8. BOTTOM NAVBAR
// -----------------------------------------------------
class CustomBottomNav extends StatelessWidget {
  final AppTheme theme;
  const CustomBottomNav({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 20, top: 10),
      decoration: const BoxDecoration(
        color: bgCream,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildItem("Home", true, theme.textColor),
          _buildItem("Map", false, Colors.black45),
          _buildItem("AI", false, Colors.black45),
          _buildItem("Log", false, Colors.black45),
        ],
      ),
    );
  }

  Widget _buildItem(String label, bool active, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24, height: 24,
          decoration: BoxDecoration(
            color: active ? color.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: active ? color : Colors.black26),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: active ? color : Colors.black45, fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
