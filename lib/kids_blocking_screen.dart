import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'parent_pin_service.dart';
import 'kids_mode_service.dart';
import 'kids_alarm_service.dart';
import 'mode_selector.dart';

/// Full-screen blocking screen shown when timer expires
/// Plays alarm and requires PIN to unlock
class KidsBlockingScreen extends StatefulWidget {
  const KidsBlockingScreen({Key? key}) : super(key: key);

  @override
  State<KidsBlockingScreen> createState() => _KidsBlockingScreenState();
}

class _KidsBlockingScreenState extends State<KidsBlockingScreen>
    with TickerProviderStateMixin {
  final ParentPinService _pinService = ParentPinService();
  final KidsModeService _kidsModeService = KidsModeService();
  final KidsAlarmService _alarmService = KidsAlarmService();
  final TextEditingController _pinController = TextEditingController();

  bool _pinError = false;
  bool _alarmPlaying = true;
  bool _isUnlocking = false;

  late AnimationController _pulseController;
  late AnimationController _flashController;

  @override
  void initState() {
    super.initState();

    // Start alarm immediately
    _startAlarm();

    // Setup animations
    _pulseController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true);

    _flashController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    )..repeat(reverse: true);

    // After 8 seconds, slow down flash and reduce alarm prominence
    Future.delayed(Duration(seconds: 8), () {
      if (mounted) {
        _flashController.duration = Duration(milliseconds: 800);
        setState(() {
          _alarmPlaying = false;
        });
      }
    });

    // Prevent system back button
    SystemChannels.platform.setMethodCallHandler((call) async {
      if (call.method == 'SystemNavigator.pop') {
        // Block back button
        return;
      }
    });
  }

  Future<void> _startAlarm() async {
    try {
      await _alarmService.playAlarm();
      print('🔔 Alarm started successfully');
    } catch (e) {
      print('❌ Error starting alarm: $e');
    }
  }

  @override
  void dispose() {
    _alarmService.stopAlarm();
    _pulseController.dispose();
    _flashController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _verifyPin() async {
    final pin = _pinController.text;

    if (pin.length != 4) {
      setState(() {
        _pinError = true;
      });
      return;
    }

    setState(() {
      _pinError = false;
      _isUnlocking = true;
    });

    try {
      print('🔐 Verifying PIN...');
      final isCorrect = await _pinService.verifyPin(pin);

      if (isCorrect) {
        print('✅ PIN verified! Stopping Kids Mode...');

        // Stop alarm
        await _alarmService.stopAlarm();

        // Stop Kids Mode
        await _kidsModeService.stopKidsMode();

        // Navigate back to mode selector
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => ModeSelector()),
            (route) => false,
          );
        }
      } else {
        print('❌ PIN verification failed');
        setState(() {
          _pinError = true;
          _isUnlocking = false;
        });
        _pinController.clear();

        // Shake animation or haptic feedback
        HapticFeedback.vibrate();

        // Reset error after 2 seconds
        Future.delayed(Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _pinError = false;
            });
          }
        });
      }
    } catch (e) {
      print('❌ Error during PIN verification: $e');
      setState(() {
        _pinError = true;
        _isUnlocking = false;
      });
      _pinController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Prevent back navigation
      child: Scaffold(
        body: AnimatedBuilder(
          animation: _flashController,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.lerp(
                      Colors.red.shade900,
                      Colors.red.shade700,
                      _flashController.value,
                    )!.withOpacity(0.95),
                    Color.lerp(
                      Colors.black87,
                      Colors.red.shade900,
                      _flashController.value,
                    )!.withOpacity(0.95),
                  ],
                ),
              ),
              child: SafeArea(
                child: Center(
                  child: _alarmPlaying
                      ? _buildAlarmScreen()
                      : _buildPinEntryScreen(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAlarmScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Pulsing alarm icon
        ScaleTransition(
          scale: Tween(begin: 1.0, end: 1.3).animate(_pulseController),
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.alarm, size: 100, color: Colors.white),
          ),
        ),

        SizedBox(height: 50),

        // Main message
        Text(
          '⏰ TIME\'S UP!',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 3,
            shadows: [Shadow(color: Colors.black45, blurRadius: 10)],
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: 20),

        // Secondary message
        Text(
          'Screen time is over!',
          style: TextStyle(
            fontSize: 28,
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: 50),

        // Alarm indicator
        Container(
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.volume_up, color: Colors.white, size: 32),
              SizedBox(width: 15),
              Text(
                'ALARM PLAYING',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPinEntryScreen() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Lock icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.lock_outline, size: 70, color: Colors.white),
          ),

          SizedBox(height: 40),

          // Title
          Text(
            '🔒 Device Locked',
            style: TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 15),

          // Subtitle
          Text(
            'Screen time has ended.\nAsk a parent to unlock the device.',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withOpacity(0.9),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 60),

          // PIN entry label
          Text(
            'Enter Parent PIN',
            style: TextStyle(
              fontSize: 22,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 25),

          // PIN input field
          Container(
            width: 250,
            child: TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              textAlign: TextAlign.center,
              autofocus: false,
              style: TextStyle(
                fontSize: 40,
                letterSpacing: 25,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor: _pinError
                    ? Colors.red.shade900.withOpacity(0.7)
                    : Colors.white.withOpacity(0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.white, width: 3),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.white, width: 3),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.white, width: 4),
                ),
                hintText: '••••',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 40,
                  letterSpacing: 25,
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 25),
              ),
              onChanged: (value) {
                if (value.length == 4) {
                  _verifyPin();
                }
              },
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ),

          // Error message
          if (_pinError) ...[
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.red.shade900.withOpacity(0.7),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.red.shade300, width: 2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error, color: Colors.white, size: 24),
                  SizedBox(width: 10),
                  Text(
                    '❌ Incorrect PIN',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],

          SizedBox(height: 50),

          // Unlock button
          if (_isUnlocking)
            Column(
              children: [
                CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                SizedBox(height: 15),
                Text(
                  'Unlocking...',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            )
          else
            ElevatedButton.icon(
              onPressed: _verifyPin,
              icon: Icon(Icons.lock_open, size: 28),
              label: Text(
                'UNLOCK DEVICE',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.red.shade900,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 10,
              ),
            ),

          SizedBox(height: 20),

          // Info text
          Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Text(
              'If you forgot your PIN, you may need to reinstall the app',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
