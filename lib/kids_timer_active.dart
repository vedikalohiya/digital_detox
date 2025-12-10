import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'kids_mode_service.dart';
import 'kids_blocking_screen.dart';

/// Active Timer Screen
/// Shows running timer while Kids Mode is active
class KidsTimerActive extends StatefulWidget {
  const KidsTimerActive({Key? key}) : super(key: key);

  @override
  State<KidsTimerActive> createState() => _KidsTimerActiveState();
}

class _KidsTimerActiveState extends State<KidsTimerActive>
    with TickerProviderStateMixin {
  final KidsModeService _kidsModeService = KidsModeService();
  late AnimationController _pulseController;
  Timer? _checkTimer;

  @override
  void initState() {
    super.initState();

    // Initialize animation
    _pulseController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true);

    // Initialize Kids Mode service
    _kidsModeService.initialize();

    // Listen for timer expiry
    _kidsModeService.onTimerExpired = _handleTimerExpired;

    // Listen for state changes
    _kidsModeService.addListener(_onKidsModeUpdate);

    // Periodically check if timer expired (backup mechanism)
    _checkTimer = Timer.periodic(Duration(seconds: 5), (_) {
      if (_kidsModeService.isExpired) {
        _handleTimerExpired();
      }
    });

    // Prevent going back
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }

  void _onKidsModeUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  void _handleTimerExpired() {
    if (mounted) {
      _checkTimer?.cancel();
      // Navigate to blocking screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => KidsBlockingScreen(),
          fullscreenDialog: true,
        ),
      );
    }
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    _pulseController.dispose();
    _kidsModeService.removeListener(_onKidsModeUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remainingSeconds = _kidsModeService.remainingSeconds;
    final hours = remainingSeconds ~/ 3600;
    final minutes = (remainingSeconds % 3600) ~/ 60;
    final seconds = remainingSeconds % 60;

    final progress = remainingSeconds / (_kidsModeService.totalMinutes * 60);

    return WillPopScope(
      onWillPop: () async {
        // Prevent back navigation
        _showCannotExitDialog();
        return false;
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.green.shade300,
                Colors.teal.shade400,
                Colors.cyan.shade500,
              ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Title
                    Text(
                      '⏱️ Timer Active',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    SizedBox(height: 10),

                    Text(
                      'Enjoy your screen time!',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),

                    SizedBox(height: 60),

                    // Circular timer
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Progress circle
                        SizedBox(
                          width: 280,
                          height: 280,
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 15,
                            backgroundColor: Colors.white.withOpacity(0.3),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),

                        // Time display
                        ScaleTransition(
                          scale: Tween<double>(
                            begin: 1.0,
                            end: 1.05,
                          ).animate(_pulseController),
                          child: Container(
                            width: 240,
                            height: 240,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Time Left',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    hours > 0
                                        ? '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}'
                                        : '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                                    style: TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal.shade700,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    hours > 0 ? 'HH:MM:SS' : 'MM:SS',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 60),

                    // Info container
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.lock_clock,
                                color: Colors.white,
                                size: 24,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Device will lock when timer ends',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 15),
                          Text(
                            'The screen will be locked with an alarm. '
                            'A parent must enter the PIN to unlock.',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 30),

                    // Warning about exit
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'You can minimize the app, but the timer will keep running',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showCannotExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.lock, color: Colors.orange),
            SizedBox(width: 10),
            Text('Timer is Running'),
          ],
        ),
        content: Text(
          'You cannot exit Kids Mode while the timer is active. '
          'The device will be locked when the timer expires.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
