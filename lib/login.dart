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

  bool isValidEmail(String e) => RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(e);
  bool isValidPass(String p) =>
      RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*[\W_]).{6,}$').hasMatch(p);

  void validate() {
    setState(() {
      emailError = email.text.isEmpty
          ? 'Email required'
          : (!isValidEmail(email.text) ? 'Enter valid email' : null);
      passError = pass.text.isEmpty
          ? 'Password required'
          : (!isValidPass(pass.text)
              ? 'Min 6 chars, 1 upper, 1 lower, 1 special'
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(title: const Text("Digital Detox Login"), backgroundColor: green),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text("Welcome Back!", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: green)),
            const SizedBox(height: 20),
            TextField(
              controller: email,
              decoration: InputDecoration(
                  labelText: "Email",
                  prefixIcon: Icon(Icons.email, color: green),
                  errorText: emailError,
                  border: const OutlineInputBorder()),
            ),
            const SizedBox(height: 15),
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
                    SnackBar(content: const Text("Forgot Password!"), backgroundColor: green),
                  ),
                  child: Text("Forgot Password?", style: TextStyle(color: green)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupPage()));
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
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: const Text("Login", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
