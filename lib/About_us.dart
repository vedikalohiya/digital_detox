import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  final Color green = const Color(0xFF2E9D8A);
  final Color bgColor = const Color(0xFFF5F5DC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text("About Us"),
        backgroundColor: green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome to Digital Detox App",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: green,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Our Mission",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: green,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Digital Detox App helps users reduce screen time, "
              "improve focus, and maintain a healthy balance between "
              "digital life and real life. Our goal is to promote "
              "wellbeing and productivity by encouraging mindful digital usage.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Text(
              "Features",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: green,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "• Track your daily screen time.\n"
              "• Set reminders for breaks.\n"
              "• Analyze your digital habits.\n"
              "• Personalized tips to reduce distractions.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Text(
              "Contact Us",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: green,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Email: support@digitaldetox.com\n"
              "Phone: +91 9876543210\n"
              "Website: www.digitaldetox.com",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: green,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: const Text(
                  "Back",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
