import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login.dart';
import 'user_model.dart';
import 'database_helper.dart';

const Color kPrimaryColor = Color(0xFF2E9D8A);
const Color kBackgroundColor = Color(0xFFF5F5DC); // Light beige

class Signup4Page extends StatefulWidget {
  final UserProfile userProfile;

  const Signup4Page({super.key, required this.userProfile});

  @override
  State<Signup4Page> createState() => _Signup4PageState();
}

class _Signup4PageState extends State<Signup4Page> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String? _passwordError;
  String? _confirmPasswordError;

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  bool _isPasswordValid = false;
  bool _isConfirmValid = false;

  // Password validation rules
  bool _validatePassword(String password) {
    final hasUpper = password.contains(RegExp(r'[A-Z]'));
    final hasLower = password.contains(RegExp(r'[a-z]'));
    final hasDigit = password.contains(RegExp(r'[0-9]'));
    final hasSpecial = password.contains(RegExp(r'[!@#\$&*~]'));

    // Block email-like passwords (e.g., test@gmail.com)
    final looksLikeEmail = password.contains('@') && password.contains('.');

    return hasUpper &&
        hasLower &&
        hasDigit &&
        hasSpecial &&
        password.length >= 8 &&
        !looksLikeEmail;
  }

  // Real-time password check
  void _onPasswordChanged(String value) {
    setState(() {
      if (_validatePassword(value)) {
        _passwordError = null;
        _isPasswordValid = true;
      } else {
        _passwordError =
            'Min 8 chars, must include upper, lower, digit & special (!@#\$&*~), not an email.';
        _isPasswordValid = false;
      }
      // Also re-check confirm password whenever password changes
      _onConfirmChanged(_confirmPasswordController.text);
    });
  }

  // Real-time confirm password check
  void _onConfirmChanged(String value) {
    setState(() {
      if (value.isEmpty) {
        _confirmPasswordError = null;
        _isConfirmValid = false;
      } else if (value != _passwordController.text) {
        _confirmPasswordError = 'Passwords do not match';
        _isConfirmValid = false;
      } else {
        _confirmPasswordError = null;
        _isConfirmValid = true;
      }
    });
  }

  Future<void> _onFinish() async {
    setState(() {
      _passwordError = null;
      _confirmPasswordError = null;
      final password = _passwordController.text;
      final confirm = _confirmPasswordController.text;
      if (!_validatePassword(password)) {
        _passwordError =
            'Password must be 8+ chars, include upper, lower, digit, special.';
      }
      if (password != confirm) {
        _confirmPasswordError = 'Passwords do not match.';
      }
    });

    if (_passwordError == null && _confirmPasswordError == null) {
      // Validate user profile data
      // Debug: User profile validation
      // All profile data validated successfully

      if (widget.userProfile.email.isEmpty ||
          widget.userProfile.fullName.isEmpty ||
          widget.userProfile.phoneNumber.isEmpty ||
          widget.userProfile.dateOfBirth.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please complete all required fields in previous steps.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      try {
        // Show loading dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  'Creating your account...',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        );

        final dbHelper = DatabaseHelper();

        try {
          // Try Firebase first (in case reCAPTCHA is fixed)
          final auth = FirebaseAuth.instance;
          UserCredential userCredential = await auth
              .createUserWithEmailAndPassword(
                email: widget.userProfile.email,
                password: _passwordController.text,
              );

          // Save to Firestore
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .set({
                'fullName': widget.userProfile.fullName,
                'phoneNumber': widget.userProfile.phoneNumber,
                'email': widget.userProfile.email,
                'dateOfBirth': widget.userProfile.dateOfBirth,
                'age': widget.userProfile.age,
                'gender': widget.userProfile.gender,
                'screenTimeLimit': widget.userProfile.screenTimeLimit,
                'createdAt': FieldValue.serverTimestamp(),
              });

          // Debug: Firebase account created successfully
        } catch (firebaseError) {
          // Debug: Firebase signup failed, using local database
          // Debug: Local database fallback initiated

          try {
            // Firebase failed, use local database
            Map<String, dynamic>? result = await dbHelper.createUser(
              email: widget.userProfile.email,
              password: _passwordController.text,
              userProfile: widget.userProfile,
            );

            if (result == null) {
              throw Exception('Database returned null result');
            }

            // Debug: Local account created successfully
          } catch (dbError) {
            // Debug: Local database creation failed
            throw Exception(
              'Both Firebase and local database failed: $dbError',
            );
          }
        }

        // Hide loading dialog
        if (mounted) Navigator.of(context).pop();

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account created successfully! You can now login.'),
              backgroundColor: kPrimaryColor,
            ),
          );

          // Navigate to LoginPage after successful signup
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        }
      } on FirebaseAuthException catch (e) {
        // Hide loading dialog
        if (mounted) Navigator.of(context).pop();

        String errorMessage;
        switch (e.code) {
          case 'weak-password':
            errorMessage = 'The password provided is too weak.';
            break;
          case 'email-already-in-use':
            errorMessage = 'An account already exists for that email.';
            break;
          case 'invalid-email':
            errorMessage = 'The email address is not valid.';
            break;
          case 'network-request-failed':
            errorMessage = 'Network error. Please check your connection.';
            break;
          case 'too-many-requests':
            errorMessage = 'Too many attempts. Please try again later.';
            break;
          case 'captcha-check-failed':
          case 'invalid-app-credential':
            errorMessage = 'Security verification failed. Please try again.';
            break;
          default:
            // Check if it's a reCAPTCHA configuration error
            if (e.message?.contains('CONFIGURATION_NOT_FOUND') == true ||
                e.message?.contains('reCAPTCHA') == true) {
              errorMessage =
                  'Account creation temporarily unavailable. Please try again.';
            } else {
              errorMessage = 'Error: ${e.message ?? "Please try again."}';
            }
          // Debug: Firebase Auth Error logged
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
          );
        }
      } catch (e) {
        // Hide loading dialog
        if (mounted) Navigator.of(context).pop();

        // Log the actual error for debugging
        // Debug: Unexpected signup error occurred
        // Debug: Stack trace logged

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Signup error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
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
                    child: Icon(Icons.lock, size: 60, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // Password Field
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: const TextStyle(
                  color: kPrimaryColor,
                  fontWeight: FontWeight.bold,
                ),
                onChanged: _onPasswordChanged,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: const TextStyle(
                    color: kPrimaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                  border: const OutlineInputBorder(),
                  errorText: _passwordError,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: kPrimaryColor,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Confirm Password Field
              TextField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirm,
                style: const TextStyle(
                  color: kPrimaryColor,
                  fontWeight: FontWeight.bold,
                ),
                onChanged: _onConfirmChanged,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  labelStyle: const TextStyle(
                    color: kPrimaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                  border: const OutlineInputBorder(),
                  errorText: _confirmPasswordError,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                      color: kPrimaryColor,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirm = !_obscureConfirm;
                      });
                    },
                  ),
                ),
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
                          side: const BorderSide(
                            color: kPrimaryColor,
                            width: 2,
                          ),
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
                        onPressed: (_isPasswordValid && _isConfirmValid)
                            ? _onFinish
                            : null,
                        child: const Text('Finish'),
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
