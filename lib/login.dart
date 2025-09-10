import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController(), pass = TextEditingController();
  String msg = '';
  final green = const Color(0xFF2E9D8A);

  void handleLogin() {
    setState(() {
      if (email.text.isEmpty || pass.text.isEmpty) {
        msg = 'All fields are required.';
      } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email.text)) {
        msg = 'Enter a valid email.';
      } else if (pass.text.length < 6) {
        msg = 'Password must be at least 6 characters.';
      } else {
        msg = 'Login successful for ${email.text}!';
      }
    });
  }

  void showSnack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), backgroundColor: green),
    );
  }

  @override
  Widget build(BuildContext ctx) => Scaffold(
        appBar: AppBar(title: const Text("Digital Detox Login"), backgroundColor: green),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: SingleChildScrollView(
              child: Column(children: [
                Text("Welcome Back!",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: green)),
                const SizedBox(height: 30),
                TextField(
                  controller: email,
                  decoration: InputDecoration(
                      labelText: "Email",
                      prefixIcon: Icon(Icons.email, color: green),
                      border: const OutlineInputBorder()),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: pass,
                  obscureText: true,
                  decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: Icon(Icons.lock, color: green),
                      border: const OutlineInputBorder()),
                ),
                const SizedBox(height: 20),
                Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                  TextButton(
                      onPressed: () => showSnack("Forgot Password clicked!"),
                      child: Text("Forgot Password?", style: TextStyle(color: green))),
                  TextButton(
                      onPressed: () => showSnack("Register clicked!"),
                      child: Text("Register", style: TextStyle(color: green))),
                ]),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: handleLogin,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: green,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
                  child: const Text("Login"),
                ),
                const SizedBox(height: 20),
                Text(msg,
                    style: TextStyle(
                        color: msg.contains('successful') ? Colors.green : Colors.red)),
              ]),
            ),
          ),
        ),
      );
}
