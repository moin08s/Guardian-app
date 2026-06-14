import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/dashboard_provider.dart';
import '../widgets/dashboard_ui.dart';
import 'dashboard_screen.dart';
import 'map_tab_screen.dart';
import 'ai_screen.dart';
import 'log_screen.dart';

class MainWrapperScreen extends StatefulWidget {
  const MainWrapperScreen({super.key});

  @override
  State<MainWrapperScreen> createState() => _MainWrapperScreenState();
}

class _MainWrapperScreenState extends State<MainWrapperScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const MapTabScreen(),
    const AIScreen(),
    const LogScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Determine the state mode for theming the bottom bar
    final provider = context.watch<DashboardProvider>();
    String mode = 'safe'; 
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
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: InteractiveBottomNav(
        theme: theme,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

// -----------------------------------------------------
// INTERACTIVE BOTTOM NAVBAR
// -----------------------------------------------------
class InteractiveBottomNav extends StatelessWidget {
  final AppTheme theme;
  final int currentIndex;
  final Function(int) onTap;

  const InteractiveBottomNav({
    super.key,
    required this.theme,
    required this.currentIndex,
    required this.onTap,
  });

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
          _buildItem(0, "Home", Icons.home_rounded),
          _buildItem(1, "Map", Icons.map_rounded),
          _buildItem(2, "AI", Icons.auto_awesome),
          _buildItem(3, "Log", Icons.view_headline_rounded),
        ],
      ),
    );
  }

  Widget _buildItem(int index, String label, IconData icon) {
    bool active = index == currentIndex;
    Color color = active ? theme.textColor : Colors.black45;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: active ? color.withOpacity(0.15) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: active ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
