import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'signup.dart';
import 'dashboard.dart';
import 'database_helper.dart';
import 'forgot_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final pass = TextEditingController();
  final green = const Color(0xFF2E9D8A);
  final bgColor = const Color(0xFFF5F5DC);

  String? emailError;
  String? passError;

  bool isValidEmail(String e) =>
      RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(e.trim());

  bool isValidPass(String p) => RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_])(?!.*\s).{8,}$',
  ).hasMatch(p);

  void validate() {
    setState(() {
      emailError = email.text.trim().isEmpty
          ? 'Email is required'
          : (!isValidEmail(email.text)
                ? 'Enter a valid email (e.g. abc@gmail.com)'
                : null);

      passError = pass.text.isEmpty
          ? 'Password is required'
          : (!isValidPass(pass.text)
                ? 'Min 8 chars, 1 upper, 1 lower, 1 digit, 1 special, no spaces'
                : null);
    });
  }

  Future<void> handleLogin() async {
    validate();
    if (emailError == null && passError == null) {
      try {
        // Show loading indicator
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
                  'Signing you in...',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        );

        final dbHelper = DatabaseHelper();
        bool loginSuccessful = false;

        try {
          // Try Firebase login first
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email.text.trim(),
            password: pass.text,
          );
          loginSuccessful = true;
          print('Firebase login successful');
        } catch (firebaseError) {
          print('Firebase login failed: $firebaseError');
          print('Trying local database login...');

          // Firebase failed, try local database
          Map<String, dynamic>? user = await dbHelper.loginUser(
            email: email.text.trim(),
            password: pass.text,
          );

          if (user != null) {
            loginSuccessful = true;
            print('Local database login successful: ${user['email']}');
          }
        }

        // Hide loading indicator
        if (mounted) Navigator.of(context).pop();

        if (loginSuccessful) {
          // Navigate to dashboard
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DashboardPage()),
            );
          }
        } else {
          // Show login failed message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Invalid email or password'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } on FirebaseAuthException catch (e) {
        // Hide loading indicator
        if (mounted) Navigator.of(context).pop();

        // Show error message
        String errorMessage;
        switch (e.code) {
          case 'user-not-found':
            errorMessage = 'No user found with this email.';
            break;
          case 'wrong-password':
            errorMessage = 'Wrong password provided.';
            break;
          case 'invalid-email':
            errorMessage = 'The email address is not valid.';
            break;
          case 'user-disabled':
            errorMessage = 'This user account has been disabled.';
            break;
          default:
            errorMessage = 'An error occurred. Please try again.';
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Live validation
    email.addListener(() {
      if (emailError != null) validate();
    });
    pass.addListener(() {
      if (passError != null) validate();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text("Digital Detox Login"),
        backgroundColor: green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              "Welcome Back!",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: green,
              ),
            ),
            const SizedBox(height: 20),

            // Email field
            TextField(
              controller: email,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "Email",
                prefixIcon: Icon(Icons.email, color: green),
                errorText: emailError,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            // Password field
            TextField(
              controller: pass,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password",
                prefixIcon: Icon(Icons.lock, color: green),
                errorText: passError,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ForgotPasswordPage(),
                      ),
                    );
                  },
                  child: Text(
                    "Forgot Password?",
                    style: TextStyle(color: green),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignupPage()),
                    );
                  },
                  child: Text("Sign Up", style: TextStyle(color: green)),
                ),
              ],
            ),
            const SizedBox(height: 15),

            ElevatedButton(
              onPressed: handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: green,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
              ),
              child: const Text("Login", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
