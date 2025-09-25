import 'package:flutter/material.dart';
import 'signup3.dart';
import 'user_model.dart';

const Color kPrimaryColor = Color(0xFF2E9D8A);
const Color kBackgroundColor = Color(0xFFF5F5DC); // Light beige

enum Gender { male, female, other, undisclosed }

class Signup2Page extends StatefulWidget {
  final UserProfile userProfile;
  
  const Signup2Page({Key? key, required this.userProfile}) : super(key: key);

  @override
  State<Signup2Page> createState() => _Signup2PageState();
}

class _Signup2PageState extends State<Signup2Page> {
  Gender? _selectedGender;

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
              const Text(
                'Select Gender',
                style: TextStyle(
                  color: kPrimaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 24),
              RadioListTile<Gender>(
                title: const Text(
                  'Male',
                  style: TextStyle(
                    color: kPrimaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                value: Gender.male,
                groupValue: _selectedGender,
                activeColor: kPrimaryColor,
                onChanged: (Gender? value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
              ),
              RadioListTile<Gender>(
                title: const Text(
                  'Female',
                  style: TextStyle(
                    color: kPrimaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                value: Gender.female,
                groupValue: _selectedGender,
                activeColor: kPrimaryColor,
                onChanged: (Gender? value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
              ),
              RadioListTile<Gender>(
                title: const Text(
                  'Other',
                  style: TextStyle(
                    color: kPrimaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                value: Gender.other,
                groupValue: _selectedGender,
                activeColor: kPrimaryColor,
                onChanged: (Gender? value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
              ),
              RadioListTile<Gender>(
                title: const Text(
                  'Not to be disclosed',
                  style: TextStyle(
                    color: kPrimaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                value: Gender.undisclosed,
                groupValue: _selectedGender,
                activeColor: kPrimaryColor,
                onChanged: (Gender? value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: kPrimaryColor, width: 2),
                          foregroundColor: kPrimaryColor,
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
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
                        onPressed: () {
                          if (_selectedGender != null) {
                            String genderString = _selectedGender.toString().split('.').last;
                            UserProfile updatedProfile = widget.userProfile.copyWith(
                              gender: genderString,
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Signup3Page(userProfile: updatedProfile),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please select a gender')),
                            );
                          }
                        },
                        child: const Text(
                          'Next',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
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
