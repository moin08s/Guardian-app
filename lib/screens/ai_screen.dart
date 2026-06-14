import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/dashboard_provider.dart';
import '../widgets/dashboard_ui.dart';

class AIScreen extends StatefulWidget {
  const AIScreen({super.key});

  @override
  State<AIScreen> createState() => _AIScreenState();
}

class _AIScreenState extends State<AIScreen> {
  final TextEditingController _chatController = TextEditingController();

  final List<Map<String, dynamic>> _messages = [
    {
      "isAi": true,
      "text": "Hello. All biometrics look calm. I'm monitoring continuously. You can ask me anything about your safety.",
      "time": "9:38 AM"
    },
    {
      "isAi": false,
      "text": "What should I do if I feel unsafe walking home tonight?",
      "time": "9:39 AM"
    },
    {
      "isAi": true,
      "text": "Here are 3 steps to stay safe:\n\n1. Stay on lit, busy streets. Share your route with a contact.\n2. I'm watching your heart rate. Any spike triggers an auto-alert.\n3. Nearest safe space: Sangli Bus Stand, 0.4 km east.",
      "time": "9:39 AM"
    }
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<DashboardProvider>();

    return Scaffold(
      backgroundColor: bgCream,
      body: SafeArea(
        child: Column(
          children: [
            // Top Header
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Text("9:41", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
                   Text("All clear", style: TextStyle(fontWeight: FontWeight.bold, color: safeGreenText)),
                ],
              ),
            ),
            
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("AI Advisor", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'serif')),
                      const SizedBox(height: 5),
                      Text("Powered by Llama 3.3 - private & local", style: TextStyle(color: Colors.black45, fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Current Situation
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.shade300)
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("CURRENT SITUATION", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black45, letterSpacing: 1.5)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text("HR ", style: TextStyle(color: Colors.black45, fontSize: 13)),
                        Text("${state.heartRate} bpm", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(width: 20),
                        Text("Stress ", style: TextStyle(color: Colors.black45, fontSize: 13)),
                        Text("${state.stressLevel.toInt()}%", style: TextStyle(color: safeGreenText, fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                         Text("Status ", style: TextStyle(color: Colors.black45, fontSize: 13)),
                         Text(state.isSOSActive ? "Emergency" : "Protected", style: TextStyle(color: safeGreenText, fontWeight: FontWeight.bold, fontSize: 13)),
                         const SizedBox(width: 20),
                         Text("BLE ", style: TextStyle(color: Colors.black45, fontSize: 13)),
                         Text("Connected", style: TextStyle(color: safeGreenText, fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Chat Interface
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return _buildMessage(msg['text'], msg['isAi'], msg['time']);
                },
              ),
            ),

            // Input Box
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.grey.shade300)
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 20),
                    Expanded(
                      child: TextField(
                        controller: _chatController,
                        decoration: const InputDecoration(
                          hintText: "Ask anything...",
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Colors.black38)
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(5),
                      decoration: BoxDecoration(color: const Color(0xFF0F5A48), shape: BoxShape.circle),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                        onPressed: () {},
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMessage(String text, bool isAi, String time) {
    if (isAi) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 20, right: 40),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: safeGreenBg,
                shape: BoxShape.circle,
                border: Border.all(color: safeGreenText, width: 1.5)
              ),
              child: const Icon(Icons.star_border, color: safeGreenText, size: 16),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(topRight: Radius.circular(20), bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
                  border: Border.all(color: Colors.grey.shade300)
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(text, style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4)),
                    const SizedBox(height: 10),
                    Text(time, style: const TextStyle(fontSize: 10, color: Colors.black45)),
                  ],
                ),
              ),
            )
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(bottom: 20, left: 40),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: const BoxDecoration(
                  color: Color(0xFF0F5A48),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20), bottomLeft: Radius.circular(20)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(text, style: const TextStyle(fontSize: 14, color: Colors.white, height: 1.4)),
                    const SizedBox(height: 10),
                    Text(time, style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.6))),
                  ],
                ),
              ),
            )
          ],
        ),
      );
    }
  }
}
