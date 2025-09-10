import 'package:flutter/material.dart';

const Color kPrimaryColor = Color(0xFF2E9D8A);
const Color kBackgroundColor = Color(0xFFF5F5DC); // Light beige

class SignupPage extends StatelessWidget {
  const SignupPage({Key? key}) : super(key: key);

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
              // Logo placeholder
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
              // Full Name field
              TextField(
                style: const TextStyle(
                  color: kPrimaryColor,
                  fontWeight: FontWeight.bold,
                ),
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  labelStyle: TextStyle(
                    color: kPrimaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              // Phone Number field
              TextField(
                keyboardType: TextInputType.phone,
                style: const TextStyle(
                  color: kPrimaryColor,
                  fontWeight: FontWeight.bold,
                ),
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  labelStyle: TextStyle(
                    color: kPrimaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                  border: OutlineInputBorder(),
                ),
              ),
              const Spacer(),
              // Next button
              SizedBox(
                width: double.infinity,
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
                    // TODO: Implement next action
                  },
                  child: const Text(
                    'Next',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
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
