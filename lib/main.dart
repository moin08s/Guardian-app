import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'state/dashboard_provider.dart';
import 'screens/onboarding_screens.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase initialization note: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
      ],
      child: const MaterialApp(
        title: 'Abhaya',
        home: OnboardingWelcomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    ),
  );
}