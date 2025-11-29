import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'kids_mode_service.dart';
import 'kids_alarm_service.dart';
import 'parent_pin_service.dart';

/// System-wide overlay service for Kids Mode blocking
/// This shows the red blocking screen ON TOP OF ALL APPS
class KidsOverlayService {
  static final KidsOverlayService _instance = KidsOverlayService._internal();
  factory KidsOverlayService() => _instance;
  KidsOverlayService._internal();

  bool _isOverlayActive = false;

  /// Check if overlay permission is granted
  Future<bool> hasOverlayPermission() async {
    try {
      return await FlutterOverlayWindow.isPermissionGranted();
    } catch (e) {
      print('❌ Error checking overlay permission: $e');
      return false;
    }
  }

  /// Request overlay permission from user
  Future<bool> requestOverlayPermission() async {
    try {
      final hasPermission = await FlutterOverlayWindow.isPermissionGranted();

      if (!hasPermission) {
        final granted = await FlutterOverlayWindow.requestPermission();
        return granted ?? false;
      }

      return true;
    } catch (e) {
      print('❌ Error requesting overlay permission: $e');
      return false;
    }
  }

  /// Show system-wide blocking overlay
  Future<void> showBlockingOverlay() async {
    if (_isOverlayActive) {
      print('⚠️ Overlay already active');
      return;
    }

    try {
      // Check permission with timeout to avoid hanging
      final hasPermission = await hasOverlayPermission().timeout(
        Duration(seconds: 2),
        onTimeout: () => false,
      );

      if (!hasPermission) {
        print('⚠️ No overlay permission - will show notification instead');
        // Could add a notification here as fallback
        return;
      }

      // Show overlay window immediately
      await FlutterOverlayWindow.showOverlay(
        enableDrag: false, // Cannot be dragged
        overlayTitle: "Screen Time Over",
        overlayContent: "Time's up! Ask parent to unlock.",
        flag: OverlayFlag.focusPointer,
        visibility: NotificationVisibility.visibilityPublic,
        height: WindowSize.matchParent,
        width: WindowSize.matchParent,
      );

      _isOverlayActive = true;
      print('✅ System blocking overlay shown');
    } catch (e) {
      print('❌ Error showing overlay: $e');
    }
  }

  /// Close the overlay
  Future<void> closeOverlay() async {
    if (!_isOverlayActive) {
      return;
    }

    try {
      await FlutterOverlayWindow.closeOverlay();
      _isOverlayActive = false;
      print('✅ Overlay closed');
    } catch (e) {
      print('❌ Error closing overlay: $e');
    }
  }

  /// Update overlay content
  Future<void> updateOverlay(String title, String content) async {
    try {
      await FlutterOverlayWindow.shareData({
        'title': title,
        'content': content,
      });
    } catch (e) {
      print('❌ Error updating overlay: $e');
    }
  }

  bool get isActive => _isOverlayActive;
}

/// Overlay entry point - This runs in a separate isolate
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

/// The actual blocking screen shown as system overlay
class KidsOverlayBlockingScreen extends StatefulWidget {
  const KidsOverlayBlockingScreen({Key? key}) : super(key: key);

  @override
  State<KidsOverlayBlockingScreen> createState() =>
      _KidsOverlayBlockingScreenState();
}

