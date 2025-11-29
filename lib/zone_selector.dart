import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_model.dart';
import 'login.dart';

const Color kPrimaryColor = Color(0xFF2E9D8A);
const Color kBackgroundColor = Color(0xFFF5F5DC);

class ZoneSelectorPage extends StatefulWidget {
  const ZoneSelectorPage({super.key});

  @override
  State<ZoneSelectorPage> createState() => _ZoneSelectorPageState();
}

class _ZoneSelectorPageState extends State<ZoneSelectorPage> {
  bool _isLoading = false;

  Future<void> _selectZone(UserZone zone) async {
    print('🔵 Zone selected: ${zone.name}');

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_zone', zone.name);
      print('✅ Zone saved locally: ${zone.name}');

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        print('🔵 User logged in, saving to Firestore...');
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'zone': zone.name});
        print('✅ Zone saved to Firestore!');
      }

      if (!mounted) return;

      print('🔵 Navigating to login page...');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } catch (e) {
      print('❌ Error selecting zone: $e');
      setState(() => _isLoading = false);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: kPrimaryColor),
              )
            : Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('👋', style: TextStyle(fontSize: 60)),
                    const SizedBox(height: 20),
                    const Text(
                      'Welcome!',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: kPrimaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Choose Your Zone',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 60),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _ZoneCircle(
                          emoji: '🎨',
                          label: 'Kids\nZone',
                          color: Colors.orange,
                          onTap: () => _selectZone(UserZone.kids),
                        ),

                        _ZoneCircle(
                          emoji: '💼',
                          label: 'Adult\nZone',
                          color: kPrimaryColor,
                          onTap: () => _selectZone(UserZone.adult),
                        ),
                      ],
                    ),

                    const SizedBox(height: 60),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Tap on a circle to select your zone\nYou can change it anytime from settings',
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _ZoneCircle extends StatefulWidget {
  final String emoji;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ZoneCircle({
    required this.emoji,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_ZoneCircle> createState() => _ZoneCircleState();
}

class _ZoneCircleState extends State<_ZoneCircle> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Column(
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color,
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onTap,
                  customBorder: const CircleBorder(),
                  child: Center(
                    child: Text(
                      widget.emoji,
                      style: const TextStyle(fontSize: 70),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: widget.color,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
