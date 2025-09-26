import 'package:flutter/material.dart';
import 'signup.dart';
import 'dashboard.dart'; // Dashboard page

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

  // Email validation (RFC 5322 simplified)
  bool isValidEmail(String e) =>
      RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(e.trim());

  // Password validation (8+ chars, upper, lower, digit, special)
  bool isValidPass(String p) => RegExp(
          r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_])(?!.*\s).{8,}$')
      .hasMatch(p);

  void validate() {
    setState(() {
      // Email
      emailError = email.text.trim().isEmpty
          ? 'Email is required'
          : (!isValidEmail(email.text) ? 'Enter a valid email (e.g. abc@gmail.com)' : null);

      // Password
      passError = pass.text.isEmpty
          ? 'Password is required'
          : (!isValidPass(pass.text)
              ? 'Min 8 chars, 1 upper, 1 lower, 1 digit, 1 special, no spaces'
              : null);
    });
  }

  void handleLogin() {
    validate();
    if (emailError == null && passError == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardPage()),
      );
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
          title: const Text("Digital Detox Login"), backgroundColor: green),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text("Welcome Back!",
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: green)),
            const SizedBox(height: 20),

            // Email field
            TextField(
              controller: email,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                  labelText: "Email",
                  prefixIcon: Icon(Icons.email, color: green),
                  errorText: emailError,
                  border: const OutlineInputBorder()),
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
                  border: const OutlineInputBorder()),
            ),
            const SizedBox(height: 15),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: const Text("Forgot Password!"),
                        backgroundColor: green),
                  ),
                  child: Text("Forgot Password?", style: TextStyle(color: green)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const SignupPage()));
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child:
                  const Text("Login", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
