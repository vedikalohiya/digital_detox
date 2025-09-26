import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'signup2.dart';
import 'user_model.dart';

const Color kPrimaryColor = Color(0xFF2E9D8A);
const Color kBackgroundColor = Color(0xFFF5F5DC); // Light beige

class Signup1Page extends StatefulWidget {
  final UserProfile userProfile;

  const Signup1Page({super.key, required this.userProfile});

  @override
  State<Signup1Page> createState() => _Signup1PageState();
}

class _Signup1PageState extends State<Signup1Page> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  int? _age;

  String? emailError;
  String? dobError;

  // ✅ Email validation
  bool isValidEmail(String e) =>
      RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(e.trim());

  // ✅ DOB validation: must be in past and at least 13 years
  bool isValidDOB(DateTime dob) {
    final today = DateTime.now();
    int age = _calculateAge(dob);
    return dob.isBefore(today) && age >= 13;
  }

  void _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: kPrimaryColor,
              onPrimary: Colors.white,
              onSurface: kPrimaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      setState(() {
        _age = _calculateAge(picked);
        dobError = isValidDOB(picked) ? null : "You must be at least 13 years old";
      });
    }
  }

  int _calculateAge(DateTime dob) {
    final today = DateTime.now();
    int age = today.year - dob.year;
    if (today.month < dob.month ||
        (today.month == dob.month && today.day < dob.day)) {
      age--;
    }
    return age;
  }

  void validate() {
    setState(() {
      // Email validation
      emailError = _emailController.text.trim().isEmpty
          ? 'Email is required'
          : (!isValidEmail(_emailController.text)
              ? 'Enter a valid email'
              : null);

      // DOB validation
      if (_dobController.text.trim().isEmpty) {
        dobError = 'Date of birth is required';
      }
    });
  }

  void handleNext() {
    validate();
    if (emailError == null && dobError == null) {
      UserProfile updatedProfile = widget.userProfile.copyWith(
        email: _emailController.text.trim(),
        dateOfBirth: _dobController.text.trim(),
        age: _age ?? 0,
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Signup2Page(userProfile: updatedProfile),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fix errors before proceeding')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // Real-time validation listeners
    _emailController.addListener(() {
      if (emailError != null) validate();
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

              // Email field
              TextField(
                controller: _emailController,
                style: const TextStyle(
                  color: kPrimaryColor,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  labelText: 'Email ID',
                  labelStyle: const TextStyle(
                    color: kPrimaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                  border: const OutlineInputBorder(),
                  errorText: emailError,
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 24),

              // DOB field
              TextField(
                controller: _dobController,
                readOnly: true,
                style: const TextStyle(
                  color: kPrimaryColor,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  labelText: 'Date of Birth',
                  labelStyle: const TextStyle(
                    color: kPrimaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                  border: const OutlineInputBorder(),
                  suffixIcon:
                      const Icon(Icons.calendar_today, color: kPrimaryColor),
                  errorText: dobError,
                ),
                onTap: _pickDate,
              ),
              const SizedBox(height: 12),

              // Age display
              if (_age != null)
                Text(
                  '${_age!} years',
                  style: const TextStyle(
                    color: kPrimaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.left,
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
                        onPressed: handleNext,
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
