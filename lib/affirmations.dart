import 'dart:math';
import 'package:flutter/material.dart';

class AffirmationsPage extends StatefulWidget {
  const AffirmationsPage({super.key});

  @override
  State<AffirmationsPage> createState() => _AffirmationsPageState();
}

class _AffirmationsPageState extends State<AffirmationsPage> {
  final List<String> _affirmations = [
    "I am calm, relaxed, and in control.",
    "I choose positivity over negativity.",
    "I am grateful for this moment.",
    "I have the power to create change.",
    "I am enough, just as I am.",
    "I radiate peace and love.",
    "My mind is clear and focused.",
  ];

  String _current = "";

  void _showNewAffirmation() {
    final random = Random();
    setState(() {
      _current = _affirmations[random.nextInt(_affirmations.length)];
    });
  }

  @override
  void initState() {
    super.initState();
    _showNewAffirmation(); // show one when page opens
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Daily Affirmations",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2E9D8A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _current,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2E9D8A),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E9D8A),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _showNewAffirmation,
                child: const Text(
                  "Show Another",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
