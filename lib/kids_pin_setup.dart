import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'parent_pin_service.dart';
import 'kids_timer_selection.dart';

/// PIN Setup Screen for Kids Mode
/// Handles PIN creation and verification
class KidsPinSetup extends StatefulWidget {
  final bool skipToTimer;

  const KidsPinSetup({Key? key, this.skipToTimer = false}) : super(key: key);

  @override
  State<KidsPinSetup> createState() => _KidsPinSetupState();
}

class _KidsPinSetupState extends State<KidsPinSetup> {
  final ParentPinService _pinService = ParentPinService();
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  bool _isPinAlreadySet = false;

  @override
  void initState() {
    super.initState();
    _checkPinStatus();
  }

  Future<void> _checkPinStatus() async {
    final isPinSet = await _pinService.isPinSet();
    setState(() {
      _isPinAlreadySet = isPinSet;
    });

    // If PIN is already set and skipToTimer is true, go directly to timer
    if (isPinSet && widget.skipToTimer && mounted) {
      _navigateToTimerSelection();
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _handlePinSubmit() async {
    final pin = _pinController.text;
    final confirmPin = _confirmPinController.text;

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    // Validate PIN format
    if (pin.length != 4) {
      setState(() {
        _errorMessage = 'PIN must be exactly 4 digits';
        _isLoading = false;
      });
      return;
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(pin)) {
      setState(() {
        _errorMessage = 'PIN must contain only numbers';
        _isLoading = false;
      });
      return;
    }

    if (_isPinAlreadySet) {
      // Verify existing PIN
      final isCorrect = await _pinService.verifyPin(pin);

      if (!isCorrect) {
        setState(() {
          _errorMessage = 'Incorrect PIN. Please try again.';
          _isLoading = false;
        });
        _pinController.clear();
        return;
      }

      // PIN verified - proceed to timer
      setState(() {
        _isLoading = false;
      });

      _navigateToTimerSelection();
    } else {
      // Create new PIN - check confirmation matches
      if (pin != confirmPin) {
        setState(() {
          _errorMessage = 'PINs do not match';
          _isLoading = false;
        });
        return;
      }

      // Save new PIN
      final success = await _pinService.setPin(pin);

      if (success) {
        setState(() {
          _isLoading = false;
        });

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✓ PIN created successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }

        // Wait a moment then navigate to timer
        await Future.delayed(Duration(milliseconds: 500));
        _navigateToTimerSelection();
      } else {
        setState(() {
          _errorMessage = 'Failed to save PIN. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToTimerSelection() {
    if (mounted) {
      Navigator.of(context).pushReplacement(
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
              Colors.purple.shade400,
              Colors.deepPurple.shade500,
              Colors.indigo.shade600,
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
                        '🔐 Parent PIN',
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

                SizedBox(height: 60),

                // PIN Setup Card
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon and title
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
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
                                Icons.lock_outline,
                                size: 45,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 20),
                            Text(
                              _isPinAlreadySet
                                  ? 'Enter Your PIN'
                                  : 'Create Secure PIN',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple.shade700,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              _isPinAlreadySet
                                  ? 'Enter your PIN to continue'
                                  : 'You\'ll need this to unlock the device',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 40),

                      // PIN input
                      Text(
                        _isPinAlreadySet ? 'PIN' : 'Enter PIN',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: _pinController,
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        obscureText: true,
                        textAlign: TextAlign.center,
                        autofocus: true,
                        style: TextStyle(
                          fontSize: 32,
                          letterSpacing: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          hintText: '••••',
                          counterText: '',
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 20),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),

                      // Confirm PIN (only for new PIN)
                      if (!_isPinAlreadySet) ...[
                        SizedBox(height: 25),
                        Text(
                          'Confirm PIN',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        SizedBox(height: 10),
                        TextField(
                          controller: _confirmPinController,
                          keyboardType: TextInputType.number,
                          maxLength: 4,
                          obscureText: true,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 32,
                            letterSpacing: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            hintText: '••••',
                            counterText: '',
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(vertical: 20),
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                      ],

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
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Warning message (only for new PIN)
                      if (!_isPinAlreadySet) ...[
                        SizedBox(height: 20),
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.orange.shade200),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.warning_amber,
                                color: Colors.orange,
                                size: 20,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Keep this PIN safe! You\'ll need it to unlock the device when timer expires.',
                                  style: TextStyle(
                                    color: Colors.orange.shade900,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      SizedBox(height: 30),

                      // Submit button
                      if (_isLoading)
                        Center(
                          child: CircularProgressIndicator(
                            color: Colors.purple,
                          ),
                        )
                      else
                        ElevatedButton(
                          onPressed: _handlePinSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple.shade600,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 3,
                          ),
                          child: Text(
                            _isPinAlreadySet ? 'VERIFY PIN' : 'CREATE PIN',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
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
    );
  }
}
