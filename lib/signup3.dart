import 'package:flutter/material.dart';
import 'signup4.dart';
import 'user_model.dart';

const Color kPrimaryColor = Color(0xFF2E9D8A);
const Color kBackgroundColor = Color(0xFFF5F5DC);

class Signup3Page extends StatefulWidget {
  final UserProfile userProfile;

  const Signup3Page({super.key, required this.userProfile});

  @override
  State<Signup3Page> createState() => _Signup3PageState();
}

class _Signup3PageState extends State<Signup3Page> {
  double _screenTime = 2.0; // Default value
  String? _errorText;

  void _validate(double value) {
    setState(() {
      if (value < 0.5) {
        _errorText = "Screen time must be at least 0.5 hours";
      } else if (value > 12.0) {
        _errorText = "Screen time cannot exceed 12 hours";
      } else {
        _errorText = null; // Valid
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _validate(_screenTime); // Initial validation
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.timer, size: 60, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // Title
              const Text(
                'Set Your Daily Screen Time Limit',
                style: TextStyle(
                  color: kPrimaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),

              const SizedBox(height: 24),

              // Current Value
              Text(
                '${_screenTime.toStringAsFixed(1)} hours',
                style: const TextStyle(
                  color: kPrimaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
                textAlign: TextAlign.center,
              ),

              // Error Message
              if (_errorText != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _errorText!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Slider
              Slider(
                value: _screenTime,
                min: 0.5,
                max: 12.0,
                divisions: 23,
                label: '${_screenTime.toStringAsFixed(1)} h',
                activeColor: kPrimaryColor,
                onChanged: (value) {
                  setState(() {
                    _screenTime = value;
                  });
                  _validate(value); // Real-time validation
                },
              ),

              const Spacer(),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: kPrimaryColor, width: 2),
                          foregroundColor: kPrimaryColor,
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Back'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        onPressed: _errorText != null
                            ? null // Disabled if invalid
                            : () {
                                UserProfile updatedProfile = widget.userProfile.copyWith(
                                  screenTimeLimit: _screenTime,
                                );
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        Signup4Page(userProfile: updatedProfile),
                                  ),
                                );
                              },
                        child: const Text('Next'),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
