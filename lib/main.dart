import 'package:flutter/material.dart';
import 'signup.dart';  

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: SignupPage());
  }
}
