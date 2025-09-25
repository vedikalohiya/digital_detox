import 'package:flutter/material.dart';
import 'landing_page.dart'; // start here

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Digital Detox App',
      home: LandingPage(), // ✅ Start with Landing first
    );
  }
}
