import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'landing_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  try {
    await FirebaseAuth.instance.setSettings(
      appVerificationDisabledForTesting: true,
      userAccessGroup: null,
    );
  } catch (e) {
    // Debug: Firebase Auth settings error
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Digital Detox App',
      home: LandingPage(),
    );
  }
}
