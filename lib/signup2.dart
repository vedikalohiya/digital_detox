import 'package:flutter/material.dart';
import 'signup3.dart';
import 'user_model.dart';

const Color kPrimaryColor = Color(0xFF2E9D8A);
const Color kBackgroundColor = Color(0xFFF5F5DC);

enum Gender { male, female, other, undisclosed }

class Signup2Page extends StatefulWidget {
  final UserProfile userProfile;

  const Signup2Page({super.key, required this.userProfile});

  @override
  State<Signup2Page> createState() => _Signup2PageState();
}

class _Signup2PageState extends State<Signup2Page> {
  Gender? _selectedGender;
  String? _errorText; // For real-time error message

  void _validate() {
    setState(() {
      _errorText = _selectedGender == null ? "Please select a gender" : null;
    });
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
                    child: Icon(Icons.person, size: 60, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // Title
              const Text(
                'Select Gender',
                style: TextStyle(
                  color: kPrimaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),

              // Real-time error display
              if (_errorText != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _errorText!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),

              const SizedBox(height: 24),

              // Gender Options
              ...Gender.values.map((gender) {
                String label = gender.toString().split('.').last[0].toUpperCase() +
                    gender.toString().split('.').last.substring(1);
                return RadioListTile<Gender>(
                  title: Text(
                    label,
                    style: const TextStyle(
                      color: kPrimaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  value: gender,
                  groupValue: _selectedGender,
                  activeColor: kPrimaryColor,
                  onChanged: (Gender? value) {
                    setState(() {
                      _selectedGender = value;
                    });
                    _validate(); // Re-validate instantly
                  },
                );
              }),

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
                        onPressed: _selectedGender == null
                            ? null // Disabled until valid
                            : () {
                                UserProfile updatedProfile = widget.userProfile.copyWith(
                                  gender: _selectedGender.toString().split('.').last,
                                );
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Signup3Page(userProfile: updatedProfile),
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
