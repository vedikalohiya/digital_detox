import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'database_helper.dart';
import 'signup.dart';
import 'dart:math';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailOrPhoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _otpSent = false;
  bool _otpVerified = false;
  String? _generatedOTP;
  String? _userEmail;
  String? _userPhone;
  Map<String, dynamic>? _foundUser;

  final Color kPrimaryColor = const Color(0xFF2E9D8A);
  final Color kBackgroundColor = const Color(0xFFF5F5DC);

  @override
  void dispose() {
    _emailOrPhoneController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(email.trim());
  }

  bool _isValidPhone(String phone) {
    return RegExp(r"^[\+]?[1-9][\d]{0,15}$").hasMatch(phone.trim());
  }

  bool _isValidPassword(String password) {
    return RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_])(?!.*\s).{8,}$',
    ).hasMatch(password);
  }

  String _generateOTP() {
    Random random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  Future<void> _findUserAndSendOTP() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final input = _emailOrPhoneController.text.trim();
      final dbHelper = DatabaseHelper();

      Map<String, dynamic>? user;

      // Check if input is email or phone
      if (_isValidEmail(input)) {
        user = await dbHelper.getUserByEmail(input);
      } else if (_isValidPhone(input)) {
        user = await dbHelper.getUserByPhone(input);
      }

      if (user == null) {
        setState(() {
          _isLoading = false;
        });
        _showErrorMessage('No account found with this email or phone number.');
        return;
      }

      // Generate and store OTP
      _generatedOTP = _generateOTP();
      _foundUser = user;
      _userEmail = user['email'];
      _userPhone = user['phone_number'];

      // Simulate sending OTP (in real app, you'd use SMS/Email service)
      await _simulateOTPSending();

      setState(() {
        _isLoading = false;
        _otpSent = true;
      });

      _showOTPSentDialog();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorMessage('An error occurred. Please try again.');
    }
  }

  Future<void> _simulateOTPSending() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // In a real app, you would:
    // 1. Send SMS to _userPhone using a service like Twilio
    // 2. Send email to _userEmail using a service like SendGrid
    // For now, we'll just show the OTP in console for testing
    print('=== OTP SENT ===');
    print('Phone: $_userPhone');
    print('Email: $_userEmail');
    print('OTP: $_generatedOTP');
    print('================');
  }

  void _verifyOTP() {
    final enteredOTP = _otpController.text.trim();

    if (enteredOTP.isEmpty) {
      _showErrorMessage('Please enter the OTP.');
      return;
    }

    if (enteredOTP == _generatedOTP) {
      setState(() {
        _otpVerified = true;
      });
      _showSuccessMessage(
        'OTP verified successfully! Now set your new password.',
      );
    } else {
      _showErrorMessage('Invalid OTP. Please try again.');
    }
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showErrorMessage('Passwords do not match.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final dbHelper = DatabaseHelper();
      await dbHelper.updateUserPassword(
        _foundUser!['id'],
        _newPasswordController.text,
      );

      setState(() {
        _isLoading = false;
      });

      _showPasswordResetSuccessDialog();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorMessage('Failed to update password. Please try again.');
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: kPrimaryColor),
    );
  }

  void _showOTPSentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.message, color: kPrimaryColor),
            const SizedBox(width: 8),
            const Text('OTP Sent'),
          ],
        ),
        content: Text(
          'OTP has been sent to:\n'
          'Phone: ${_userPhone ?? 'Not available'}\n'
          'Email: ${_userEmail ?? 'Not available'}\n\n'
          'Please enter the 6-digit code to continue.\n\n'
          'For testing purposes, check the console output for the OTP.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK', style: TextStyle(color: kPrimaryColor)),
          ),
        ],
      ),
    );
  }

  void _showPasswordResetSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: kPrimaryColor),
            const SizedBox(width: 8),
            const Text('Password Reset Successful'),
          ],
        ),
        content: const Text(
          'Your password has been reset successfully! '
          'You can now login with your new password.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Go back to login
            },
            child: Text('OK', style: TextStyle(color: kPrimaryColor)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: const Text(
          'Forgot Password',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(key: _formKey, child: _buildCurrentStep()),
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    if (!_otpSent) {
      return _buildEmailPhoneStep();
    } else if (!_otpVerified) {
      return _buildOTPStep();
    } else {
      return _buildPasswordResetStep();
    }
  }

  Widget _buildEmailPhoneStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 40),

        Icon(Icons.lock_reset, size: 80, color: kPrimaryColor),

        const SizedBox(height: 24),

        Text(
          'Reset Your Password',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: kPrimaryColor,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 16),

        Text(
          'Enter your email or phone number and we\'ll send you an OTP to reset your password.',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 40),

        TextFormField(
          controller: _emailOrPhoneController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Email or Phone Number',
            hintText: 'Enter your email or phone number',
            prefixIcon: Icon(Icons.person, color: kPrimaryColor),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: kPrimaryColor, width: 2),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your email or phone number';
            }
            if (!_isValidEmail(value) && !_isValidPhone(value)) {
              return 'Please enter a valid email or phone number';
            }
            return null;
          },
        ),

        const SizedBox(height: 32),

        SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _findUserAndSendOTP,
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                : const Text(
                    'Send OTP',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),

        const SizedBox(height: 24),

        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Back to Login',
            style: TextStyle(
              color: kPrimaryColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOTPStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 40),

        Icon(Icons.verified_user, size: 80, color: kPrimaryColor),

        const SizedBox(height: 24),

        Text(
          'Enter OTP',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: kPrimaryColor,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 16),

        Text(
          'Enter the 6-digit OTP sent to your phone and email.\n'
          '(Check console for testing OTP)',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 40),

        TextFormField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 6,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 8,
          ),
          decoration: InputDecoration(
            labelText: 'OTP',
            hintText: '000000',
            prefixIcon: Icon(Icons.lock_outline, color: kPrimaryColor),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: kPrimaryColor, width: 2),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter the OTP';
            }
            if (value.length != 6) {
              return 'OTP must be 6 digits';
            }
            return null;
          },
        ),

        const SizedBox(height: 32),

        SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: _verifyOTP,
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Verify OTP',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        TextButton(
          onPressed: () {
            setState(() {
              _otpSent = false;
              _otpController.clear();
            });
          },
          child: Text('Resend OTP', style: TextStyle(color: kPrimaryColor)),
        ),
      ],
    );
  }

  Widget _buildPasswordResetStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 40),

        Icon(Icons.lock_outline, size: 80, color: kPrimaryColor),

        const SizedBox(height: 24),

        Text(
          'Set New Password',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: kPrimaryColor,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 16),

        Text(
          'Enter your new password below.',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 40),

        TextFormField(
          controller: _newPasswordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'New Password',
            hintText: 'Enter new password',
            prefixIcon: Icon(Icons.lock, color: kPrimaryColor),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: kPrimaryColor, width: 2),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a password';
            }
            if (!_isValidPassword(value)) {
              return 'Min 8 chars, 1 upper, 1 lower, 1 digit, 1 special';
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        TextFormField(
          controller: _confirmPasswordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Confirm Password',
            hintText: 'Confirm new password',
            prefixIcon: Icon(Icons.lock_outline, color: kPrimaryColor),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: kPrimaryColor, width: 2),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please confirm your password';
            }
            if (value != _newPasswordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
        ),

        const SizedBox(height: 32),

        SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _resetPassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                : const Text(
                    'Reset Password',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
