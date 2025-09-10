import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'login.dart'; // keep LoginPage as entry point
=======
import 'signup.dart';
>>>>>>> 74ff57eb0471715965f1b679b802eba0c68205cf

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Login App',
      home: LoginPage(),
    );
  }
}
