import 'package:flutter/material.dart';
import 'kids_timer_active.dart';
import 'kids_mode_service.dart';
import 'kids_overlay_service.dart';
import 'package:permission_handler/permission_handler.dart';

class KidsTimerSelection extends StatefulWidget {
  const KidsTimerSelection({Key? key}) : super(key: key);

  @override
  State<KidsTimerSelection> createState() => _KidsTimerSelectionState();
}

class _KidsTimerSelectionState extends State<KidsTimerSelection> {
  final KidsModeService _kidsModeService = KidsModeService();
  final KidsOverlayService _overlayService = KidsOverlayService();

  // Timer duration in minutes (2 min to 300 min = 5 hours)
  int _selectedMinutes = 30;
  bool _isStarting = false;
  String? _errorMessage;

  // Quick select options in minutes
  final List<int> _quickOptions = [2, 5, 10, 15, 30, 45, 60, 90, 120];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple.shade300,
              Colors.deepPurple.shade400,
              Colors.indigo.shade500,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    Expanded(
                      child: Text(
                        '⏱️ Set Timer',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(width: 48),
                  ],
                ),

                SizedBox(height: 40),

                // Timer Selection Card
                Container(
                  padding: EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Timer Icon
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.purple.shade400,
                              Colors.deepPurple.shade600,
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.timer, size: 60, color: Colors.white),
                      ),

                      SizedBox(height: 30),

                      // Title
                      Text(
                        'Screen Time Duration',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple.shade700,
                        ),
                      ),

                      SizedBox(height: 8),

                      Text(
                        'Choose how long your child can use the device',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: 40),

                      // Large time display
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 20,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.purple.shade50,
                              Colors.purple.shade100,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  _getDisplayTime(),
                                  style: TextStyle(
                                    fontSize: 72,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.purple.shade700,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  _getDisplayUnit(),
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.purple.shade600,
                                  ),
                                ),
                              ],
                            ),
                            if (_selectedMinutes >= 60) ...[
                              SizedBox(height: 5),
                              Text(
                                '($_selectedMinutes minutes)',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.purple.shade400,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      SizedBox(height: 35),

                      // Slider
                      Column(
                        children: [
                          Slider(
                            value: _selectedMinutes.toDouble(),
                            min: 2,
                            max: 300,
                            divisions: 298,
                            activeColor: Colors.purple.shade600,
                            inactiveColor: Colors.purple.shade100,
                            label: _selectedMinutes >= 60
                                ? '${(_selectedMinutes / 60).toStringAsFixed(1)}h'
                                : '$_selectedMinutes min',
                            onChanged: (value) {
                              setState(() {
                                _selectedMinutes = value.toInt();
                              });
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '2 min',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                Text(
                                  '5 hours',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 30),

                      // Quick select buttons
                      Text(
                        'Quick Select',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      SizedBox(height: 15),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        alignment: WrapAlignment.center,
                        children: _quickOptions.map((minutes) {
                          final isSelected = _selectedMinutes == minutes;
                          return InkWell(
                            onTap: () {
                              setState(() {
                                _selectedMinutes = minutes;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? LinearGradient(
                                        colors: [
                                          Colors.purple.shade400,
                                          Colors.deepPurple.shade600,
                                        ],
                                      )
                                    : null,
                                color: isSelected
                                    ? null
                                    : Colors.purple.shade50,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.purple.shade600
                                      : Colors.purple.shade200,
                                  width: 2,
                                ),
                              ),
                              child: Text(
                                minutes >= 60
                                    ? '${(minutes / 60).toStringAsFixed(minutes % 60 == 0 ? 0 : 1)}h'
                                    : '$minutes min',
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.purple.shade700,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      // Error message
                      if (_errorMessage != null) ...[
                        SizedBox(height: 20),
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error, color: Colors.red, size: 20),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: TextStyle(
                                    color: Colors.red.shade900,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      SizedBox(height: 30),

                      // Start button
                      if (_isStarting)
                        Center(
                          child: Column(
                            children: [
                              CircularProgressIndicator(color: Colors.purple),
                              SizedBox(height: 10),
                              Text(
                                'Starting timer...',
                                style: TextStyle(
                                  color: Colors.purple.shade600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ElevatedButton.icon(
                          onPressed: _startTimer,
                          icon: Icon(Icons.play_arrow, size: 28),
                          label: Text(
                            'START TIMER',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple.shade600,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 18,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 5,
                          ),
                        ),
                    ],
                  ),
                ),

                SizedBox(height: 20),

                // Info box
                Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, color: Colors.white, size: 24),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'What happens when timer expires?',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              '• Device will be locked with a full-screen overlay\n'
                              '• Loud alarm will sound\n'
                              '• Parent PIN required to unlock\n'
                              '• Works even if app is closed or device is locked',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 12,
                                height: 1.5,
                              ),
                            ),
                          ],
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
    );
  }

  String _getDisplayTime() {
    if (_selectedMinutes < 60) {
      return _selectedMinutes.toString();
    } else {
      final hours = _selectedMinutes / 60;
      if (_selectedMinutes % 60 == 0) {
        return hours.toInt().toString();
      } else {
        return hours.toStringAsFixed(1);
      }
    }
  }

  String _getDisplayUnit() {
    return _selectedMinutes < 60 ? 'min' : 'hours';
  }

  Future<void> _startTimer() async {
    setState(() {
      _isStarting = true;
      _errorMessage = null;
    });

    try {
      // Request permissions first
      final permissionsGranted = await _requestPermissions();

      if (!permissionsGranted) {
        setState(() {
          _errorMessage =
              'Required permissions not granted. Please enable overlay and alarm permissions.';
          _isStarting = false;
        });
        return;
      }

      // Start Kids Mode
      final success = await _kidsModeService.startKidsMode(_selectedMinutes);

      if (success) {
        // Navigate to active timer screen
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const KidsTimerActive()),
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to start timer. Please try again.';
          _isStarting = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _isStarting = false;
      });
    }
  }

  Future<bool> _requestPermissions() async {
    bool allGranted = true;

    // Request overlay permission (required for blocking screen)
    final hasOverlayPermission = await _overlayService.hasOverlayPermission();

    if (!hasOverlayPermission) {
      print('📱 Requesting overlay permission...');
      final overlayGranted = await _overlayService.requestOverlayPermission();

      if (!overlayGranted) {
        print('❌ Overlay permission denied');
        allGranted = false;

        // Show dialog explaining why permission is needed
        if (mounted) {
          await _showPermissionDialog(
            'Overlay Permission Required',
            'Kids Mode needs permission to display over other apps to show the lock screen when timer expires. '
                'Please enable "Display over other apps" in settings.',
          );
        }
      }
    }

    // Request notification permission (for alarm)
    final notificationStatus = await Permission.notification.status;
    if (!notificationStatus.isGranted) {
      print('📱 Requesting notification permission...');
      final notificationGranted = await Permission.notification.request();

      if (!notificationGranted.isGranted) {
        print('⚠️ Notification permission denied');
        // Not critical, but helpful
      }
    }

    // Request exact alarm permission (Android 12+)
    if (await Permission.scheduleExactAlarm.isDenied) {
      print('📱 Requesting exact alarm permission...');
      final alarmStatus = await Permission.scheduleExactAlarm.request();

      if (!alarmStatus.isGranted) {
        print('⚠️ Exact alarm permission denied');
        // Not critical for basic functionality
      }
    }

    return allGranted;
  }

  Future<void> _showPermissionDialog(String title, String message) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange),
            SizedBox(width: 10),
            Expanded(child: Text(title)),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              // Try requesting permission again
              await _overlayService.requestOverlayPermission();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            child: Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}
