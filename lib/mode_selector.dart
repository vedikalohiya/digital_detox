import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard.dart';
import 'kids_mode_setup.dart';
import 'parent_pin_service.dart';

/// Mode selector screen - first screen shown on app launch
/// Allows user to choose between Adult Mode or Kids Mode
class ModeSelector extends StatefulWidget {
  const ModeSelector({Key? key}) : super(key: key);

  @override
  State<ModeSelector> createState() => _ModeSelectorState();
}

class _ModeSelectorState extends State<ModeSelector>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  final ParentPinService _pinService = ParentPinService();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _selectAdultMode() async {
    // Save mode selection
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('mode_selected', true);
    await prefs.setString('selected_mode', 'adult');

    // Navigate to adult dashboard
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (context) => DashboardPage()));
  }

  Future<void> _selectKidsMode() async {
    // Save mode selection
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('mode_selected', true);
    await prefs.setString('selected_mode', 'kids');

    // Check if parent PIN is set
    final isPinSet = await _pinService.isPinSet();

    if (!isPinSet) {
      // First time using Kids Mode - parent must set PIN
      _showFirstTimeSetup();
    } else {
      // PIN already set - go to Kids Mode setup (set timer)
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => KidsModeSetup()),
      );
    }
  }

  void _showFirstTimeSetup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.security, color: Colors.orange),
            SizedBox(width: 10),
            Text('Parent Setup Required'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'First time using Kids Mode?',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'Parents must create a PIN code to:\n'
              '• Set screen time limits\n'
              '• Unlock the device when time expires\n'
              '• Protect settings from changes',
            ),
            SizedBox(height: 15),
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.orange),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Keep your PIN safe! It cannot be recovered.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => KidsModeSetup()),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            child: Text('Continue'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2E9D8A), Color(0xFF1A7A6A)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 40),

              // App logo/title
              Text(
                '📱 Digital Detox',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              SizedBox(height: 10),

              Text(
                'Choose Your Mode',
                style: TextStyle(fontSize: 20, color: Colors.white70),
              ),

              Spacer(),

              // Mode selection cards
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Adult Mode Circle
                    _buildModeCircle(
                      title: 'Adult Mode',
                      icon: Icons.person,
                      gradient: [Color(0xFF2E9D8A), Color(0xFF1A7A6A)],
                      onTap: _selectAdultMode,
                    ),

                    // Kids Mode Circle
                    _buildModeCircle(
                      title: 'Kids Mode',
                      icon: Icons.child_care,
                      gradient: [Color(0xFFFF9800), Color(0xFFE68900)],
                      onTap: _selectKidsMode,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 40),

              // Feature descriptions
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    Text(
                      'Adult Mode: Full access to all features, track usage, mental health tools',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 15),
                    Text(
                      'Kids Mode: Parental controls, screen time limits, automatic blocking',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              Spacer(),

              // Info text
              Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'You can switch modes anytime from settings',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeCircle({
    required String title,
    required IconData icon,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          // Circular button with gradient
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradient,
              ),
              boxShadow: [
                BoxShadow(
                  color: gradient[0].withOpacity(0.5),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Icon(icon, size: 70, color: Colors.white),
          ),

          SizedBox(height: 20),

          // Title
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
