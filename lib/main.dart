import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'firebase_options.dart';
import 'landing_page.dart';
import 'dashboard.dart';
import 'kids_mode_dashboard.dart';
import 'kids_mode_service.dart';
import 'kids_overlay_service.dart';
import 'parent_pin_service.dart';

// Overlay entry point
@pragma("vm:entry-point")
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: KidsOverlayBlockingScreen(),
    ),
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("✅ Firebase initialized successfully");
  } catch (e) {
    print("❌ Firebase initialization error: $e");
    print("App will continue with local authentication only");
  }

  // Initialize Kids Mode service
  await KidsModeService().initialize();

  // Listen for messages from overlay
  _setupOverlayListener();

  runApp(const MyApp());
}

/// Setup listener for overlay communication
void _setupOverlayListener() {
  FlutterOverlayWindow.overlayListener.listen((data) async {
    print('📥 Main app received data from overlay: $data');

    if (data['action'] == 'verify_pin') {
      final pin = data['pin'] as String?;
      print('🔐 Main app verifying PIN: ${pin?.length} digits');

      if (pin != null && pin.length == 4) {
        final parentPinService = ParentPinService();
        final isValid = await parentPinService.verifyPin(pin);
        print('🔐 Main app verification result: $isValid');

        // Send result back to overlay
        FlutterOverlayWindow.shareData({
          'action': 'pin_verified',
          'is_valid': isValid,
        });

        // If valid, stop Kids Mode
        if (isValid) {
          print('✅ PIN correct - stopping Kids Mode');
          await KidsModeService().stopKidsMode();
        }
      } else {
        print('❌ Invalid PIN format from overlay');
        FlutterOverlayWindow.shareData({
          'action': 'pin_verified',
          'is_valid': false,
        });
      }
    } else if (data['action'] == 'verify_pin_add_time') {
      final pin = data['pin'] as String?;
      final minutes = data['minutes'] as int? ?? 15;
      print(
        '⏰ Main app verifying PIN for add time: ${pin?.length} digits, adding $minutes minutes',
      );

      if (pin != null && pin.length == 4) {
        final parentPinService = ParentPinService();
        final isValid = await parentPinService.verifyPin(pin);
        print('⏰ Main app verification result: $isValid');

        // Send result back to overlay
        FlutterOverlayWindow.shareData({
          'action': 'time_added',
          'is_valid': isValid,
        });

        // If valid, add time and close overlay
        if (isValid) {
          print('✅ PIN correct - adding $minutes minutes');
          await KidsModeService().addExtraTime(minutes);
        }
      } else {
        print('❌ Invalid PIN format from overlay');
        FlutterOverlayWindow.shareData({
          'action': 'time_added',
          'is_valid': false,
        });
      }
    } else if (data['action'] == 'unlock') {
      print('🔓 Unlock action received from overlay');
      await KidsModeService().stopKidsMode();
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Digital Detox App',
      home: FutureBuilder<bool>(
        future: _checkKidsModeActive(),
        builder: (context, kidsModeSnapshot) {
          // Show loading while checking
          if (kidsModeSnapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: Color(0xFF2E9D8A)),
              ),
            );
          }

          // If Kids Mode is active, go directly to Kids Dashboard
          if (kidsModeSnapshot.data == true) {
            return const KidsModeDashboard();
          }

          // Show normal app flow (original landing page with animations)
          // Always start with landing page for non-kids mode
          return const LandingPage();
        },
      ),
    );
  }

  Future<bool> _checkKidsModeActive() async {
    final kidsModeService = KidsModeService();
    return kidsModeService.isActive;
  }
}
