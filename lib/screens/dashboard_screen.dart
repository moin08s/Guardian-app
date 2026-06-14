import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/dashboard_provider.dart';
import '../widgets/dashboard_ui.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DashboardProvider>();

    // Determine the state mode
    String mode = 'safe'; // 'safe', 'panic', 'tamper'
    if (provider.isSOSActive) {
      if (provider.sosReason == "STRAP_REMOVED_BY_FORCE" || provider.sosReason == "SENSOR_HUB_DISCONNECTED_CRITICAL") {
        mode = 'tamper';
      } else {
        mode = 'panic';
      }
    }

    AppTheme theme;
    if (mode == 'safe') {
      theme = AppTheme.safe();
    } else if (mode == 'panic') theme = AppTheme.panic();
    else theme = AppTheme.tamper();

    return Scaffold(
      backgroundColor: bgCream,
      body: SafeArea(
        child: Column(
          children: [
            // SCROLLABLE BODY
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  children: [
                    // TOP BAR
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("9:41", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
                        if (mode == 'panic')
                           Text("EMERGENCY", style: TextStyle(fontWeight: FontWeight.bold, color: panicRedText.withOpacity(0.5), letterSpacing: 1.5))
                        else if (mode == 'tamper')
                           Text("TAMPER", style: TextStyle(fontWeight: FontWeight.bold, color: tamperOrangeText, letterSpacing: 1.5))
                        else
                           const Text("Safe · home", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black45)),
                        
                        Row(
                          children: [
                            const Icon(Icons.signal_cellular_4_bar, size: 16, color: Colors.black54),
                            const SizedBox(width: 15),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
                              },
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: safeGreenBg,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: safeGreenText, width: 1.5),
                                ),
                                child: const Center(
                                  child: Text("P", style: TextStyle(color: safeGreenText, fontWeight: FontWeight.bold, fontSize: 16)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // LOGO HEADER
                    Row(
                      children: [
                        const Text("Guardian", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, fontFamily: 'serif')), // Serif simulation
                        const SizedBox(width: 5),
                        Text("AI", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: panicRedText.withOpacity(0.6))),
                      ],
                    ),
                    const SizedBox(height: 25),

                    // DYNAMIC STATUS HEADER
                    if (mode == 'safe')
                      StatusHeaderCard(
                        title: "You are protected",
                        subtitle: "Strap connected · all sensors normal",
                        icon: Icons.check_circle_outline,
                        theme: theme,
                      )
                    else if (mode == 'panic')
                       StatusHeaderCard(
                        title: "Emergency alert sent",
                        subtitle: "Panic detected · help is coming",
                        icon: Icons.shield_outlined,
                        theme: theme,
                      )
                    else
                      StatusHeaderCard(
                        title: "Device tamper detected",
                        subtitle: "Strap disconnected · last known sent",
                        icon: Icons.block,
                        theme: theme,
                      ),
                      
                    const SizedBox(height: 15),

                    // MINI MAP
                    MiniMapCard(pos: provider.currentPos, accuracy: 4, theme: theme),

                    // DYNAMIC CONTENT BLOCK
                    if (mode != 'tamper') ...[
                      const SizedBox(height: 15),
                      MetricsGrid(mode: mode, theme: theme),
                      const SizedBox(height: 15),
                    ],

                    if (mode == 'safe') ...[
                      const StrapStatusCard(),
                      const SizedBox(height: 25),
                      ActionButton(
                        label: "Ping device / Test alarm", 
                        isFilled: false,
                        theme: theme, 
                        onTap: () {
                          // Allow parent to quietly ping or test connect to the device.
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Ping sent to Guardian Hub."))
                          );
                        }
                      ),
                    ]
                    else if (mode == 'panic') ...[
                      const SizedBox(height: 15),
                      const AIGuidanceCard(steps: [
                        "Call 112. Your live location has been shared.",
                        "Move toward an open, lit area if possible.",
                        "Sangli City PS is 1.2 km north. Stay on the line."
                      ]),
                      const SizedBox(height: 25),
                      ActionButton(
                        label: "Clear alert from phone", 
                        isFilled: true,
                        theme: theme, 
                        onTap: () {
                          provider.clearSOS();
                        }
                      ),
                    ]
                    else ...[
                      const SizedBox(height: 15),
                      // Tamper Specific "Strap disconnected" banner
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                        decoration: BoxDecoration(
                          color: theme.bgColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: theme.lineBg, width: 1.5),
                        ),
                        child: Row(
                          children: [
                             Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: tamperOrangeText)),
                             const SizedBox(width: 15),
                             Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 Text("Strap disconnected", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 15)),
                                 Text("No signal for 38 seconds", style: TextStyle(color: Colors.black54, fontSize: 13)),
                               ],
                             ),
                             const Spacer(),
                             Text("Tamper", style: TextStyle(color: tamperOrangeText, fontSize: 13)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      const TamperStatusCard(),
                      const SizedBox(height: 15),
                      const AIGuidanceCard(steps: [
                        "Authorities alerted. Evidence preserved automatically.",
                        "Do not switch off the hub. GPS tracking continues."
                      ]),
                      const SizedBox(height: 25),
                      ActionButton(
                        label: "Clear Tamper State", 
                        isFilled: true,
                        theme: theme, 
                        onTap: () {
                          provider.clearSOS();
                        }
                      ),
                    ],
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),

            // REMOVED CustomBottomNav since it's handled by MainWrapperScreen
          ],
        ),
      ),
    );
  }
}