class _KidsOverlayBlockingScreenState extends State<KidsOverlayBlockingScreen>
    with SingleTickerProviderStateMixin {
  final ParentPinService _pinService = ParentPinService();
  final KidsAlarmService _alarmService = KidsAlarmService();

  final TextEditingController _pinController = TextEditingController();
  bool _showPinEntry = false;
  bool _pinError = false;
  bool _alarmPlaying = true;
  late AnimationController _pulseController;

  Map<String, dynamic>? _overlayData;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true);

    // Listen for data from main app
    FlutterOverlayWindow.overlayListener.listen((data) {
      print('📥 Overlay received data from main app: $data');

      setState(() {
        _overlayData = data;
      });

      // Handle verification result from main app
      if (data['action'] == 'pin_verified') {
        final bool isValid = data['is_valid'] ?? false;
        print('✅ Received PIN verification result: $isValid');

        if (isValid) {
          print('✅ PIN correct - unlocking');
          _alarmService.stopAlarm();
          FlutterOverlayWindow.closeOverlay();
        } else {
          print('❌ PIN incorrect');
          setState(() {
            _pinError = true;
            _pinController.clear();
          });

          Future.delayed(Duration(seconds: 2), () {
            if (mounted) {
              setState(() => _pinError = false);
            }
          });
        }
      } else if (data['action'] == 'time_added') {
        final bool isValid = data['is_valid'] ?? false;
        print('⏰ Received add time verification result: $isValid');

        if (isValid) {
          print('✅ Time added successfully');
          _alarmService.stopAlarm();
          FlutterOverlayWindow.closeOverlay();
        } else {
          print('❌ PIN incorrect for add time');
          setState(() {
            _pinError = true;
            _pinController.clear();
          });

          Future.delayed(Duration(seconds: 2), () {
            if (mounted) {
              setState(() => _pinError = false);
            }
          });
        }
      }
    });

    // Play alarm for 30 seconds
    _alarmService.playAlarm();

    Future.delayed(Duration(seconds: 30), () {
      if (mounted) {
        _alarmService.stopAlarm();
        setState(() {
          _alarmPlaying = false;
          _showPinEntry = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _pinController.dispose();
    _alarmService.stopAlarm();
    super.dispose();
  }

  Future<void> _verifyPin() async {
    final pin = _pinController.text;

    print('🔐 Attempting to verify PIN: ${pin.length} digits');

    if (pin.length != 4) {
      print('❌ PIN length invalid');
      setState(() => _pinError = true);
      return;
    }

    setState(() => _pinError = false);

    try {
      // Send PIN to main app for verification
      // The overlay isolate can't access SharedPreferences/Firebase directly
      print('📤 Sending PIN to main app for verification');
      FlutterOverlayWindow.shareData({'action': 'verify_pin', 'pin': pin});

      // Wait for response from main app
      // The main app will send back verification result via overlayListener
      print('⏳ Waiting for verification result from main app...');
    } catch (e) {
      print('❌ PIN verification error: $e');
      setState(() {
        _pinError = true;
        _pinController.clear();
      });
    }
  }

  Future<void> _addExtraTime() async {
    final pin = _pinController.text;

    print('⏰ Attempting to add extra time with PIN: ${pin.length} digits');

    if (pin.length != 4) {
      setState(() => _pinError = true);
      return;
    }

    setState(() => _pinError = false);

    try {
      // Send PIN to main app for verification and adding time
      print('📤 Sending PIN to main app for add time verification');
      FlutterOverlayWindow.shareData({
        'action': 'verify_pin_add_time',
        'pin': pin,
        'minutes': 15,
      });

      print('⏳ Waiting for verification result from main app...');
    } catch (e) {
      print('❌ Add time error: $e');
      setState(() {
        _pinError = true;
        _pinController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.red.shade900,
              Colors.red.shade700,
              Colors.red.shade900,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: _alarmPlaying ? _buildAlarmScreen() : _buildPinEntryScreen(),
          ),
        ),
      ),
    );
  }

  Widget _buildAlarmScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ScaleTransition(
          scale: Tween(begin: 1.0, end: 1.2).animate(_pulseController),
          child: Icon(Icons.alarm, size: 120, color: Colors.white),
        ),

        SizedBox(height: 40),

        Text(
          '⏰ SCREEN TIME IS OVER!',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2,
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: 20),

        Text(
          'Time to take a break!',
          style: TextStyle(fontSize: 24, color: Colors.white70),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: 40),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.volume_up, color: Colors.white, size: 32),
            SizedBox(width: 10),
            Text(
              'ALARM PLAYING',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPinEntryScreen() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline, size: 80, color: Colors.white),

          SizedBox(height: 30),

          Text(
            '🔒 Phone Locked',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          SizedBox(height: 15),

          Text(
            'Screen time is over.\nAsk a parent to unlock.',
            style: TextStyle(fontSize: 18, color: Colors.white70),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 50),

          Text(
            'Enter Parent PIN',
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 20),

          Container(
            width: 200,
            child: TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                letterSpacing: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor: _pinError ? Colors.red.shade800 : Colors.white24,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                hintText: '••••',
                hintStyle: TextStyle(color: Colors.white38),
              ),
              onChanged: (value) {
                if (value.length == 4) {
                  _verifyPin();
                }
              },
            ),
          ),

          if (_pinError) ...[
            SizedBox(height: 10),
            Text(
              '❌ Incorrect PIN',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],

          SizedBox(height: 40),

          Column(
            children: [
              ElevatedButton.icon(
                onPressed: _verifyPin,
                icon: Icon(Icons.lock_open),
                label: Text('UNLOCK PHONE'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.red.shade900,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                ),
              ),

              SizedBox(height: 15),

              OutlinedButton.icon(
                onPressed: _addExtraTime,
                icon: Icon(Icons.add_alarm),
                label: Text('ADD 15 MINUTES'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white, width: 2),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
