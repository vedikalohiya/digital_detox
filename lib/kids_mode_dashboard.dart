import 'package:flutter/material.dart';
import 'kids_pin_setup.dart';
import 'kids_timer_selection.dart';
import 'parent_pin_service.dart';

/// Main Kids Mode Dashboard
/// Shows a single prominent container for setting timer
class KidsModeDashboard extends StatefulWidget {
  const KidsModeDashboard({Key? key}) : super(key: key);

  @override
  State<KidsModeDashboard> createState() => _KidsModeDashboardState();
}

class _KidsModeDashboardState extends State<KidsModeDashboard> {
  final ParentPinService _pinService = ParentPinService();
  bool _isLoading = true;
  bool _isPinSet = false;

  @override
  void initState() {
    super.initState();
    _checkPinStatus();
  }

  Future<void> _checkPinStatus() async {
    final isPinSet = await _pinService.isPinSet();
    setState(() {
      _isPinSet = isPinSet;
      _isLoading = false;
    });
  }

  void _onSetTimerTapped() {
    if (!_isPinSet) {
      // Navigate to PIN setup first
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => const KidsPinSetup()))
          .then((_) {
            // Refresh PIN status after returning
            _checkPinStatus();
          });
    } else {
      // PIN already set - go directly to timer selection
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const KidsTimerSelection()),
      );
    }
  }

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
          child: _isLoading
              ? Center(child: CircularProgressIndicator(color: Colors.white))
              : Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          Expanded(
                            child: Text(
                              '👶 Kids Mode',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(width: 48), // Balance back button
                        ],
                      ),
                    ),

                    // Main Content
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Welcome message
                              Text(
                                'Welcome to Kids Mode!',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Set a timer to manage screen time',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                                textAlign: TextAlign.center,
                              ),

                              SizedBox(height: 60),

                              // Single prominent timer container
                              GestureDetector(
                                onTap: _onSetTimerTapped,
                                child: Container(
                                  width: double.infinity,
                                  height: 280,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(30),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 30,
                                        spreadRadius: 5,
                                        offset: Offset(0, 15),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: _onSetTimerTapped,
                                      borderRadius: BorderRadius.circular(30),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          // Timer icon/animation
                                          Container(
                                            width: 120,
                                            height: 120,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.purple.shade400,
                                                  Colors.deepPurple.shade600,
                                                ],
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.timer,
                                              size: 70,
                                              color: Colors.white,
                                            ),
                                          ),

                                          SizedBox(height: 25),

                                          // Action text
                                          Text(
                                            'Set timer for your child',
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.purple.shade700,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),

                                          SizedBox(height: 10),

                                          // Subtitle
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                            ),
                                            child: Text(
                                              _isPinSet
                                                  ? 'Tap to choose screen time duration'
                                                  : 'Tap to set up parental controls',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey.shade600,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(height: 40),

                              // Info text
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
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        _isPinSet
                                            ? 'When the timer expires, the device will be locked with an alarm'
                                            : 'You\'ll need to create a secure PIN before setting a timer',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
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
                  ],
                ),
        ),
      ),
    );
  }
}
