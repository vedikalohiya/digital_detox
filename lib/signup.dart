import 'package:flutter/material.dart';
import 'signup1.dart'; // Next signup step
import 'user_model.dart';

const Color kPrimaryColor = Color(0xFF2E9D8A);
const Color kBackgroundColor = Color(0xFFF5F5DC);

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String? nameError;
  String? phoneError;

  // ✅ Validations
  bool isValidName(String name) =>
      RegExp(r"^[A-Za-z]+(?: [A-Za-z]+)+$").hasMatch(name.trim());

  bool isValidPhone(String phone) =>
      RegExp(r'^[0-9]{10}$').hasMatch(phone.trim());

  void validate() {
    setState(() {
      // Full Name validation
      nameError = _nameController.text.trim().isEmpty
          ? 'Full name is required'
          : (!isValidName(_nameController.text)
              ? 'Enter first and last name (alphabets only)'
              : null);

      // Phone validation
      phoneError = _phoneController.text.trim().isEmpty
          ? 'Phone number is required'
          : (!isValidPhone(_phoneController.text)
              ? 'Enter a valid 10-digit number'
              : null);
    });
  }

  void handleNext() {
    validate();
    if (nameError == null && phoneError == null) {
      UserProfile userProfile = UserProfile(
        fullName: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        email: '',
        dateOfBirth: '',
        age: 0,
        gender: '',
        screenTimeLimit: 2.0,
        password: '',
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Signup1Page(userProfile: userProfile),
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
    // Revalidate while typing
    _nameController.addListener(() {
      if (nameError != null) validate();
    });
    _phoneController.addListener(() {
      if (phoneError != null) validate();
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

              // Name field
              TextField(
                controller: _nameController,
                style: const TextStyle(
                    color: kPrimaryColor, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  labelStyle: const TextStyle(
                      color: kPrimaryColor, fontWeight: FontWeight.bold),
                  border: const OutlineInputBorder(),
                  errorText: nameError,
                ),
              ),
              const SizedBox(height: 24),

              // Phone field
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(
                    color: kPrimaryColor, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  labelStyle: const TextStyle(
                      color: kPrimaryColor, fontWeight: FontWeight.bold),
                  border: const OutlineInputBorder(),
                  errorText: phoneError,
                ),
              ),
              const Spacer(),

              // Next Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    textStyle: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  onPressed: handleNext,
                  child: const Text('Next',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
